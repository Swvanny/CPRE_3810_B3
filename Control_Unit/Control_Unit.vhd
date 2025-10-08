library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
  port (
    -- Instruction fields
    -- CHANGE THESE CONSTANTS. PLEASE.
    opcode   : in  std_logic_vector(6 downto 0);
    funct3   : in  std_logic_vector(2 downto 0);
    funct7   : in  std_logic_vector(6 downto 0);

    -- Control outputs (match your table)
    ALUSrc            : out std_logic;                      -- 1-bit
    ALUControl        : out std_logic_vector(3 downto 0);   -- 4-bit
    ImmType           : out std_logic_vector(1 downto 0);   -- 2-bit
    AndLink           : out std_logic_vector(1 downto 0);   -- 2-bit
    MemWrite          : out std_logic;                      -- 1-bit
    RegWrite          : out std_logic;                      -- 1-bit
    MemToReg          : out std_logic_vector(1 downto 0);   -- 2-bit
    MemRead           : out std_logic;                      -- 1-bit
    Branch            : out std_logic;                      -- 1-bit
    Jump              : out std_logic;                      -- 1-bit
    ALU_Or_Imm_Jump   : out std_logic;                      -- 1-bit
    Flag_Mux          : out std_logic_vector(1 downto 0);   -- 2-bit
    Flag_Or_Nflag     : out std_logic                       -- 1-bit
  );
end entity;

architecture rtl of control_unit is

  -- RISC-V opcodes (RV32I)
  --AND THESE. PLEASE.
  
  constant OP_IMM  : std_logic_vector(6 downto 0) := "0010011"; -- I-type ALU (addi/andi/ori/xori/slti(u)/slli/srli/srai)
  constant OP      : std_logic_vector(6 downto 0) := "0110011"; -- R-type ALU (add/sub/and/or/xor/sll/srl/sra/slt)
  constant LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant LOAD    : std_logic_vector(6 downto 0) := "0000011"; -- lb/lh/lw/lbu/lhu
  constant STORE   : std_logic_vector(6 downto 0) := "0100011"; -- sb/sh/sw
  constant BRANCH  : std_logic_vector(6 downto 0) := "1100011"; -- beq/bne/blt/bge/bltu/bgeu
  constant JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant JALR    : std_logic_vector(6 downto 0) := "1100111";

  -- ALUControl codes (align with your table)
  -- 0000=AND, 0001=OR, 0010=XOR, 0011=ADD, 0100=SUB/SLT compare,
  -- 0101=SRL, 0110=SRA, 0111=SLL, 1000=LUI (as per your sheet)
  constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OR  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0010";
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0011";
  constant ALU_CMP : std_logic_vector(3 downto 0) := "0100"; -- used for SUB/SLT/branch compares in your mapping
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_LUI : std_logic_vector(3 downto 0) := "1000";

  -- ImmType enc (match your table)
  -- 01 = I-type (signed), 00 = I-type (unsigned) for sltiu row in your sheet,
  -- 10 = (used in your sheet for auipc MemToReg=10 path), 11 = U-type (lui/auipc)
  constant IMM_I_SIGNED   : std_logic_vector(1 downto 0) := "01";
  constant IMM_I_UNSIGNED : std_logic_vector(1 downto 0) := "00";
  constant IMM_U          : std_logic_vector(1 downto 0) := "11";
  constant IMM_AUX        : std_logic_vector(1 downto 0) := "10"; -- if you use it elsewhere (auipc row shows 11 though)

  -- MemToReg enc (match your sheet): 00=ALU result, 01=Memory, 10=PC+imm (auipc)
  constant MUX_ALU  : std_logic_vector(1 downto 0) := "00";
  constant MUX_MEM  : std_logic_vector(1 downto 0) := "01";
  constant MUX_AUX  : std_logic_vector(1 downto 0) := "10";

  -- Flag_Mux enc (from your rows):
  -- 11 = EQ/NE comparator, 00 = signed LT/GE, 10 = unsigned LT/GE
  constant FLAG_EQNE : std_logic_vector(1 downto 0) := "11";
  constant FLAG_SLT  : std_logic_vector(1 downto 0) := "00";
  constant FLAG_ULT  : std_logic_vector(1 downto 0) := "10";

begin

  -- Default safe values (NOP-like)
  process(opcode, funct3, funct7)
  begin
    ALUSrc          <= '0';
    ALUControl      <= ALU_ADD;
    ImmType         <= IMM_I_SIGNED;
    AndLink         <= "00";
    MemWrite        <= '0';
    RegWrite        <= '0';
    MemToReg        <= MUX_ALU;
    MemRead         <= '0';
    Branch          <= '0';
    Jump            <= '0';
    ALU_Or_Imm_Jump <= '0';
    Flag_Mux        <= FLAG_SLT;
    Flag_Or_Nflag   <= '0';

    case opcode is

      ------------------------------------------------------------------------
      -- R-type: add/sub/and/or/xor/sll/srl/sra/slt
      ------------------------------------------------------------------------
      when OP =>
        RegWrite   <= '1';
        MemToReg   <= MUX_ALU;
        ALUSrc     <= '0';
        case funct3 is
          when "000" =>  -- add/sub
            if (funct7 = "0100000") then
              ALUControl <= ALU_CMP; -- using 0100 per your table for SUB
            else
              ALUControl <= ALU_ADD; -- add
            end if;
          when "111" => ALUControl <= ALU_AND;
          when "110" => ALUControl <= ALU_OR;
          when "100" => ALUControl <= ALU_XOR;
          when "001" => ALUControl <= ALU_SLL;
          when "101" =>
            if (funct7 = "0100000") then
              ALUControl <= ALU_SRA;
            else
              ALUControl <= ALU_SRL;
            end if;
          when "010" =>  -- slt (signed compare)
            ALUControl <= ALU_CMP;    -- 0100 per your table
            Flag_Mux   <= FLAG_SLT;   -- signed comparator selected downstream
          when others =>
            null;
        end case;

      ------------------------------------------------------------------------
      -- I-type ALU: addi/andi/ori/xori/slti/sltiu/slli/srli/srai
      ------------------------------------------------------------------------
      when OP_IMM =>
        RegWrite   <= '1';
        ALUSrc     <= '1';
        MemToReg   <= MUX_ALU;

        case funct3 is
          when "000" =>  -- addi
            ALUControl <= ALU_ADD;
            ImmType    <= IMM_I_SIGNED;

          when "111" =>  -- andi
            ALUControl <= ALU_AND;
            ImmType    <= IMM_I_SIGNED;

          when "110" =>  -- ori
            ALUControl <= ALU_OR;
            ImmType    <= IMM_I_SIGNED;

          when "100" =>  -- xori
            ALUControl <= ALU_XOR;
            ImmType    <= IMM_I_SIGNED;

          when "010" =>  -- slti (signed)
            ALUControl    <= ALU_CMP;
            ImmType       <= IMM_I_SIGNED;
            Flag_Mux      <= FLAG_SLT;

          when "011" =>  -- sltiu (unsigned)
            ALUControl    <= ALU_CMP;             -- comparator datapath
            ImmType       <= IMM_I_UNSIGNED;      -- matches your table for SLTIU
            Flag_Mux      <= FLAG_ULT;            -- unsigned comparator

          when "001" =>  -- slli
            ALUControl    <= ALU_SLL;
            ImmType       <= "00";                -- your sheet shows 00 for shifts
          when "101" =>  -- srli/srai
            if (funct7 = "0100000") then
              ALUControl  <= ALU_SRA;
            else
              ALUControl  <= ALU_SRL;
            end if;
            ImmType       <= "00";
          when others =>
            null;
        end case;

      ------------------------------------------------------------------------
      -- LOADs: lb/lh/lw/lbu/lhu (top-level control same; size/sign by funct3)
      ------------------------------------------------------------------------
      when LOAD =>
        ALUSrc     <= '1';
        ALUControl <= ALU_ADD;   -- base + offset
        ImmType    <= IMM_I_SIGNED;  -- I-type signed offset
        RegWrite   <= '1';
        MemToReg   <= MUX_MEM;
        MemRead    <= '1';

      ------------------------------------------------------------------------
      -- STOREs: sb/sh/sw (funct3 chooses size; top-level control same)
      ------------------------------------------------------------------------
      when STORE =>
        ALUSrc     <= '1';
        ALUControl <= ALU_ADD;   -- base + offset
        ImmType    <= IMM_I_SIGNED;  -- S-type sign behavior in your pipe if reused
        MemWrite   <= '1';
        RegWrite   <= '0';

      ------------------------------------------------------------------------
      -- BRANCH: beq/bne/blt/bge/bltu/bgeu
      ------------------------------------------------------------------------
      when BRANCH =>
        Branch     <= '1';
        ALUSrc     <= '0';
        ALUControl <= ALU_CMP; -- use compare unit
        ImmType    <= IMM_I_SIGNED; -- your sheet shows 01 for branches

        case funct3 is
          when "000" => -- beq
            Flag_Mux      <= FLAG_EQNE;
            Flag_Or_Nflag <= '0';     -- equals
          when "001" => -- bne
            Flag_Mux      <= FLAG_EQNE;
            Flag_Or_Nflag <= '1';     -- not equals
          when "100" => -- blt (signed)
            Flag_Mux      <= FLAG_SLT;
            Flag_Or_Nflag <= '0';
          when "101" => -- bge (signed)
            Flag_Mux      <= FLAG_SLT;
            Flag_Or_Nflag <= '1';
          when "110" => -- bltu (unsigned)
            Flag_Mux      <= FLAG_ULT;
            Flag_Or_Nflag <= '0';
          when "111" => -- bgeu (unsigned)
            Flag_Mux      <= FLAG_ULT;
            Flag_Or_Nflag <= '1';
          when others =>
            null;
        end case;

      ------------------------------------------------------------------------
      -- JAL / JALR
      ------------------------------------------------------------------------
      when JAL =>
        Jump             <= '1';
        RegWrite         <= '1';      -- write link register
        AndLink          <= "01";     -- matches your table
        ImmType          <= IMM_U;    -- your sheet shows 11 for jal target immediate form
        MemToReg         <= MUX_ALU;  -- link (PC+4) typically from PC adder elsewhere; keep 00 here
        ALU_Or_Imm_Jump  <= '1';      -- your sheet shows 1 for jal
        -- ALUControl not used, but keep safe:
        ALUControl       <= ALU_ADD;

      when JALR =>
        Jump             <= '1';
        RegWrite         <= '1';
        AndLink          <= "01";
        ALUSrc           <= '1';         -- base + imm (for jalr)
        ALUControl       <= ALU_ADD;
        ImmType          <= IMM_I_SIGNED;
        ALU_Or_Imm_Jump  <= '0';         -- per your sheet
        MemToReg         <= MUX_ALU;

      ------------------------------------------------------------------------
      -- LUI / AUIPC
      ------------------------------------------------------------------------
      when LUI =>
        RegWrite   <= '1';
        ALUSrc     <= '1';
        ALUControl <= ALU_LUI;     -- 1000 per your table
        ImmType    <= IMM_U;
        MemToReg   <= MUX_MEM;     -- your sheet shows 01 for LUI row
        -- If your datapath writes imm<<12 directly, MemToReg here can be ignored by that path.

      when AUIPC =>
        RegWrite         <= '1';
        ImmType          <= IMM_U;
        MemToReg         <= MUX_AUX;     -- your sheet shows 10
        ALU_Or_Imm_Jump  <= '1';         -- use PC as ALU A (PC-relative)
        -- ALUControl/ALUSrc depend on your PC-ALU muxing; keep safe:
        ALUControl       <= ALU_ADD;

      ------------------------------------------------------------------------
      when others =>
        -- keep defaults (NOP-like)
        null;

    end case;
  end process;

end architecture;

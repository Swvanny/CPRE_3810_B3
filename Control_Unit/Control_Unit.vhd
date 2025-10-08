library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
  port (
    -- Instruction fields
    opcode   : in  std_logic_vector(6 downto 0);
    funct3   : in  std_logic_vector(2 downto 0);
    funct7   : in  std_logic_vector(6 downto 0);

    -- Control outputs
    ALUSrc            : out std_logic;
    ALUControl        : out std_logic_vector(3 downto 0);
    ImmType           : out std_logic_vector(1 downto 0);
    AndLink           : out std_logic_vector(1 downto 0);
    MemWrite          : out std_logic;
    RegWrite          : out std_logic;
    MemToReg          : out std_logic_vector(1 downto 0);
    Branch            : out std_logic;
    Jump              : out std_logic;
    ALU_Or_Imm_Jump   : out std_logic;
    Flag_Mux          : out std_logic_vector(1 downto 0);
    Flag_Or_Nflag     : out std_logic
  );
end entity;

architecture rtl of control_unit is

  -- === Opcode constants (RV32I) ===
  constant OP_IMM  : std_logic_vector(6 downto 0) := "0010011"; -- addi, andi, ori...
  constant OP      : std_logic_vector(6 downto 0) := "0110011"; -- add, sub, etc.
  constant LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant LOAD    : std_logic_vector(6 downto 0) := "0000011"; -- lb, lh, lw...
  constant STORE   : std_logic_vector(6 downto 0) := "0100011"; -- sb, sh, sw
  constant BRANCH  : std_logic_vector(6 downto 0) := "1100011"; -- beq, bne...
  constant JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant JALR    : std_logic_vector(6 downto 0) := "1100111";

  -- === ALU operation codes ===
  constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OR  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0010";
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0011";
  constant ALU_CMP : std_logic_vector(3 downto 0) := "0100"; -- SUB/compare
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_LUI : std_logic_vector(3 downto 0) := "1000";

  -- === Immediate and mux encodings ===
  constant IMM_I_SIGNED   : std_logic_vector(1 downto 0) := "01";
  constant IMM_I_UNSIGNED : std_logic_vector(1 downto 0) := "00";
  constant IMM_U          : std_logic_vector(1 downto 0) := "11";

  constant MUX_ALU  : std_logic_vector(1 downto 0) := "00";
  constant MUX_MEM  : std_logic_vector(1 downto 0) := "01";
  constant MUX_AUX  : std_logic_vector(1 downto 0) := "10";

  constant FLAG_EQNE : std_logic_vector(1 downto 0) := "11";
  constant FLAG_SLT  : std_logic_vector(1 downto 0) := "00";
  constant FLAG_ULT  : std_logic_vector(1 downto 0) := "10";

begin

  process(opcode, funct3, funct7)
  begin
    -- === Default values (NOP) ===
    ALUSrc          <= '0';
    ALUControl      <= ALU_ADD;
    ImmType         <= IMM_I_SIGNED;
    AndLink         <= "00";
    MemWrite        <= '0';
    RegWrite        <= '0';
    MemToReg        <= MUX_ALU;
    Branch          <= '0';
    Jump            <= '0';
    ALU_Or_Imm_Jump <= '0';
    Flag_Mux        <= FLAG_SLT;
    Flag_Or_Nflag   <= '0';

    case opcode is

      -------------------------------------------------------------------
      -- R-type (add, sub, and, or, xor, sll, srl, sra, slt)
      -------------------------------------------------------------------
      when OP =>
        RegWrite <= '1';
        ALUSrc   <= '0';
        MemToReg <= MUX_ALU;

        case funct3 is
          when "000" =>
            if (funct7 = "0100000") then
              ALUControl <= ALU_CMP; -- sub
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
          when "010" =>
            ALUControl <= ALU_CMP;  -- SLT (signed)
            Flag_Mux   <= FLAG_SLT;
          when others => null;
        end case;

      -------------------------------------------------------------------
      -- I-type immediate ALU (addi, andi, ori, xori, slti, sltiu, shifts)
      -------------------------------------------------------------------
      when OP_IMM =>
        RegWrite <= '1';
        ALUSrc   <= '1';
        MemToReg <= MUX_ALU;

        case funct3 is
          when "000" => ALUControl <= ALU_ADD; ImmType <= IMM_I_SIGNED; -- addi
          when "111" => ALUControl <= ALU_AND;
          when "110" => ALUControl <= ALU_OR;
          when "100" => ALUControl <= ALU_XOR;
          when "010" => ALUControl <= ALU_CMP; Flag_Mux <= FLAG_SLT;  -- slti
          when "011" => ALUControl <= ALU_CMP; Flag_Mux <= FLAG_ULT; ImmType <= IMM_I_UNSIGNED; -- sltiu
          when "001" => ALUControl <= ALU_SLL;                        -- slli
          when "101" =>
            if (funct7 = "0100000") then
              ALUControl <= ALU_SRA;
            else
              ALUControl <= ALU_SRL;
            end if;
          when others => null;
        end case;

      -------------------------------------------------------------------
      -- LOAD (lb, lh, lw, lbu, lhu)
      -------------------------------------------------------------------
      when LOAD =>
        ALUSrc     <= '1';
        ALUControl <= ALU_ADD;   -- base + offset
        ImmType    <= IMM_I_SIGNED;
        RegWrite   <= '1';
        MemToReg   <= MUX_MEM;   -- result comes from memory

      -------------------------------------------------------------------
      -- STORE (sb, sh, sw)
      -------------------------------------------------------------------
      when STORE =>
        ALUSrc     <= '1';
        ALUControl <= ALU_ADD;   -- base + offset
        ImmType    <= IMM_I_SIGNED;
        MemWrite   <= '1';
        RegWrite   <= '0';

      -------------------------------------------------------------------
      -- BRANCH (beq, bne, blt, bge, bltu, bgeu)
      -------------------------------------------------------------------
      when BRANCH =>
        Branch     <= '1';
        ALUSrc     <= '0';
        ALUControl <= ALU_CMP;
        ImmType    <= IMM_I_SIGNED;

        case funct3 is
          when "000" => Flag_Mux <= FLAG_EQNE; Flag_Or_Nflag <= '0'; -- beq
          when "001" => Flag_Mux <= FLAG_EQNE; Flag_Or_Nflag <= '1'; -- bne
          when "100" => Flag_Mux <= FLAG_SLT;  Flag_Or_Nflag <= '0'; -- blt
          when "101" => Flag_Mux <= FLAG_SLT;  Flag_Or_Nflag <= '1'; -- bge
          when "110" => Flag_Mux <= FLAG_ULT;  Flag_Or_Nflag <= '0'; -- bltu
          when "111" => Flag_Mux <= FLAG_ULT;  Flag_Or_Nflag <= '1'; -- bgeu
          when others => null;
        end case;

      -------------------------------------------------------------------
      -- JAL / JALR
      -------------------------------------------------------------------
      when JAL =>
        Jump             <= '1';
        RegWrite         <= '1';
        AndLink          <= "01";
        ALU_Or_Imm_Jump  <= '1';
        ALUControl       <= ALU_ADD;
        ImmType          <= IMM_U;

      when JALR =>
        Jump             <= '1';
        RegWrite         <= '1';
        AndLink          <= "01";
        ALU_Or_Imm_Jump  <= '0';
        ALUSrc           <= '1';
        ALUControl       <= ALU_ADD;
        ImmType          <= IMM_I_SIGNED;

      -------------------------------------------------------------------
      -- LUI / AUIPC
      -------------------------------------------------------------------
      when LUI =>
        RegWrite   <= '1';
        ALUSrc     <= '1';
        ALUControl <= ALU_LUI;
        ImmType    <= IMM_U;
        MemToReg   <= MUX_MEM;   -- your table lists 01 for LUI

      when AUIPC =>
        RegWrite         <= '1';
        ImmType          <= IMM_U;
        MemToReg         <= MUX_AUX;
        ALU_Or_Imm_Jump  <= '1';
        ALUControl       <= ALU_ADD;

      -------------------------------------------------------------------
      when others =>
        null;
    end case;
  end process;

end architecture;
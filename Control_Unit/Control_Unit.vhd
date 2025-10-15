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
    ALUSrc             : out std_logic;
    ALUControl         : out std_logic_vector(3 downto 0);
    ImmType            : out std_logic_vector(1 downto 0);
    AndLink            : out std_logic_vector(1 downto 0);
    MemWrite           : out std_logic;
    RegWrite           : out std_logic;
    MemToReg           : out std_logic;
    Branch             : out std_logic;
    Jump               : out std_logic;
    ALU_Or_Imm_Jump    : out std_logic;
    Flag_Mux           : out std_logic_vector(1 downto 0);
    Flag_Or_Nflag      : out std_logic;
    Jump_With_Register : out std_logic
  );
end entity;

architecture dataflow of control_unit is

  -- Opcode constants (RV32I)
  constant OP_I_Type  : std_logic_vector(6 downto 0) := "0010011"; -- OP-IMM (ADDI/SLTI/…/SLLI/SRLI/SRAI)
  constant OP_R_Type  : std_logic_vector(6 downto 0) := "0110011"; -- OP (ADD/SUB/…/SLL/SRL/SRA)
  constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
  constant OP_STORE   : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";

  -- ALU operation codes (your micro-ALU encoding)
  constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OR  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0010";
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0011";
  constant ALU_CMP : std_logic_vector(3 downto 0) := "0100"; -- SUB/compare path
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_LUI : std_logic_vector(3 downto 0) := "1000";

  -- Immediate encodings
  constant ImmType_12bit_Unsigned : std_logic_vector(1 downto 0) := "00";
  constant ImmType_12bit_Signed   : std_logic_vector(1 downto 0) := "01";
  constant ImmType_20bit_Unsigned : std_logic_vector(1 downto 0) := "10";
  constant ImmType_20bit_Signed   : std_logic_vector(1 downto 0) := "11";

  -- Branch flag-mux encodings (as per your design)
  constant FLAG_NEG      : std_logic_vector(1 downto 0) := "00";
  constant FLAG_OVERFLOW : std_logic_vector(1 downto 0) := "01";
  constant FLAG_CARRY    : std_logic_vector(1 downto 0) := "10";
  constant FLAG_ZERO     : std_logic_vector(1 downto 0) := "11";

  -- Opcode class signals
  signal is_Rtype  : std_logic;
  signal is_Itype  : std_logic;
  signal is_load   : std_logic;
  signal is_store  : std_logic;
  signal is_branch : std_logic;
  signal is_jal    : std_logic;
  signal is_jalr   : std_logic;
  signal is_lui    : std_logic;
  signal is_auipc  : std_logic;

  -- ALU control helpers
  signal aluctl_Rtype : std_logic_vector(3 downto 0);
  signal aluctl_Itype : std_logic_vector(3 downto 0);
  signal aluctl_main  : std_logic_vector(3 downto 0);

begin
  -----------------------------------------------------------------------------
  -- Opcode classification

  is_Rtype  <= '1' when opcode = OP_R_Type else '0';
  is_Itype  <= '1' when opcode = OP_I_Type else '0';
  is_load   <= '1' when opcode = OP_LOAD   else '0';
  is_store  <= '1' when opcode = OP_STORE  else '0';
  is_branch <= '1' when opcode = OP_BRANCH else '0';
  is_jal    <= '1' when opcode = OP_JAL    else '0';
  is_jalr   <= '1' when opcode = OP_JALR   else '0';
  is_lui    <= '1' when opcode = OP_LUI    else '0';
  is_auipc  <= '1' when opcode = OP_AUIPC  else '0';

  -----------------------------------------------------------------------------
  -- ALUControl decode for R-type: uses funct3 + funct7

  Rtype_decode : process(funct3, funct7)
  begin
    case funct3 is
      when "000" =>  -- ADD/SUB
        if funct7 = "0100000" then
          aluctl_Rtype <= ALU_CMP; -- SUB
        else
          aluctl_Rtype <= ALU_ADD; -- ADD (funct7 = 0000000)
        end if;

      when "001" =>  -- SLL
        aluctl_Rtype <= ALU_SLL;

      when "010" =>  -- SLT (signed compare path)
        aluctl_Rtype <= ALU_CMP;

      when "100" =>  -- XOR
        aluctl_Rtype <= ALU_XOR;

      when "101" =>  -- SRL/SRA
        if funct7 = "0100000" then
          aluctl_Rtype <= ALU_SRA;
        else
          aluctl_Rtype <= ALU_SRL;
        end if;

      when "110" =>  -- OR
        aluctl_Rtype <= ALU_OR;

      when "111" =>  -- AND
        aluctl_Rtype <= ALU_AND;

      when others =>
        aluctl_Rtype <= ALU_ADD;
    end case;
  end process;

  -----------------------------------------------------------------------------
  -- ALUControl decode for I-type (OP-IMM = 0010011): uses funct3 (+ funct7 for shifts)
  -- SLLI/SRLI require funct7=0000000; SRAI requires funct7=0100000.

  Itype_decode : process(funct3, funct7)
  begin
    case funct3 is
      when "000" =>  -- ADDI
        aluctl_Itype <= ALU_ADD;

      when "001" =>  -- SLLI
        -- RV32I: funct7 must be 0000000 for SLLI
        aluctl_Itype <= ALU_SLL;

      when "010" =>  -- SLTI
        aluctl_Itype <= ALU_CMP;

      when "011" =>  -- SLTIU (uses same compare datapath; flag logic decides unsigned)
        aluctl_Itype <= ALU_CMP;

      when "100" =>  -- XORI
        aluctl_Itype <= ALU_XOR;

      when "101" =>  -- SRLI/SRAI
        if funct7 = "0100000" then
          aluctl_Itype <= ALU_SRA; -- SRAI
        else
          aluctl_Itype <= ALU_SRL; -- SRLI (funct7=0000000)
        end if;

      when "110" =>  -- ORI
        aluctl_Itype <= ALU_OR;

      when "111" =>  -- ANDI
        aluctl_Itype <= ALU_AND;

      when others =>
        aluctl_Itype <= ALU_ADD;
    end case;
  end process;

  -----------------------------------------------------------------------------
  -- Main ALUControl selection by opcode class

  aluctl_main <=
    ALU_LUI                                   when is_lui  = '1' else
    ALU_ADD                                   when is_load = '1' or is_store = '1' or is_jal = '1' or is_jalr = '1' or is_auipc = '1' else
    aluctl_Rtype                              when is_Rtype = '1' else
    aluctl_Itype                              when is_Itype = '1' else
    ALU_ADD;  -- default/NOP

  ALUControl <= aluctl_main;

  -----------------------------------------------------------------------------
  -- ALUSrc (1 = use immediate; 0 = use rs2)

  ALUSrc <= '1' when (is_Itype = '1') or (is_load = '1') or (is_store = '1') or
                     (is_jalr = '1') or (is_lui = '1')
           else '0';

  -----------------------------------------------------------------------------
  -- Immediate type (choose your mapping; this one is conventional)

  ImmType <=
    ImmType_20bit_Unsigned when (is_lui   = '1') else     -- U-type: LUI
    ImmType_20bit_Signed   when (is_auipc = '1') or (is_jal = '1') else -- AUIPC/JAL offsets
    ImmType_12bit_Signed;                                  -- I/B/S types

  -----------------------------------------------------------------------------
  -- Link writing (x1) for JAL/JALR (your 2-bit AndLink encoding kept)

  AndLink <= "01" when (is_jal = '1') or (is_jalr = '1') else "00";

  -----------------------------------------------------------------------------
  -- Memory + Register write enables
 
  MemWrite <= '1' when is_store = '1' else '0';

  RegWrite <= '1' when (is_Rtype = '1') or (is_Itype = '1') or (is_load = '1') or
                        (is_jal = '1') or (is_jalr = '1') or (is_lui = '1') or
                        (is_auipc = '1')
              else '0';

  -----------------------------------------------------------------------------
  -- MemToReg (1 = from memory/LUI path; 0 = from ALU)
  -- If in your datapath LUI writes the immediate via the "MemToReg" mux, keep it as below.

  MemToReg <= '1' when (is_load = '1') or (is_lui = '1') else '0';

  -----------------------------------------------------------------------------
  -- Branch / Jump

  Branch <= '1' when is_branch = '1' else '0';
  Jump   <= '1' when (is_jal = '1') or (is_jalr = '1') else '0';

  -----------------------------------------------------------------------------
  -- ALU_Or_Imm_Jump: '1' for JAL/AUIPC (PC+imm), '0' for JALR (rs1+imm)

  ALU_Or_Imm_Jump <= '1' when (is_jal = '1') or (is_auipc = '1') else '0';

  -----------------------------------------------------------------------------
  -- Flag mux / invert (branch conditions)
  
  Flag_Mux <=
    FLAG_ZERO   when (is_branch = '1' and (funct3 = "000" or funct3 = "001")) else -- beq/bne
    FLAG_NEG    when (is_branch = '1' and (funct3 = "100" or funct3 = "101")) else -- blt/bge
    FLAG_CARRY  when (is_branch = '1' and (funct3 = "110" or funct3 = "111")) else -- bltu/bgeu
    FLAG_NEG;  -- default outside branch

  Flag_Or_Nflag <=
    '1' when (is_branch = '1' and (funct3 = "001" or funct3 = "101" or funct3 = "111")) -- bne, bge, bgeu (invert sense)
    else '0'; -- beq, blt, bltu, or non-branch

  -----------------------------------------------------------------------------
  -- JALR uses register (rs1) base for the jump target

  Jump_With_Register <= '1' when is_jalr = '1' else '0';

end architecture;

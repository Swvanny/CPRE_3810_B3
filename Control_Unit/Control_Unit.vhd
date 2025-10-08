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
  constant OP_I_Type  : std_logic_vector(6 downto 0) := "0010011";
  constant OP_R_Type  : std_logic_vector(6 downto 0) := "0110011";
  constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
  constant OP_SW      : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";

  -- ALU operation codes
  constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OR  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0010";
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0011";
  constant ALU_CMP : std_logic_vector(3 downto 0) := "0100"; -- SUB/compare
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_LUI : std_logic_vector(3 downto 0) := "1000";

  -- Immediate encodings
  constant ImmType_12bit_Unsigned : std_logic_vector(1 downto 0) := "00";
  constant ImmType_12bit_Signed   : std_logic_vector(1 downto 0) := "01";
  constant ImmType_20bit_Unsigned : std_logic_vector(1 downto 0) := "10";
  constant ImmType_20bit_Signed   : std_logic_vector(1 downto 0) := "11";

  -- Flag mux encodings (as per your design)
  constant FLAG_NEG      : std_logic_vector(1 downto 0) := "00";
  constant FLAG_OVERFLOW : std_logic_vector(1 downto 0) := "01";
  constant FLAG_CARRY    : std_logic_vector(1 downto 0) := "10";
  constant FLAG_ZERO     : std_logic_vector(1 downto 0) := "11";

  -- Classify opcode (one-hot enables)
  signal is_Rtype  : std_logic;
  signal is_Itype  : std_logic;
  signal is_load   : std_logic;
  signal is_store  : std_logic;
  signal is_branch : std_logic;
  signal is_jal    : std_logic;
  signal is_jalr   : std_logic;
  signal is_lui    : std_logic;
  signal is_auipc  : std_logic;

  -- Helpers for ALUControl selection
  signal aluctl_Rtype : std_logic_vector(3 downto 0);
  signal aluctl_Itype : std_logic_vector(3 downto 0);
  signal aluctl_main  : std_logic_vector(3 downto 0);

begin
  ---------------------------------------------------------------------------
  -- Opcode classification
  is_Rtype  <= '1' when opcode = OP_R_Type else '0';
  is_Itype  <= '1' when opcode = OP_I_Type else '0';
  is_load   <= '1' when opcode = OP_LOAD   else '0';
  is_store  <= '1' when opcode = OP_SW     else '0';
  is_branch <= '1' when opcode = OP_BRANCH else '0';
  is_jal    <= '1' when opcode = OP_JAL    else '0';
  is_jalr   <= '1' when opcode = OP_JALR   else '0';
  is_lui    <= '1' when opcode = OP_LUI    else '0';
  is_auipc  <= '1' when opcode = OP_AUIPC  else '0';

  ---------------------------------------------------------------------------
  -- ALUControl for R-type
  with funct3 select aluctl_Rtype <=
    -- add/sub
    ALU_CMP when "000" when funct7 = "0100000" else ALU_ADD,
    -- sll
    ALU_SLL when "001",
    -- slt (signed compare path)
    ALU_CMP when "010",
    -- xor
    ALU_XOR when "100",
    -- srl/sra
    ALU_SRA when "101" when funct7 = "0100000" else ALU_SRL,
    -- or
    ALU_OR  when "110",
    -- and
    ALU_AND when "111",
    -- default
    ALU_ADD when others;

  ---------------------------------------------------------------------------
  -- ALUControl for I-type (OP-IMM)
  -- Note: shifts use funct7 to distinguish srli vs srai.
  with funct3 select aluctl_Itype <=
    -- addi
    ALU_ADD when "000",
    -- slli
    ALU_SLL when "001",
    -- slti (signed compare)
    ALU_CMP when "010",
    -- sltiu (unsigned compare path shares ALU_CMP; flag mux decides signed/unsigned)
    ALU_CMP when "011",
    -- xori
    ALU_XOR when "100",
    -- srli / srai
    ALU_SRA when "101" when funct7 = "0100000" else ALU_SRL,
    -- ori
    ALU_OR  when "110",
    -- andi
    ALU_AND when "111",
    -- default
    ALU_ADD when others;

  ---------------------------------------------------------------------------
  -- Main ALUControl selection by opcode class
  aluctl_main <=
    ALU_LUI when is_lui  = '1' else
    ALU_ADD when is_load = '1' or is_store = '1' or is_jal = '1' or is_jalr = '1' or is_auipc = '1' else
    aluctl_Rtype when is_Rtype = '1' else
    aluctl_Itype when is_Itype = '1' else
    ALU_ADD;  -- default/NOP

  ALUControl <= aluctl_main;

  ---------------------------------------------------------------------------
  -- ALUSrc
  ALUSrc <= '1' when (is_itype = '1') or (is_load = '1') or (is_store = '1') or
                     (is_jalr = '1') or (is_lui = '1')
           else '0';

  ---------------------------------------------------------------------------
  -- ImmType
  ImmType <=
    -- 20-bit (signed) immediates for U/J types per mapping
    ImmType_20bit_Signed when (is_jal = '1') or (is_auipc = '1') or (is_lui = '1') else
    -- 12-bit signed for I/B/S
    ImmType_12bit_Signed;

  ---------------------------------------------------------------------------
  -- AndLink (writes link register)
  AndLink <= "01" when (is_jal = '1') or (is_jalr = '1') else "00";

  ---------------------------------------------------------------------------
  -- MemWrite / RegWrite
  MemWrite <= '1' when is_store = '1' else '0';

  RegWrite <= '1' when (is_Rtype = '1') or (is_Itype = '1') or (is_load = '1') or
                        (is_jal = '1') or (is_jalr = '1') or (is_lui = '1') or
                        (is_auipc = '1')
              else '0';

  ---------------------------------------------------------------------------
  -- MemToReg (single bit)
  -- MemToReg = '1' for LOADs and LUI.
  MemToReg <= '1' when (is_load = '1') or (is_lui = '1') else '0';

  ---------------------------------------------------------------------------
  -- Branch / Jump
  Branch <= '1' when is_branch = '1' else '0';
  Jump   <= '1' when (is_jal = '1') or (is_jalr = '1') else '0';

  ---------------------------------------------------------------------------
  -- ALU_Or_Imm_Jump ('1' for JAL/AUIPC, '0' for JALR)
  ALU_Or_Imm_Jump <= '1' when (is_jal = '1') or (is_auipc = '1') else '0';

  ---------------------------------------------------------------------------
  -- Flag mux and invert for branches
  -- Default (non-branch) values:
  Flag_Mux      <=
    FLAG_ZERO   when (is_branch = '1' and (funct3 = "000" or funct3 = "001")) else
    FLAG_NEG    when (is_branch = '1' and (funct3 = "100" or funct3 = "101")) else
    FLAG_CARRY  when (is_branch = '1' and (funct3 = "110" or funct3 = "111")) else
    FLAG_NEG;  -- default outside branch

  Flag_Or_Nflag <=
    '1' when (is_branch = '1' and (funct3 = "001" or funct3 = "101" or funct3 = "111")) -- bne, bge, bgeu
    else '0'; -- beq, blt, bltu, or non-branch

  ---------------------------------------------------------------------------
  -- Jump_With_Register (true only for JALR)
  Jump_With_Register <= '1' when is_jalr = '1' else '0';

end architecture;
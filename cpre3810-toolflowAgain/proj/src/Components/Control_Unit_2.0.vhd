library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Control_Unit_2 is
  port (
    opcode   : in  std_logic_vector(6 downto 0);
    funct3   : in  std_logic_vector(2 downto 0);
    funct7   : in  std_logic_vector(6 downto 0);

    ALUSrc             : out std_logic;
    ALUControl         : out std_logic_vector(3 downto 0);
    ImmType            : out std_logic_vector(6 downto 0);
    AndLink            : out std_logic_vector(1 downto 0);
    MemWrite           : out std_logic;
    RegWrite           : out std_logic;
    MemToReg           : out std_logic;
    Branch             : out std_logic;
    Jump               : out std_logic;
    ALU_Or_Imm_Jump    : out std_logic;
    Flag_Mux           : out std_logic_vector(1 downto 0);
    Flag_Or_Nflag      : out std_logic;
    Shift              : out std_logic;
    Halt               : out std_logic;
    Jump_With_Register : out std_logic
  );
end entity;

architecture dataflow of control_Unit_2 is

  -- Opcode constants
  constant OP_I_Type  : std_logic_vector(6 downto 0) := "0010011";
  constant OP_R_Type  : std_logic_vector(6 downto 0) := "0110011";
  constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
  constant OP_STORE   : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";
  constant OP_HALT    : std_logic_vector(6 downto 0) := "1110011";

  -- ALU operation codes
  constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OR  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0010";
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0011";
  constant ALU_CMP : std_logic_vector(3 downto 0) := "0100";
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_LUI : std_logic_vector(3 downto 0) := "1000";

  -- Immediate encodings
  constant ImmType_12bit_Unsigned : std_logic_vector(1 downto 0) := "00";
  constant ImmType_12bit_Signed   : std_logic_vector(1 downto 0) := "01";
  constant ImmType_20bit_Unsigned : std_logic_vector(1 downto 0) := "10";
  constant ImmType_20bit_Signed   : std_logic_vector(1 downto 0) := "11";

  -- Flag encodings
  constant FLAG_NEG      : std_logic_vector(1 downto 0) := "00";
  constant FLAG_OVERFLOW : std_logic_vector(1 downto 0) := "01";
  constant FLAG_CARRY    : std_logic_vector(1 downto 0) := "10";
  constant FLAG_ZERO     : std_logic_vector(1 downto 0) := "11";

  -- Opcode class signals
  signal is_Rtype, is_Itype, is_load, is_store,
         is_branch, is_jal, is_jalr, is_lui, is_auipc, is_shift : std_logic;

  signal aluctl_Rtype, aluctl_Itype, aluctl_main : std_logic_vector(3 downto 0);

begin
 
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


  -- ALUControl decode (R-type, purely concurrent form)
  aluctl_Rtype <=
    ALU_CMP when (funct3 = "000" and funct7 = "0100000") else -- SUB
    ALU_ADD when (funct3 = "000") else                        -- ADD
    ALU_SLL when (funct3 = "001") else
    ALU_CMP when (funct3 = "010") else
    ALU_XOR when (funct3 = "100") else
    ALU_SRA when (funct3 = "101" and funct7 = "0100000") else
    ALU_SRL when (funct3 = "101") else
    ALU_OR  when (funct3 = "110") else
    ALU_AND when (funct3 = "111") else
    ALU_ADD;


  -- ALUControl decode (I-type)
  aluctl_Itype <=
    ALU_ADD when (funct3 = "000") else
    ALU_SLL when (funct3 = "001") else
    ALU_CMP when (funct3 = "010" or funct3 = "011") else
    ALU_XOR when (funct3 = "100") else
    ALU_SRA when (funct3 = "101" and funct7 = "0100000") else
    ALU_SRL when (funct3 = "101") else
    ALU_OR  when (funct3 = "110") else
    ALU_AND when (funct3 = "111") else
    ALU_ADD;


  -- Main ALUControl selection
  aluctl_main <=
    ALU_LUI   when is_lui  = '1' else
    ALU_CMP   when is_branch = '1' else
    ALU_ADD   when (is_load = '1' or is_store = '1' or is_jal = '1' or is_jalr = '1' or is_auipc = '1') else
    aluctl_Rtype when is_Rtype = '1' else
    aluctl_Itype when is_Itype = '1' else
    ALU_ADD;

  ALUControl <= aluctl_main;

   -- Halt
    Halt <= '1' when opcode = OP_HALT else '0';

  -- ALUSrc
  ALUSrc <= '1' when (is_Itype = '1') or (is_load = '1') or (is_store = '1') or
                     (is_jalr = '1') or (is_lui = '1')
           else '0';


  -- ImmType
  ImmType <= 
    OP_I_Type  when opcode = OP_I_Type  else  -- arithmetic immediates (ADDI, etc.)
    OP_LOAD    when opcode = OP_LOAD    else  -- loads
    OP_STORE   when opcode = OP_STORE   else  -- stores
    OP_BRANCH  when opcode = OP_BRANCH  else  -- branches
    OP_JAL     when opcode = OP_JAL     else  -- jump and link
    OP_JALR    when opcode = OP_JALR    else  -- jump and link register
    OP_LUI     when opcode = OP_LUI     else  -- load upper immediate
    OP_AUIPC   when opcode = OP_AUIPC   else  -- add upper immediate to PC
    (others => '0');


  -- AndLink
  AndLink <= 
    "11" when (is_jal  = '1' or is_jalr = '1') else                                -- PC+4
    "01" when (is_auipc = '1') else                                                 -- PC + imm (AUIPC)
    "10" when ( (is_Rtype = '1' and (funct3 = "010" or funct3 = "011")) or          -- SLT/SLTU
              (is_Itype = '1' and (funct3 = "010" or funct3 = "011")) ) else      -- SLTI/SLTIU
    "00";       
  
  -- Memory and register control
  MemWrite <= '1' when is_store = '1' else '0';
  RegWrite <= '1' when (is_Rtype = '1' or is_Itype = '1' or is_load = '1' or
                        is_jal = '1' or is_jalr = '1' or is_lui = '1' or
                        is_auipc = '1') else '0';
                        
  MemToReg <= '1' when is_load = '1'  else '0';

  
  -- Branch / Jump
  Branch <= is_branch;
  Jump   <= '1' when (is_jal = '1' or is_jalr = '1') else '0';

  
  -- ALU_Or_Imm_Jump
  ALU_Or_Imm_Jump <= '1' when (is_branch = '1' or is_jal = '1' or is_auipc = '1') else '0';

  
  -- Flag_Mux
  Flag_Mux <=
    FLAG_ZERO  when (is_branch = '1' and (funct3 = "000" or funct3 = "001")) else
    FLAG_NEG   when (is_branch = '1' and (funct3 = "100" or funct3 = "101")) else
    FLAG_CARRY when (is_branch = '1' and (funct3 = "110" or funct3 = "111")) else
    FLAG_NEG;

  
  -- Flag_Or_Nflag
  Flag_Or_Nflag <=
    '1' when (is_branch = '1' and (funct3 = "001" or funct3 = "101" or funct3 = "111"))
    else '0';


  
  -- Jump_With_Register
  Jump_With_Register <= is_jalr;

   -- Shift
  Shift <= '1' when
             (is_Rtype = '1' and (funct3 = "001" or funct3 = "101")) or
             (is_Itype = '1' and (funct3 = "001" or funct3 = "101"))
           else '0';

end architecture;
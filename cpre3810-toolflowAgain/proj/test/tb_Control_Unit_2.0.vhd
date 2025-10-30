library ieee;
use ieee.std_logic_1164.all;

entity tb_control_unit is
end entity;

architecture sim of tb_control_unit_2 is
  -- DUT ports
  signal opcode   : std_logic_vector(6 downto 0);
  signal funct3   : std_logic_vector(2 downto 0);
  signal funct7   : std_logic_vector(6 downto 0);

  signal ALUSrc             : std_logic;
  signal ALUControl         : std_logic_vector(3 downto 0);
  signal ImmType            : std_logic_vector(1 downto 0);
  signal AndLink            : std_logic_vector(1 downto 0);
  signal MemWrite           : std_logic;
  signal RegWrite           : std_logic;
  signal MemToReg           : std_logic;
  signal Branch             : std_logic;
  signal Jump               : std_logic;
  signal ALU_Or_Imm_Jump    : std_logic;
  signal Flag_Mux           : std_logic_vector(1 downto 0);
  signal Flag_Or_Nflag      : std_logic;
  signal Jump_With_Register : std_logic;

  -- Helpful local constants for opcodes (match your control_unit)
  constant OP_I_Type : std_logic_vector(6 downto 0) := "0010011";
  constant OP_R_Type : std_logic_vector(6 downto 0) := "0110011";
  constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";
  constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";

begin
  -- DUT
  dut: entity work.control_unit
    port map (
      opcode, funct3, funct7,
      ALUSrc, ALUControl, ImmType, AndLink, MemWrite, RegWrite, MemToReg,
      Branch, Jump, ALU_Or_Imm_Jump, Flag_Mux, Flag_Or_Nflag, Jump_With_Register
    );

  -- Simple stimulus (no asserts; just drive and wait)
  stim: process
  begin
    -- Default idle
    opcode <= (others => '0'); funct3 <= (others => '0'); funct7 <= (others => '0');
    wait for 10 ns;

    -- R-type: ADD  (funct3=000, funct7=0000000)
    opcode <= OP_R_Type; funct3 <= "000"; funct7 <= "0000000";
    wait for 10 ns;

    -- R-type: SUB  (funct3=000, funct7=0100000)
    opcode <= OP_R_Type; funct3 <= "000"; funct7 <= "0100000";
    wait for 10 ns;

    -- R-type: SLL  (funct3=001)
    opcode <= OP_R_Type; funct3 <= "001"; funct7 <= "0000000";
    wait for 10 ns;

    -- R-type: SRL  (funct3=101, funct7=0000000)
    opcode <= OP_R_Type; funct3 <= "101"; funct7 <= "0000000";
    wait for 10 ns;

    -- R-type: SRA  (funct3=101, funct7=0100000)
    opcode <= OP_R_Type; funct3 <= "101"; funct7 <= "0100000";
    wait for 10 ns;

    -- I-type: ADDI (funct3=000)
    opcode <= OP_I_Type; funct3 <= "000"; funct7 <= "0000000"; -- funct7 ignored except for shifts
    wait for 10 ns;

    -- I-type: SLLI (funct3=001, funct7=0000000)
    opcode <= OP_I_Type; funct3 <= "001"; funct7 <= "0000000";
    wait for 10 ns;

    -- I-type: SRLI (funct3=101, funct7=0000000)
    opcode <= OP_I_Type; funct3 <= "101"; funct7 <= "0000000";
    wait for 10 ns;

    -- I-type: SRAI (funct3=101, funct7=0100000)
    opcode <= OP_I_Type; funct3 <= "101"; funct7 <= "0100000";
    wait for 10 ns;

    -- LOAD (e.g., LW)  funct3 varies, but control only needs opcode class
    opcode <= OP_LOAD;  funct3 <= "010"; funct7 <= "0000000";
    wait for 10 ns;

    -- STORE (e.g., SW)
    opcode <= OP_STORE; funct3 <= "010"; funct7 <= "0000000";
    wait for 10 ns;

    -- BRANCH: BEQ (funct3=000)
    opcode <= OP_BRANCH; funct3 <= "000"; funct7 <= "0000000";
    wait for 10 ns;

    -- BRANCH: BNE (funct3=001)
    opcode <= OP_BRANCH; funct3 <= "001"; funct7 <= "0000000";
    wait for 10 ns;

    -- BRANCH: BLT (funct3=100)
    opcode <= OP_BRANCH; funct3 <= "100"; funct7 <= "0000000";
    wait for 10 ns;

    -- BRANCH: BGEU (funct3=111)
    opcode <= OP_BRANCH; funct3 <= "111"; funct7 <= "0000000";
    wait for 10 ns;

    -- Jumps
    opcode <= OP_JAL;  funct3 <= "000"; funct7 <= "0000000";
    wait for 10 ns;
    opcode <= OP_JALR; funct3 <= "000"; funct7 <= "0000000";
    wait for 10 ns;

    -- U-type
    opcode <= OP_LUI;   funct3 <= "000"; funct7 <= "0000000";
    wait for 10 ns;
    opcode <= OP_AUIPC; funct3 <= "000"; funct7 <= "0000000";
    wait for 10 ns;

    -- Hold forever (lets you inspect waveforms)
    wait;
  end process;

end architecture;
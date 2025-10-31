-- tb_Control_Unit_2_no_asserts.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Control_Unit_2_no_asserts is
end entity;

architecture sim of tb_Control_Unit_2_no_asserts is
  -- Inputs
  signal opcode : std_logic_vector(6 downto 0) := (others => '0');
  signal funct3 : std_logic_vector(2 downto 0) := (others => '0');
  signal funct7 : std_logic_vector(6 downto 0) := (others => '0');

  -- Outputs
  signal ALUSrc             : std_logic;
  signal ALUControl         : std_logic_vector(3 downto 0);
  signal ImmType            : std_logic_vector(6 downto 0);
  signal AndLink            : std_logic_vector(1 downto 0);
  signal MemWrite           : std_logic;
  signal RegWrite           : std_logic;
  signal MemToReg           : std_logic;
  signal Branch             : std_logic;
  signal Jump               : std_logic;
  signal ALU_Or_Imm_Jump    : std_logic;
  signal Flag_Mux           : std_logic_vector(1 downto 0);
  signal Flag_Or_Nflag      : std_logic;
  signal Shift              : std_logic;
  signal Halt               : std_logic;
  signal Jump_With_Register : std_logic;

  procedure step is
  begin
    wait for 10 ns;
  end procedure;

  procedure print_state(constant tag : string) is
  begin
    report tag
      & " | op=" & to_hstring(opcode)
      & " f3="   & to_hstring(funct3)
      & " f7="   & to_hstring(funct7)
      & " || ALUctl=" & to_hstring(ALUControl)
      & " ALUSrc="    & std_logic'image(ALUSrc)
      & " ImmType(opcode proxy)=" & to_hstring(ImmType)
      & " AndLink="   & to_hstring(AndLink)
      & " MemWrite="  & std_logic'image(MemWrite)
      & " RegWrite="  & std_logic'image(RegWrite)
      & " MemToReg="  & std_logic'image(MemToReg)
      & " Branch="    & std_logic'image(Branch)
      & " Jump="      & std_logic'image(Jump)
      & " ALU_or_Imm_Jump=" & std_logic'image(ALU_Or_Imm_Jump)
      & " Flag_Mux="  & to_hstring(Flag_Mux)
      & " FlagOrN="   & std_logic'image(Flag_Or_Nflag)
      & " Shift="     & std_logic'image(Shift)
      & " Halt="      & std_logic'image(Halt)
      & " JmpReg="    & std_logic'image(Jump_With_Register)
      severity note;
  end procedure;

  -- Handy constants (must match DUT)
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

  -- RISC-V funct fields used
  constant F7_ADD  : std_logic_vector(6 downto 0) := "0000000";
  constant F7_SUB  : std_logic_vector(6 downto 0) := "0100000";
  constant F7_SRL  : std_logic_vector(6 downto 0) := "0000000";
  constant F7_SRA  : std_logic_vector(6 downto 0) := "0100000";

begin
  -- DUT
  dut: entity work.Control_Unit_2
    port map (
      opcode   => opcode,
      funct3   => funct3,
      funct7   => funct7,
      ALUSrc             => ALUSrc,
      ALUControl         => ALUControl,
      ImmType            => ImmType,
      AndLink            => AndLink,
      MemWrite           => MemWrite,
      RegWrite           => RegWrite,
      MemToReg           => MemToReg,
      Branch             => Branch,
      Jump               => Jump,
      ALU_Or_Imm_Jump    => ALU_Or_Imm_Jump,
      Flag_Mux           => Flag_Mux,
      Flag_Or_Nflag      => Flag_Or_Nflag,
      Shift              => Shift,
      Halt               => Halt,
      Jump_With_Register => Jump_With_Register
    );

  -- Drive a set of representative instructions and print what the decoder emits.
  stim: process
  begin
    --------------------------------------------------------------------
    -- R-type examples
    --------------------------------------------------------------------
    -- ADD  (funct3=000,f7=0000000) → ALU_ADD, RegWrite=1, ALUSrc=0, Shift=0
    opcode <= OP_R_Type; funct3 <= "000"; funct7 <= F7_ADD;
    step; print_state("R/ADD    ");

    -- SUB  (funct3=000,f7=0100000) → ALU_CMP (your code maps SUB to CMP)
    opcode <= OP_R_Type; funct3 <= "000"; funct7 <= F7_SUB;
    step; print_state("R/SUB(CMP)");

    -- AND  (funct3=111) → ALU_AND
    opcode <= OP_R_Type; funct3 <= "111"; funct7 <= F7_ADD;
    step; print_state("R/AND    ");

    -- OR   (funct3=110) → ALU_OR
    opcode <= OP_R_Type; funct3 <= "110"; funct7 <= F7_ADD;
    step; print_state("R/OR     ");

    -- XOR  (funct3=100) → ALU_XOR
    opcode <= OP_R_Type; funct3 <= "100"; funct7 <= F7_ADD;
    step; print_state("R/XOR    ");

    -- SLL  (funct3=001) → ALU_SLL, Shift=1
    opcode <= OP_R_Type; funct3 <= "001"; funct7 <= F7_ADD;
    step; print_state("R/SLL    ");

    -- SRL  (funct3=101,f7=0000000) → ALU_SRL, Shift=1
    opcode <= OP_R_Type; funct3 <= "101"; funct7 <= F7_SRL;
    step; print_state("R/SRL    ");

    -- SRA  (funct3=101,f7=0100000) → ALU_SRA, Shift=1
    opcode <= OP_R_Type; funct3 <= "101"; funct7 <= F7_SRA;
    step; print_state("R/SRA    ");

    --------------------------------------------------------------------
    -- I-type ALU examples
    --------------------------------------------------------------------
    -- ADDI (funct3=000) → ALU_ADD, ALUSrc=1, RegWrite=1
    opcode <= OP_I_Type; funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("I/ADDI   ");

    -- ANDI (funct3=111) → ALU_AND
    opcode <= OP_I_Type; funct3 <= "111"; funct7 <= (others => '0');
    step; print_state("I/ANDI   ");

    -- ORI  (funct3=110) → ALU_OR
    opcode <= OP_I_Type; funct3 <= "110"; funct7 <= (others => '0');
    step; print_state("I/ORI    ");

    -- XORI (funct3=100) → ALU_XOR
    opcode <= OP_I_Type; funct3 <= "100"; funct7 <= (others => '0');
    step; print_state("I/XORI   ");

    -- SLTI (funct3=010) → ALU_CMP; AndLink="10" per your mapping
    opcode <= OP_I_Type; funct3 <= "010"; funct7 <= (others => '0');
    step; print_state("I/SLTI   ");

    -- SLTIU (funct3=011) → ALU_CMP; Flag mux carries unsigned compare path
    opcode <= OP_I_Type; funct3 <= "011"; funct7 <= (others => '0');
    step; print_state("I/SLTIU  ");

    -- SLLI (funct3=001) → ALU_SLL, Shift=1
    opcode <= OP_I_Type; funct3 <= "001"; funct7 <= "0000000";
    step; print_state("I/SLLI   ");

    -- SRLI (funct3=101,f7=0000000) → ALU_SRL, Shift=1
    opcode <= OP_I_Type; funct3 <= "101"; funct7 <= "0000000";
    step; print_state("I/SRLI   ");

    -- SRAI (funct3=101,f7=0100000) → ALU_SRA, Shift=1
    opcode <= OP_I_Type; funct3 <= "101"; funct7 <= "0100000";
    step; print_state("I/SRAI   ");

    --------------------------------------------------------------------
    -- Memory
    --------------------------------------------------------------------
    -- LOAD  → ALU_ADD (addr gen), ALUSrc=1, RegWrite=1, MemToReg=1, MemWrite=0
    opcode <= OP_LOAD;  funct3 <= "010"; funct7 <= (others => '0'); -- funct3 varies by load width
    step; print_state("LOAD     ");

    -- STORE → ALU_ADD (addr gen), ALUSrc=1, MemWrite=1, RegWrite=0
    opcode <= OP_STORE; funct3 <= "010"; funct7 <= (others => '0'); -- funct3 varies by store width
    step; print_state("STORE    ");

    --------------------------------------------------------------------
    -- Branches (funct3 selects condition, ALUControl=ALU_CMP, Branch=1)
    --------------------------------------------------------------------
    -- BEQ  (funct3=000) → Flag_Mux=ZERO
    opcode <= OP_BRANCH; funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("BR/BEQ   ");

    -- BLT  (funct3=100) → Flag_Mux=NEG
    opcode <= OP_BRANCH; funct3 <= "100"; funct7 <= (others => '0');
    step; print_state("BR/BLT   ");

    -- BGEU (funct3=111) → Flag_Mux=CARRY
    opcode <= OP_BRANCH; funct3 <= "111"; funct7 <= (others => '0');
    step; print_state("BR/BGEU  ");

    --------------------------------------------------------------------
    -- Jumps / Upper immediates
    --------------------------------------------------------------------
    -- JAL  → Jump=1, RegWrite=1 (link), AndLink="11" (PC+4), ALU_or_Imm_Jump=1
    opcode <= OP_JAL;  funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("JAL      ");

    -- JALR → Jump=1, Jump_With_Register=1, ALUSrc=1, RegWrite=1
    opcode <= OP_JALR; funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("JALR     ");

    -- LUI  → ALUControl=ALU_LUI, ALUSrc=1, RegWrite=1
    opcode <= OP_LUI;  funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("LUI      ");

    -- AUIPC → ALU_ADD with PC, AndLink="01", ALU_or_Imm_Jump=1, RegWrite=1
    opcode <= OP_AUIPC; funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("AUIPC    ");

    --------------------------------------------------------------------
    -- HALT (custom)
    --------------------------------------------------------------------
    opcode <= OP_HALT; funct3 <= "000"; funct7 <= (others => '0');
    step; print_state("HALT     ");

    report "Control_Unit_2 decode sweep complete (manual check)." severity note;
    wait;
  end process;

end architecture sim;
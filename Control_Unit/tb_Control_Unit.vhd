library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Control_Unit is
end tb_Control_Unit;

architecture behavior of tb_Control_Unit is
component control_unit is
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
end component;


-- Instruction fields
   signal  opcode   :   std_logic_vector(6 downto 0);
   signal funct3   :  std_logic_vector(2 downto 0);
   signal funct7   :   std_logic_vector(6 downto 0);

    -- Control outputs
   signal   ALUSrc             :  std_logic;
   signal  ALUControl         :  std_logic_vector(3 downto 0);
   signal  ImmType            :  std_logic_vector(1 downto 0);
   signal AndLink            :  std_logic_vector(1 downto 0);
   signal MemWrite           :  std_logic;
   signal  RegWrite           :  std_logic;
   signal  MemToReg           :  std_logic;
   signal  Branch             :  std_logic;
   signal  Jump               :  std_logic;
   signal  ALU_Or_Imm_Jump    :  std_logic;
   signal Flag_Mux           :  std_logic_vector(1 downto 0);
   signal Flag_Or_Nflag      :  std_logic;
   signal Jump_With_Register :  std_logic;

   begin 

   UUT: control_unit
   port map(
   opcode => opcode,
   funct3 => funct3,
   funct7 => funct7,
   ALUSrc => ALUSrc,
   ALUControl => ALUControl,
   ImmType => ImmType,
   AndLink => AndLink,
   MemWrite => MemWrite,
   RegWrite => RegWrite,
   MemToReg => MemToReg,
   Branch => Branch,
   Jump => Jump,
   ALU_Or_Imm_Jump => ALU_Or_Imm_Jump,
   Flag_Mux => Flag_Mux,
   Flag_Or_Nflag => Flag_Or_Nflag,
   Jump_With_Register => Jump_With_Register
   );

    stim_proc: process
    begin
--R-TYPE INSTRUCTIONS

    --test R-type ADD instruction
    opcode <= "0110011"; 
    funct3 <= "000";
    funct7 <= "0000000";
wait for 10 ns;

    --test R-type SUB instruction
    opcode <= "0110011"; 
    funct3 <= "000";
    funct7 <= "0100000";
 wait for 10 ns;

    --test R-type AND instruction
    opcode <= "0110011"; 
    funct3 <= "111";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type OR instruction
    opcode <= "0110011"; 
    funct3 <= "110";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type XOR instruction
    opcode <= "0110011"; 
    funct3 <= "100";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type SLTU instruction
    opcode <= "0110011"; 
    funct3 <= "011";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type SLL instruction
    opcode <= "0110011"; 
    funct3 <= "001";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type SRL instruction
    opcode <= "0110011"; 
    funct3 <= "101";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type SLT instruction
    opcode <= "0110011"; 
    funct3 <= "010";
    funct7 <= "0000000";
 wait for 10 ns;
    --test R-type SRA instruction
    opcode <= "0110011"; 
    funct3 <= "101";
    funct7 <= "0100000";
 wait for 10 ns;


--I-TYPE INSTRUCTIONS

    --test I-type ADDI instruction
    opcode <= "0010011"; 
    funct3 <= "000";
    funct7 <= "0000000";
 wait for 10 ns;

    --more tests... 

    end process;

end behavior;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_types.all;

entity EXMEMRegister is
  port(
    i_CLK  : in std_logic;
    i_RST  : in std_logic;

    -- Inputs
    EXMEM_ALU_Flag        : in  std_logic;
    EXMEM_ALUOut          : in  std_logic_vector(31 downto 0);
    EXMEM_Shift           : in  std_logic;
    EXMEM_PC4             : in  std_logic_vector(31 downto 0);
    EXMEM_barrel          : in  std_logic_vector(31 downto 0);
    EXMEM_PC_jump_adder   : in  std_logic_vector(31 downto 0);
    EXMEM_Branch          : in  std_logic;
    EXMEM_Jump            : in  std_logic;
    EXMEM_FlagNFlag       : in  std_logic;
    EXMEM_AndLink         : in  std_logic_vector(1 downto 0);
    EXMEM_MemWrite        : in  std_logic;
    EXMEM_MemToReg        : in  std_logic;
    EXMEM_funct3          : in std_logic_vector(2 downto 0);

    EXMEM_funct3_out        : out std_logic_vector(2 downto 0);
    EXMEM_ALU_Flag_out      : out std_logic;
    EXMEM_ALUOut_out        : out std_logic_vector(31 downto 0);
    EXMEM_Shift_out         : out std_logic;
    EXMEM_PC4_out           : out std_logic_vector(31 downto 0);
    EXMEM_barrel_out        : out std_logic_vector(31 downto 0);
    EXMEM_PC_jump_adder_out : out std_logic_vector(31 downto 0);
    EXMEM_Branch_out        : out std_logic;
    EXMEM_Jump_out          : out std_logic;
    EXMEM_FlagNFlag_out     : out std_logic;
    EXMEM_AndLink_out       : out std_logic_vector(1 downto 0);
    EXMEM_MemWrite_out      : out std_logic;
    EXMEM_MemToReg_out      : out std_logic
  );
end EXMEMRegister;

architecture Structural of EXMEMRegister is

  component PipelineRegister is
    generic (
      N : integer := 32
    );
    port(
      i_CLK : in  std_logic;
      i_RST : in  std_logic;
      i_WE  : in  std_logic;
      i_D   : in  std_logic_vector(N-1 downto 0);
      o_Q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component PipelineRegister_logic is
   port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic;
       o_Q          : out std_logic     -- Data 
       );

end component;

begin

EXMEM_funct3_Register: PipelineRegister
    generic map (N => 3)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_funct3,
      o_Q   => EXMEM_funct3_out
    );

  EXMEM_ALUOut_Register: PipelineRegister
    generic map (N => 32)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_ALUOut,
      o_Q   => EXMEM_ALUOut_out
    );

  EXMEM_PC4_Register: PipelineRegister
    generic map (N => 32)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_PC4,
      o_Q   => EXMEM_PC4_out
    );

  EXMEM_barrel_Register: PipelineRegister
    generic map (N => 32)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_barrel,
      o_Q   => EXMEM_barrel_out
    );

  EXMEM_ALU_Flag_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_ALU_Flag,
      o_Q   => EXMEM_ALU_Flag_out
    );

  EXMEM_Shift_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_Shift,
      o_Q   => EXMEM_Shift_out
    );

  EXMEM_PC_jump_adder_Register: PipelineRegister
    generic map( N => 32)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_PC_jump_adder,
      o_Q   => EXMEM_PC_jump_adder_out
    );

  EXMEM_Branch_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_Branch,
      o_Q   => EXMEM_Branch_out
    );

  EXMEM_Jump_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_Jump,
      o_Q   => EXMEM_Jump_out
    );

  EXMEM_FlagNFlag_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_FlagNFlag,
      o_Q   => EXMEM_FlagNFlag_out
    );

  EXMEM_AndLink_Register: PipelineRegister
    generic map (N => 2)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_AndLink,
      o_Q   => EXMEM_AndLink_out
    );

  EXMEM_MemWrite_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_MemWrite,
      o_Q   => EXMEM_MemWrite_out
    );

  EXMEM_MemToReg_Register: PipelineRegister_logic
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => '1',
      i_D   => EXMEM_MemToReg,
      o_Q   => EXMEM_MemToReg_out
    );

end Structural;
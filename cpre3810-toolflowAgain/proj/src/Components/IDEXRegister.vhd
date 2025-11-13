library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_types.all;


entity IDEXRegister is 

port(
 i_CLK        : in std_logic;    
 i_RST        : in std_logic;
 

 IDEX_immGen        : in std_logic_vector(31 downto 0);
  IDEX_rs1          : in std_logic_vector(31 downto 0);
  IDEX_rs2          : in std_logic_vector(31 downto 0);
  IDEX_Branch       : in std_logic;
  IDEX_Jump         : in std_logic;
  IDEX_FlagNFlag    : in  std_logic;
  IDEX_AndLink      : in std_logic_vector(1 downto 0);
  IDEX_MemWrite     : in std_logic;
  IDEX_FlagMux      : in std_logic_vector(1 downto 0);
  IDEX_MemToReg     : in std_logic;
  IDEX_ALUSrc       : in std_logic;
  IDEX_Shift        : in std_logic;
  IDEX_ALUControl   : in std_logic_vector(3 downto 0);
  IDEX_JumpWithReg  : in std_logic;
  IDEX_PC           : in std_logic_vector(31 downto 0);
  IDEX_PC4          : in std_logic_vector(31 downto 0);
  IDEX_ALU_or_IMM   : in std_logic;
  IDEX_funct3       : in std_logic_vector(2 downto 0);
  IDEX_WriteBack    : in std_logic_vector(4 downto 0);

  IDEX_WriteBack_out    : out std_logic_vector(4 downto 0);
  IDEX_funct3_out       : out std_logic_vector(2 downto 0);
  IDEX_ALU_or_IMM_out   : out std_logic;
IDEX_immGen_out         : out std_logic_vector(31 downto 0);
   IDEX_rs1_out         : out std_logic_vector(31 downto 0);
   IDEX_rs2_out         : out std_logic_vector(31 downto 0);
   IDEX_Branch_out      : out std_logic;
   IDEX_Jump_out        : out std_logic;
   IDEX_FlagNFlag_out   : out std_logic;
   IDEX_AndLink_out     : out std_logic_vector(1 downto 0);
   IDEX_MemWrite_out    :  out std_logic;
   IDEX_FlagMux_out     : out std_logic_vector(1 downto 0);
   IDEX_MemToReg_out    :  out std_logic;
   IDEX_ALUSrc_out      : out std_logic;
   IDEX_Shift_out       : out std_logic;
   IDEX_ALUControl_out  : out std_logic_vector(3 downto 0);
   IDEX_JumpWithReg_out : out std_logic;
   IDEX_PC_out          : out std_logic_vector(31 downto 0);
   IDEX_PC4_out         : out std_logic_vector(31 downto 0)
);

end IDEXRegister;

architecture Structural of IDEXRegister is 


component PipelineRegister is
    generic (
        N : integer := 32  
    );

  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
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

IDEX_funct3_Register: PipelineRegister
  generic map(N => 3)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_funct3,     
       o_Q   => IDEX_funct3_out
);
IDEX_WriteBack_Register: PipelineRegister
  generic map(N => 5)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_WriteBack,     
       o_Q   => IDEX_WriteBack_out
);

  IDEX_rs1_Register: PipelineRegister
  generic map(N => 32)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_rs1,     
       o_Q   => IDEX_rs1_out
);

IDEX_rs2_Register: PipelineRegister
  generic map(N => 32)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_rs2,     
       o_Q   => IDEX_rs2_out
);

IDEX_immGen_Register: PipelineRegister
  generic map(N => 32)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_immGen,     
       o_Q   => IDEX_immGen_out
);

IDEX_Branch_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_Branch,     
       o_Q   => IDEX_Branch_out
);

IDEX_Jump_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_Jump,     
       o_Q   => IDEX_Jump_out
);

IDEX_FlagNFlag_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_FLagNFlag,     
       o_Q   => IDEX_FlagNFlag_out
);

IDEX_AndLink_Register: PipelineRegister
  generic map(N => 2)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_AndLink,     
       o_Q   => IDEX_AndLink_out
);


IDEX_MemWrite_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_MemWrite,     
       o_Q   => IDEX_MemWrite_out
);

IDEX_FlagMux_Register: PipelineRegister
  generic map(N => 2)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_FlagMux,     
       o_Q   => IDEX_FlagMux_out
);

IDEX_MemToReg_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_MemToReg,     
       o_Q   => IDEX_MemToReg_out
);

IDEX_ALUSrc_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_ALUSrc,     
       o_Q   => IDEX_ALUSrc_out
);

IDEX_Shift_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_Shift,     
       o_Q   => IDEX_Shift_out
);

IDEX_ALUControl_Register: PipelineRegister
  generic map(N => 4)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_ALUControl,     
       o_Q   => IDEX_ALUControl_out
);

IDEX_JumpWithReg_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_JumpWithReg,     
       o_Q   => IDEX_JumpWithReg_out
);

IDEX_PC_Register: PipelineRegister
  generic map(N => 32)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_PC,     
       o_Q   => IDEX_PC_out
);

IDEX_PC4_Register: PipelineRegister
  generic map(N => 32)
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_PC4,     
       o_Q   => IDEX_PC4_out
);

IDEX_ALU_or_Imm_Register: PipelineRegister_logic
  port map (
      i_CLK  => i_CLK,
       i_RST  => i_RST,
       i_WE => '1',
       i_D =>  IDEX_ALU_or_IMM,     
       o_Q   => IDEX_ALU_or_IMM_out
);

end Structural;


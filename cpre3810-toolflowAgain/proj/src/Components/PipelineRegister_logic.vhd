library IEEE;
use IEEE.std_logic_1164.all;

entity PipelineRegister is

  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic;
       o_Q          : out std_logic     -- Data 
       );

end PipelineRegister;

architecture Structural of PipelineRegister is
    component falling_dffg is
  port(i_CLK        : in std_logic;     -- Clock
       i_RST        : in std_logic;     -- Reset
       i_WE         : in std_logic;     -- Write 
       i_D          : in std_logic;     -- Data 
       o_Q          : out std_logic);   -- Data 
end component;



begin
    MUX: falling_dffg port map(
              i_CLK      => i_CLK,     
              i_RST     => i_RST,  
              i_WE     => i_WE,  
              i_D      => i_D,
              o_Q      => o_Q
              );  
  
end Structural ; 
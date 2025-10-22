library IEEE;
use IEEE.std_logic_1164.all;

entity nbitRegister is
    generic (
        N : integer := 32  
    );

  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;     
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
       );

end nbitRegister;

architecture Structural of nbitRegister is
    component dffg is
  port(i_CLK        : in std_logic;     -- Clock
       i_RST        : in std_logic;     -- Reset
       i_WE         : in std_logic;     -- Write 
       i_D          : in std_logic;     -- Data 
       o_Q          : out std_logic);   -- Data 
end component;

begin
  G_nbit_reg: for i in 0 to N-1 generate
    MUXI: dffg port map(
              i_CLK      => i_CLK,     
              i_RST     => i_RST,  
              i_WE     => i_WE,  
              i_D      => i_D(i),
              o_Q      => o_Q(i)
              );  
  end generate G_nbit_reg;


end Structural ; -- S
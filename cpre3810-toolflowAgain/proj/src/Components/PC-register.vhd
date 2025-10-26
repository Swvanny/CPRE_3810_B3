library IEEE;
use IEEE.std_logic_1164.all;

entity PCRegister is
    generic (
        N : integer := 32  
    );

  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
       );

end PCRegister;

architecture Structural of PCRegister is
    component pc_dffg is
  port(i_CLK        : in std_logic;     -- Clock
       i_RST        : in std_logic;     -- Reset
       i_WE         : in std_logic;     -- Write 
       i_INIT       : in std_logic;
       i_D          : in std_logic;     -- Data 
       o_Q          : out std_logic);   -- Data 
end component;

constant INIT_VALUE : std_logic_vector(31 downto 0) := X"00400000";
signal q_internal : std_logic_vector(31 downto 0);

begin
  G_nbit_reg: for i in 0 to N-1 generate
    MUXI: pc_dffg port map(
              i_CLK      => i_CLK,     
              i_RST     => i_RST,  
              i_WE     => i_WE,  
              i_INIT   => INIT_VALUE(i),
              i_D      => i_D(i),
              o_Q      => q_internal(i)
              );  
  end generate G_nbit_reg;

  o_Q <= q_internal;


end Structural ; 
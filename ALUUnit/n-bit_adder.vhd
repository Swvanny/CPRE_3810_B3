-------------------------------------------------------------------------
-- Anthon Worsham
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- andg2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is my n-bit adder
--
--
-- NOTES:

-------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;



entity Nbit_adder is
  generic(N : integer := 32);  
  port(
    i_A  : in std_logic_vector(N-1 downto 0);
    i_B  : in std_logic_vector(N-1 downto 0);
    i_C  : in std_logic;  
    o_S  : out std_logic_vector(N-1 downto 0);
    o_C  : out std_logic  
  );
end Nbit_adder;

architecture structural of Nbit_adder is

  
  component adder
    port (
      i_D0 : in std_logic;
      i_D1 : in std_logic;
      i_C  : in std_logic;
      oC   : out std_logic;
      o_O  : out std_logic
    );
  end component;

  
  signal carry : std_logic_vector(N downto 0);  

begin

  
  carry(0) <= i_C;

 
  gen_adder: for i in 0 to N-1 generate
    FA: adder
      port map(
        i_D0 => i_A(i),
        i_D1 => i_B(i),
        i_C  => carry(i),
        oC   => carry(i+1),
        o_O  => o_S(i)
      );
  end generate;

  
  o_C <= carry(N);

end structural;
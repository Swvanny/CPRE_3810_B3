-------------------------------------------------------------------------
-- Drew Swanson
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity ones_complementor is
  generic(
    N : integer := 32   -- width of the input/output bus
  );
  port (
    i_A : in  std_logic_vector(N-1 downto 0); -- input
    o_F : out std_logic_vector(N-1 downto 0)  -- one’s complement output
  );
end ones_complementor;

architecture structural of ones_complementor is
  -- Declare the inverter component (from invg.vhd)
  component invg
    port (
      i_A : in  std_logic;
      o_F : out std_logic
    );
  end component;
begin
  -- Generate one inverter per bit
  G1: for i in 0 to N-1 generate
    U_INV: invg
      port map (
        i_A => i_A(i),
        o_F => o_F(i)
      );
  end generate;
end structural;
library IEEE;
use IEEE.std_logic_1164.all;

entity zeroExtender_1to32 is
  port (
    data_in  : in  std_logic;                     -- single input bit
    data_out : out std_logic_vector(31 downto 0)  -- 32-bit zero-extended output
  );
end entity;

architecture Behavioral of zeroExtender_1to32 is
begin
  -- Pad 31 zeros above, keep input in least significant bit
  data_out <= (31 downto 1 => '0') & data_in;
end architecture Behavioral;
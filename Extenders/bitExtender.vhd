library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bitExtender is
    port (
        data_in  : in  std_logic_vector(11 downto 0);
        ctrl : in  std_logic; -- '0' for zero-extend, '1' for sign-extend
        data_out : out std_logic_vector(31 downto 0)
    );
end entity bitExtender;

architecture Behavioral of bitExtender is
begin
    data_out(11 downto 0) <= data_in;
    
    data_out(31 downto 12) <= (others => data_in(11)) when ctrl = '1' else (others => '0');
end architecture Behavioral;
library IEEE;
use IEEE.std_logic_1164.all;

entity nor_32t1bit is
    generic(WIDTH : integer := 32);
    port(
        i_D : in std_logic_vector(WIDTH-1 downto 0);
        o_O : out std_logic
    );
end nor_32t1bit;

architecture behavioral of nor_32t1bit is
begin
    -- NOR of all 32 bits
    o_O <= not (
        i_D(31) or i_D(30) or i_D(29) or i_D(28) or
        i_D(27) or i_D(26) or i_D(25) or i_D(24) or
        i_D(23) or i_D(22) or i_D(21) or i_D(20) or
        i_D(19) or i_D(18) or i_D(17) or i_D(16) or
        i_D(15) or i_D(14) or i_D(13) or i_D(12) or
        i_D(11) or i_D(10) or i_D(9)  or i_D(8)  or
        i_D(7)  or i_D(6)  or i_D(5)  or i_D(4)  or
        i_D(3)  or i_D(2)  or i_D(1)  or i_D(0)
    );
end behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity bitExtender is
    port (
        -- Provide up to 20 bits; the low 12 bits are used for 12-bit immediates.
        data_in  : in  std_logic_vector(19 downto 0);
        -- 00: ZEXT12, 01: SEXT12, 10: ZEXT20, 11: SEXT20
        ctrl     : in  std_logic_vector(1 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end entity bitExtender;

architecture Behavioral of bitExtender is
begin
    -- Select the proper extension
    with ctrl select
        data_out <=
            -- 12-bit zero-extend
            ((31 downto 12 => '0')            & data_in(11 downto 0)) when "00",

            -- 12-bit sign-extend
            ((31 downto 12 => data_in(11))    & data_in(11 downto 0)) when "01",

            -- 20-bit zero-extend
            ((31 downto 20 => '0')            & data_in(19 downto 0)) when "10",

            -- 20-bit sign-extend (default covers "11")
            ((31 downto 20 => data_in(19))    & data_in(19 downto 0)) when others;
end architecture Behavioral;
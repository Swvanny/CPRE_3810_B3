--Drew Swanson
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.reg_array.all;
use IEEE.numeric_std.all;

entity tb_mux_32by32 is
end tb_mux_32by32;

architecture behavior of tb_mux_32by32 is

    component mux_32by32 is
        port(
            sel : in std_logic_vector(4 downto 0);
            data_in : in reg_array;
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    signal sel : std_logic_vector(4 downto 0);
    signal data_in : reg_array;
    signal data_out : std_logic_vector(31 downto 0);

    begin
        dut0 : mux_32by32
        port map(
            sel => sel,
            data_in => data_in,
            data_out => data_out
        );

        mux_32by32_TESTS: process
        begin
            for i in 0 to 31 loop
                data_in(i) <= std_logic_vector(to_unsigned(i, 32));
            end loop;
            for i in 0 to 31 loop
                sel <= std_logic_vector(to_unsigned(i, 5));
                wait for 20 ns;
            end loop;    

        end process;

end behavior;
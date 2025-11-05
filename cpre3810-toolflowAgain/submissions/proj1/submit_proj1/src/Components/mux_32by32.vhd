library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

use work.reg_array.all;

entity mux_32by32 is
    port(
        sel : in std_logic_vector(4 downto 0);
        data_in : in reg_array;
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture dataflow of mux_32by32 is
    begin
        data_out <= data_in(to_integer(unsigned(sel)));
end architecture;
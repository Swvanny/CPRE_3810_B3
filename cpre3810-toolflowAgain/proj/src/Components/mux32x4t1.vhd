
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_types.all;

entity mux4x32t1 is
  
  port(sel        : in std_logic_vector(1 downto 0);
       bus_in		  : in t_bus_4x32;
       o_output 	: out std_logic_vector(31 downto 0));

end mux4x32t1;

architecture dataflow of mux4x32t1 is

begin
    o_output <= bus_in(to_integer(unsigned(sel)));
  
end dataflow;
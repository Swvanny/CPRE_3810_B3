-- Quartus Prime VHDL Template
-- Single-port RAM with single read/write address

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmem is

	generic 
	(
		DATA_WIDTH : natural := 32; -- this is the data length stored in memory to manipulate. It is the same length as the registers
		ADDR_WIDTH : natural := 10  -- this is the length of the data is stored in memory. 
	);

	port 
	(
		clk		: in std_logic; --clock for the memory
		addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);  --this is where the address is stored in memory
		data	        : in std_logic_vector((DATA_WIDTH-1) downto 0); -- this is the data that is stored at that address.
		we		: in std_logic := '1'; -- this is the enable for the write memory
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0) -- this is the output of the memory file
	);

end dmem;

architecture rtl of dmem is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;


	-- Declare the RAM signal and specify a default value.	Quartus Prime
	-- will load the provided memory initialization file (.mif).
	signal ram : memory_t;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(we = '1') then
			ram(to_integer(unsigned(addr))) <= data;
		end if;
	end if;
	end process;

	q <= ram(to_integer(unsigned(addr)));

end rtl;

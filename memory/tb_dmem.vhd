library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dmem is
end tb_dmem;

architecture behavior of tb_dmem is
	constant DATA_WIDTH : natural := 32;
constant ADDR_WIDTH : natural := 10;
constant clk_period : time := 10 ns;

    component dmem
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
    end component;

signal  clk		:  std_logic; --clock for the memory
signal 	addr	        :  std_logic_vector((ADDR_WIDTH-1) downto 0);  --this is where the address is stored in memory
signal 	data	        :  std_logic_vector((DATA_WIDTH-1) downto 0); -- this is the data that is stored at that address.
signal  we		:  std_logic := '1'; -- this is the enable for the write memory
signal 	q		:  std_logic_vector((DATA_WIDTH -1) downto 0); -- this is the output of the memory file




begin 

mem_inst: dmem
port map (
    clk => clk,
    addr => addr,
    data => data,
    we => we,
    q => q
);

clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

        stimulus : process  
		 variable i : integer;
        variable read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
        constant start_write_addr : integer := 16#100#; -- 0x100  
		type mem_array_t is array(0 to 9) of std_logic_vector(DATA_WIDTH-1 downto 0);
        variable initial_values : mem_array_t;
begin
	 data <= (others => '0');  

        -- Step (a) and (b): Read initial 10 values
        we <= '0';
        for i in 0 to 9 loop
            addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
            wait for clk_period;
            initial_values(i) := q;
        end loop;

        -- Step (c): Write those values to 0x100 onward
        we <= '1';
        for i in 0 to 9 loop
            addr <= std_logic_vector(to_unsigned(start_write_addr + i, ADDR_WIDTH));
            data <= initial_values(i);
            wait for clk_period;
        end loop;

        -- Step (d): Read them back and verify
        we <= '0';
        for i in 0 to 9 loop
            addr <= std_logic_vector(to_unsigned(start_write_addr + i, ADDR_WIDTH));
            wait for clk_period;
            read_data := q;
        end loop;

        wait;
    end process;

end behavior;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bitExtender is
end entity tb_bitExtender;

architecture Behavioral of tb_bitExtender is
    component bitExtender
        port (
            data_in  : in  std_logic_vector(11 downto 0);
            ctrl     : in  std_logic;
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals to connect to the UUT
    signal data_in  : std_logic_vector(11 downto 0);
    signal ctrl     : std_logic;
    signal data_out : std_logic_vector(31 downto 0);

begin
    -- Instantiate the UUT
    uut: bitExtender
        port map (
            data_in  => data_in,
            ctrl     => ctrl,
            data_out => data_out
        );

    -- Test process
    process
    begin
        -- Test case 1: Zero-extension
        data_in <= "000000000001"; -- Input: 1
        ctrl <= '0';
        wait for 10 ns;

        -- Test case 2: Sign-extension (positive number)
        data_in <= "011111111111"; -- Input: 2047
        ctrl <= '1';
        wait for 10 ns;

        -- Test case 3: Sign-extension (negative number)
        data_in <= "100000000000"; -- Input: -2048 (in 2's complement)
        ctrl <= '1';
        wait for 10 ns;

        -- Test case 4: Zero-extension with all zeros
        data_in <= "000000000000"; -- Input: 0
        ctrl <= '0';
        wait for 10 ns;

        -- Test case 5: Zero-extension with all ones
        data_in <= "111111111111"; -- Input: 4095
        ctrl <= '0';
        wait for 10 ns;

        --created by ChatGPT using 4.0 model "can you create a simple test bench for me"
        wait;
    end process;

end architecture;
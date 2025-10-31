-- tb_goblinBarrel_simple.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_goblinBarrel is
end entity;

architecture sim of tb_goblinBarrel is
  -- DUT inputs
  signal data_in          : std_logic_vector(31 downto 0) := (others => '0');
  signal shift_left_right : std_logic_vector(3 downto 0)  := (others => '0'); -- "0111" SLL, "0101" SRL, "0110" SRA
  signal shift_amount     : std_logic_vector(4 downto 0)  := (others => '0');
  signal data_out         : std_logic_vector(31 downto 0);

  -- constants
  constant C_SLL : std_logic_vector(3 downto 0) := "0111";
  constant C_SRL : std_logic_vector(3 downto 0) := "0101";
  constant C_SRA : std_logic_vector(3 downto 0) := "0110";

begin
  -- DUT instance
  dut: entity work.goblinBarrel
    port map(
      data_in          => data_in,
      shift_left_right => shift_left_right,
      shift_amount     => shift_amount,
      data_out         => data_out
    );

  -- stimulus
  stim: process
  begin
    --------------------------------------------------------------------
    -- Logical left shifts (SLL)
    --------------------------------------------------------------------
    report "Testing SLL...";
    data_in <= x"12345678";
    shift_left_right <= C_SLL;

    shift_amount <= "00000"; wait for 10 ns;
    shift_amount <= "00001"; wait for 10 ns;
    shift_amount <= "00100"; wait for 10 ns;
    shift_amount <= "01000"; wait for 10 ns;
    shift_amount <= "10000"; wait for 10 ns;
    shift_amount <= "11111"; wait for 10 ns;

    --------------------------------------------------------------------
    -- Logical right shifts (SRL)
    --------------------------------------------------------------------
    report "Testing SRL...";
    data_in <= x"12345678";
    shift_left_right <= C_SRL;

    shift_amount <= "00000"; wait for 10 ns;
    shift_amount <= "00001"; wait for 10 ns;
    shift_amount <= "00100"; wait for 10 ns;
    shift_amount <= "01000"; wait for 10 ns;
    shift_amount <= "10000"; wait for 10 ns;
    shift_amount <= "11111"; wait for 10 ns;

    --------------------------------------------------------------------
    -- Arithmetic right shifts (SRA) on negative input
    --------------------------------------------------------------------
    report "Testing SRA...";
    data_in <= x"F1234567";  -- negative number, MSB=1
    shift_left_right <= C_SRA;

    shift_amount <= "00000"; wait for 10 ns;
    shift_amount <= "00001"; wait for 10 ns;
    shift_amount <= "00100"; wait for 10 ns;
    shift_amount <= "01000"; wait for 10 ns;
    shift_amount <= "10000"; wait for 10 ns;
    shift_amount <= "11111"; wait for 10 ns;

    --------------------------------------------------------------------
    -- Arithmetic right shift (SRA) on positive input
    --------------------------------------------------------------------
    data_in <= x"12345678";  -- positive number, MSB=0
    shift_left_right <= C_SRA;

    shift_amount <= "00001"; wait for 10 ns;
    shift_amount <= "00100"; wait for 10 ns;
    shift_amount <= "01000"; wait for 10 ns;
    shift_amount <= "10000"; wait for 10 ns;
    shift_amount <= "11111"; wait for 10 ns;

    report "Barrel shifter test complete.";
    wait;
  end process;
end architecture sim;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_full_reg_file is
end entity;

architecture sim of tb_full_reg_file is
  -- DUT I/O
  signal i_data_in    : std_logic_vector(31 downto 0) := x"00000000";
  signal i_write_addr : std_logic_vector(4 downto 0)  := "00000";
  signal i_clk        : std_logic := '0';
  signal i_write_en   : std_logic := '0';
  signal i_rs1        : std_logic_vector(4 downto 0)  := "00000";
  signal i_rs2        : std_logic_vector(4 downto 0)  := "00000";
  signal o_rs1        : std_logic_vector(31 downto 0);
  signal o_rs2        : std_logic_vector(31 downto 0);

  constant CLK_HPER : time := 5 ns;  -- 10 ns period

begin
  -- Clock
  clk_proc : process
  begin
    i_clk <= '0'; wait for CLK_HPER;
    i_clk <= '1'; wait for CLK_HPER;
  end process;

  -- DUT
  dut: entity work.full_reg_file
    port map (
      i_data_in    => i_data_in,
      i_write_addr => i_write_addr,
      i_clk        => i_clk,
      i_write_en   => i_write_en,
      i_rs1        => i_rs1,
      i_rs2        => i_rs2,
      o_rs1        => o_rs1,
      o_rs2        => o_rs2
    );

  -- Checks
  stim: process
    procedure write_reg(addr : natural; data : std_logic_vector(31 downto 0)) is
    begin
      i_write_addr <= std_logic_vector(to_unsigned(addr, 5));
      i_data_in    <= data;
      i_write_en   <= '1';
      wait until rising_edge(i_clk);
      i_write_en   <= '0';
      wait for 1 ns;
    end procedure;

    procedure check_reads(
      a1, a2 : natural;
      exp1, exp2 : std_logic_vector(31 downto 0)
    ) is
    begin
      i_rs1 <= std_logic_vector(to_unsigned(a1, 5));
      i_rs2 <= std_logic_vector(to_unsigned(a2, 5));
      wait for 1 ns;
      assert o_rs1 = exp1
        report "o_rs1 mismatch for rs1=" & integer'image(a1) &
               " got " & to_hstring(o_rs1) &
               " expected " & to_hstring(exp1)
        severity error;
      assert o_rs2 = exp2
        report "o_rs2 mismatch for rs2=" & integer'image(a2) &
               " got " & to_hstring(o_rs2) &
               " expected " & to_hstring(exp2)
        severity error;
    end procedure;

    constant D5a : std_logic_vector(31 downto 0) := x"DEADBEEF";
    constant D5b : std_logic_vector(31 downto 0) := x"CAFEBABE";
    constant D10 : std_logic_vector(31 downto 0) := x"12345678";
    constant ZERO32 : std_logic_vector(31 downto 0) := x"00000000";

  begin
    -- 1) x0 must stay zero even if we "write" it
    write_reg(0, x"FFFFFFFF");
    check_reads(0, 0, ZERO32, ZERO32);

    -- 2) Write r5 and r10, then read them back on both ports
    write_reg(5,  D5a);
    write_reg(10, D10);
    check_reads(5, 10, D5a, D10);
    check_reads(10, 5, D10, D5a);

    -- 3) Overwrite r5 with new value and verify
    write_reg(5, D5b);
    check_reads(5, 10, D5b, D10);

    report "tb_full_reg_file completed OK." severity note;
    wait;
  end process;

end architecture sim;
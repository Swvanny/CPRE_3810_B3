-- tb_datapath_simple.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_datapathFetch is
end entity;

architecture sim of tb_datapathFetch is
  -- DUT ports
  signal i_clk               : std_logic := '0';
  signal i_data_in           : std_logic_vector(31 downto 0) := (others => '0');
  signal i_write_addr        : std_logic_vector(4 downto 0)  := (others => '0');
  signal i_write_en          : std_logic := '0';
  signal i_rs1               : std_logic_vector(4 downto 0)  := (others => '0');
  signal i_rs2               : std_logic_vector(4 downto 0)  := (others => '0');

  signal i_ALUSrc            : std_logic := '0';
  signal i_AddSubSel         : std_logic := '0';
  signal i_imm               : std_logic_vector(11 downto 0) := (others => '0');

  signal o_ALU_Sum           : std_logic_vector(31 downto 0);
  signal o_ALU_Carry         : std_logic;

  signal signed_or_zero_select : std_logic := '0';
  signal mem_we              : std_logic := '0';
  signal ALU_or_mem_sel      : std_logic := '0';

  constant T : time := 10 ns;
begin
  -- clock
  clkgen : process
  begin
    i_clk <= '0'; wait for T/2;
    i_clk <= '1'; wait for T/2;
  end process;

  -- DUT
  dut : entity work.datapathTwo_full_reg_file
    port map(
      i_data_in  => i_data_in,
      i_write_addr => i_write_addr,
      i_clk      => i_clk,
      i_write_en => i_write_en,
      i_rs1      => i_rs1,
      i_rs2      => i_rs2,
      i_ALUSrc   => i_ALUSrc,
      i_AddSubSel=> i_AddSubSel,
      i_imm      => i_imm,
      o_ALU_Sum  => o_ALU_Sum,
      o_ALU_Carry=> o_ALU_Carry,
      signed_or_zero_select => signed_or_zero_select,
      mem_we     => mem_we,
      ALU_or_mem_sel => ALU_or_mem_sel
    );

  -- stimulus
  stim : process
  begin
    -- defaults: take ALU path, ignore memory
    ALU_or_mem_sel        <= '0';
    mem_we                <= '0';
    signed_or_zero_select <= '0';   -- zero-extend immediates

    ----------------------------
    -- write x1 := 10
    ----------------------------
    i_write_addr <= std_logic_vector(to_unsigned(1,5));
    i_data_in    <= std_logic_vector(to_unsigned(10,32));
    i_write_en   <= '1';
    wait until rising_edge(i_clk);
    i_write_en   <= '0';
    wait until rising_edge(i_clk);

    ----------------------------
    -- write x2 := 20
    ----------------------------
    i_write_addr <= std_logic_vector(to_unsigned(2,5));
    i_data_in    <= std_logic_vector(to_unsigned(20,32));
    i_write_en   <= '1';
    wait until rising_edge(i_clk);
    i_write_en   <= '0';
    wait until rising_edge(i_clk);

    ----------------------------
    -- Test 1: ADD x1 + x2 = 30
    ----------------------------
    i_rs1       <= std_logic_vector(to_unsigned(1,5));
    i_rs2       <= std_logic_vector(to_unsigned(2,5));
    i_ALUSrc    <= '0';   -- use rs2
    i_AddSubSel <= '0';   -- add
    wait for 2 ns;
    assert o_ALU_Sum = std_logic_vector(to_unsigned(30,32))
      report "ADD failed" severity error;

    ----------------------------
    -- Test 2: ADDI x1 + 5 = 15
    ----------------------------
    i_ALUSrc    <= '1';   -- use imm
    i_imm       <= std_logic_vector(to_unsigned(5,12));
    i_AddSubSel <= '0';
    wait for 2 ns;
    assert o_ALU_Sum = std_logic_vector(to_unsigned(15,32))
      report "ADDI failed" severity error;

    ----------------------------
    -- Test 3: SUB x1 - x2 = -10
    ----------------------------
    i_ALUSrc    <= '0';
    i_AddSubSel <= '1';   -- subtract
    wait for 2 ns;
    assert o_ALU_Sum = std_logic_vector(to_signed(-10,32))
      report "SUB failed" severity error;

    report "Simple TB finished (check for ERRORs above)";
    wait;  -- leave running
  end process;

end architecture;
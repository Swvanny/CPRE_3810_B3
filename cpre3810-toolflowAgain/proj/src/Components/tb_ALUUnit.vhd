-- tb_ALUUnit_no_asserts.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_types.all;

entity tb_ALUUnit_no_asserts is
end entity;

architecture sim of tb_ALUUnit_no_asserts is
  -- DUT signals
  signal Alucontrol    : std_logic_vector(3 downto 0) := (others => '0');
  signal flag_mux      : std_logic_vector(1 downto 0) := (others => '0');
  signal input_A       : std_logic_vector(31 downto 0) := (others => '0');
  signal input_B       : std_logic_vector(31 downto 0) := (others => '0');
  signal output_result : std_logic_vector(31 downto 0);
  signal flag_zero     : std_logic;
  signal flag_carry    : std_logic;
  signal flag_negative : std_logic;
  signal flag_slt      : std_logic;

  procedure step is
  begin
    wait for 10 ns;
  end procedure;

  procedure print_state(constant tag : string) is
  begin
    report tag
      & "  A="  & to_hstring(input_A)
      & "  B="  & to_hstring(input_B)
      & "  ctrl=" & to_hstring(Alucontrol)
      & "  RES=" & to_hstring(output_result)
      & "  Z=" & std_logic'image(flag_zero)
      & "  N=" & std_logic'image(flag_negative)
      & "  C=" & std_logic'image(flag_carry)
      & "  SLT=" & std_logic'image(flag_slt)
      severity note;
  end procedure;

begin
  -- DUT
  dut: entity work.ALUUnit
    generic map (WIDTH => 32)
    port map (
      Alucontrol    => Alucontrol,
      flag_mux      => flag_mux,
      input_A       => input_A,
      input_B       => input_B,
      output_result => output_result,
      flag_zero     => flag_zero,
      flag_carry    => flag_carry,
      flag_negative => flag_negative,
      flag_slt      => flag_slt
    );

  -- Stimulus
  stim: process
  begin
    --------------------------------------------------------------------
    -- Test 1: AND (Alucontrol = "0000")
    -- A=0x80000001, B=0x7FFFFFFF → RES=0x00000001, Z=0, N=0
    --------------------------------------------------------------------
    input_A    <= x"80000001";
    input_B    <= x"7FFFFFFF";
    Alucontrol <= "0000";
    step; print_state("AND  ");

    --------------------------------------------------------------------
    -- Test 2: OR (Alucontrol = "0001")
    -- RES=0xFFFFFFFF, Z=0, N=1
    --------------------------------------------------------------------
    Alucontrol <= "0001";
    step; print_state("OR   ");

    --------------------------------------------------------------------
    -- Test 3: XOR (Alucontrol = "0010")
    -- RES=0xFFFFFFFF, Z=0, N=1
    --------------------------------------------------------------------
    Alucontrol <= "0010";
    step; print_state("XOR  ");

    --------------------------------------------------------------------
    -- Test 4: SUB (Alucontrol = "0100")
    -- A=5, B=3 → RES=2, Z=0, N=0, C=1 (no borrow), SLT=0
    --------------------------------------------------------------------
    input_A    <= std_logic_vector(to_unsigned(5,32));
    input_B    <= std_logic_vector(to_unsigned(3,32));
    Alucontrol <= "0100";
    step; print_state("SUB1 ");

    --------------------------------------------------------------------
    -- Test 5: SUB (borrow & negative)
    -- A=3, B=5 → RES=0xFFFF_FFFE (-2), Z=0, N=1, C=0 (borrow), SLT=1
    --------------------------------------------------------------------
    input_A    <= std_logic_vector(to_unsigned(3,32));
    input_B    <= std_logic_vector(to_unsigned(5,32));
    Alucontrol <= "0100";
    step; print_state("SUB2 ");

    --------------------------------------------------------------------
    -- Test 6: Pass-through case (Alucontrol = "1000")
    -- output_result should equal input_B (CAFEBABE)
    --------------------------------------------------------------------
    input_A    <= x"DEADBEEF";
    input_B    <= x"CAFEBABE";
    Alucontrol <= "1000";
    step; print_state("PASS ");

    --------------------------------------------------------------------
    -- Done
    --------------------------------------------------------------------
    report "Manual check complete. Review messages or waveforms." severity note;
    wait;
  end process;

end architecture sim;
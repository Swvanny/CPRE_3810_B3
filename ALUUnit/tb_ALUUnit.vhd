-- tb_ALUUnit_simple_noassert.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_types.all;

entity tb_ALUUnit is
end entity;

architecture sim of tb_ALUUnit is
  constant WIDTH : integer := DATA_WIDTH;

  -- DUT ports
  signal Alucontrol    : std_logic_vector(3 downto 0) := (others => '0');
  signal flag_mux      : std_logic_vector(1 downto 0) := "11"; -- show ZERO flag by default
  signal input_A       : std_logic_vector(WIDTH-1 downto 0)   := (others => '0');
  signal input_B       : std_logic_vector(WIDTH-1 downto 0)   := (others => '0');
  signal output_result : std_logic_vector(WIDTH-1 downto 0);
  signal flag          : std_logic;

  -- Helpers (no to_hstring dependency)
  function to_hex(slv : std_logic_vector) return string is
    constant HEX : string := "0123456789ABCDEF";
    variable L     : integer := slv'length;
    variable nibb  : integer := (L + 3)/4;
    variable tmp   : std_logic_vector(nibb*4-1 downto 0) := (others => '0');
    variable str   : string(1 to nibb);
    variable u     : unsigned(3 downto 0);
  begin
    tmp(L-1 downto 0) := slv(slv'high downto slv'low);
    for i in 0 to nibb-1 loop
      u := unsigned(tmp(tmp'high - i*4 downto tmp'high - i*4 - 3));
      str(i+1) := HEX(to_integer(u)+1);
    end loop;
    return str;
  end function;

  -- Convenience procedure to print a line
  procedure show(msg : in string) is
  begin
    report msg & "  A=0x" & to_hex(input_A)
                & "  B=0x" & to_hex(input_B)
                & "  ctl=" & std_logic'image(Alucontrol(3))
                           & std_logic'image(Alucontrol(2))
                           & std_logic'image(Alucontrol(1))
                           & std_logic'image(Alucontrol(0))
                & "  res=0x" & to_hex(output_result)
                & "  flag=" & std_logic'image(flag);
  end procedure;

  -- Example encodings (based on your control wiring)
  -- Lower 2 bits select AND/OR/XOR when Alucontrol(2)='0'
  constant CTL_AND : std_logic_vector(3 downto 0) := "0000"; -- ..00
  constant CTL_OR  : std_logic_vector(3 downto 0) := "0001"; -- ..01
  constant CTL_XOR : std_logic_vector(3 downto 0) := "0010"; -- ..10
  -- When Alucontrol(2)='1', your mux forces select "11" → bus_in(3) (add/sub)
  -- NOTE: In your code, nAdd_Sub is tied to Alucontrol(2), so with bit2='1' it behaves like SUB.
  -- If your nBit_ALU expects '0' for ADD and '1' for SUB, ADD may be unreachable as written.
  -- We still drive two values to demonstrate behavior:
  constant CTL_ADD_like : std_logic_vector(3 downto 0) := "1000"; -- intended "ADD (see note)"
  constant CTL_SUB_like : std_logic_vector(3 downto 0) := "1010"; -- intended "SUB (bit2=1)"

begin
  -- DUT
  dut : entity work.ALUUnit
    generic map (WIDTH => WIDTH)
    port map (
      Alucontrol    => Alucontrol,
      flag_mux      => flag_mux,
      input_A       => input_A,
      input_B       => input_B,
      output_result => output_result,
      flag          => flag
    );

  -- Stimulus (no asserts)
  process
    type v32a is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);
    constant As : v32a := (
      std_logic_vector'(x"00000000"),
      std_logic_vector'(x"FFFFFFFF"),
      std_logic_vector'(x"12345678"),
      std_logic_vector'(x"80000000")
    );
    constant Bs : v32a := (
      std_logic_vector'(x"00000000"),
      std_logic_vector'(x"00000001"),
      std_logic_vector'(x"87654321"),
      std_logic_vector'(x"80000000")
    );
  begin
    report "===== ALUUnit simple test (no asserts) =====";

    -- Show ZERO flag
    flag_mux <= "11";

    -- AND
    Alucontrol <= CTL_AND;
    for i in As'range loop
      input_A <= As(i); input_B <= Bs(i); wait for 5 ns; show("AND ");
    end loop;

    -- OR
    Alucontrol <= CTL_OR;
    for i in As'range loop
      input_A <= As(i); input_B <= Bs(i); wait for 5 ns; show("OR  ");
    end loop;

    -- XOR
    Alucontrol <= CTL_XOR;
    for i in As'range loop
      input_A <= As(i); input_B <= Bs(i); wait for 5 ns; show("XOR ");
    end loop;

    -- Arithmetic path (see note above re: ADD/SUB reachability)
    -- Try two different ctl values with bit2='1' to show behavior.
    Alucontrol <= CTL_ADD_like; -- may behave as SUB depending on nBit_ALU and your wiring
    for i in As'range loop
      input_A <= As(i); input_B <= Bs(i); wait for 5 ns; show("ARTH");
    end loop;

    Alucontrol <= CTL_SUB_like; -- also selects arithmetic path
    for i in As'range loop
      input_A <= As(i); input_B <= Bs(i); wait for 5 ns; show("ARTH");
    end loop;

    -- Now cycle flag selection (NEG/OVF/CARRY/ZERO) for the last result
    for f in 0 to 3 loop
      case f is
        when 0 => flag_mux <= "00"; -- NEG
        when 1 => flag_mux <= "01"; -- OVF
        when 2 => flag_mux <= "10"; -- CARRY
        when others => flag_mux <= "11"; -- ZERO
      end case;
      wait for 2 ns;
      show("FLAG");
    end loop;

    report " DONE ";
    wait;
  end process;

end architecture;
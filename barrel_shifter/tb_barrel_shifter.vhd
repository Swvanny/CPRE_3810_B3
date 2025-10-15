-- tb_barrel_shifter_simple.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_barrel_shifter is
end entity;

architecture sim of tb_barrel_shifter is
  -- Pick a width (32 matches RV32)
  constant WIDTH : integer := 32;

  -- DUT ports
  signal din        : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal shamt_vec  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal alu_ctl    : std_logic_vector(3 downto 0)       := (others => '0');
  signal dout       : std_logic_vector(WIDTH-1 downto 0);

  -- Only the low 2 bits matter in your design; set them explicitly
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0011"; -- ..11
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0001"; -- ..01
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0010"; -- ..10
  constant ALU_NOP : std_logic_vector(3 downto 0) := "0000"; -- ..00

  -- simple reference functions
  function ref_sll(v: std_logic_vector; s: natural) return std_logic_vector is
  begin
    return std_logic_vector(shift_left(unsigned(v), s));
  end function;
  function ref_srl(v: std_logic_vector; s: natural) return std_logic_vector is
  begin
    return std_logic_vector(shift_right(unsigned(v), s));
  end function;
  function ref_sra(v: std_logic_vector; s: natural) return std_logic_vector is
  begin
    return std_logic_vector(shift_right(signed(v), s));
  end function;

begin
  -- DUT
  dut : entity work.barrel_shifter
    generic map (WIDTH => WIDTH)
    port map (
      input       => din,
      shiftAmount => shamt_vec,
      ALUControl  => alu_ctl,
      output      => dout
    );

  -- Stimulus
  process
    type varr is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);
    constant patterns : varr := (
      std_logic_vector'(x"00000000"),
      std_logic_vector'(x"FFFFFFFF"),
      std_logic_vector'(x"12345678"),
      std_logic_vector'(x"7FFFFFFF"),
      std_logic_vector'(x"80000000"),
      std_logic_vector'(x"80000001")
    );

    type narr is array (natural range <>) of natural;
    constant shlist : narr := (0, 1, 2, 4, 7, 8, 15, 16, 31);

    variable s : natural;
    variable exp : std_logic_vector(WIDTH-1 downto 0);
  begin
    report "tb_barrel_shifter_simple: start";

    -- SLL -----------------------------------------------------------
    alu_ctl <= ALU_SLL;
    for p in patterns'range loop
      din <= patterns(p);
      for k in shlist'range loop
        s := shlist(k);
        shamt_vec <= std_logic_vector(to_unsigned(s, WIDTH));  -- WIDTH-wide vector, lower bits used
        wait for 2 ns;
        exp := ref_sll(patterns(p), s);
        assert dout = exp
          report "SLL mismatch: din=" & integer'image(to_integer(unsigned(patterns(p)(31 downto 0)))) &
                 " sh=" & integer'image(s)
          severity error;
      end loop;
    end loop;

    -- SRL -----------------------------------------------------------
    alu_ctl <= ALU_SRL;
    for p in patterns'range loop
      din <= patterns(p);
      for k in shlist'range loop
        s := shlist(k);
        shamt_vec <= std_logic_vector(to_unsigned(s, WIDTH));
        wait for 2 ns;
        exp := ref_srl(patterns(p), s);
        assert dout = exp
          report "SRL mismatch: din=" & integer'image(to_integer(unsigned(patterns(p)(31 downto 0)))) &
                 " sh=" & integer'image(s)
          severity error;
      end loop;
    end loop;

    -- SRA -----------------------------------------------------------
    alu_ctl <= ALU_SRA;
    for p in patterns'range loop
      din <= patterns(p);
      for k in shlist'range loop
        s := shlist(k);
        shamt_vec <= std_logic_vector(to_unsigned(s, WIDTH));
        wait for 2 ns;
        exp := ref_sra(patterns(p), s);
        assert dout = exp
          report "SRA mismatch: din=" & integer'image(to_integer(unsigned(patterns(p)(31 downto 0)))) &
                 " sh=" & integer'image(s)
          severity error;
      end loop;
    end loop;

    -- Pass-through (other code) ------------------------------------
    alu_ctl <= ALU_NOP;       -- low bits "00" → pass-through in your design
    for p in patterns'range loop
      din <= patterns(p);
      shamt_vec <= (others => '0');
      wait for 2 ns;
      assert dout = patterns(p)
        report "PASS-THRU mismatch" severity error;
    end loop;

    report "tb_barrel_shifter_simple: ALL TESTS PASSED" severity note;
    wait;
  end process;

end architecture;
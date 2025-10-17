-- tb_ALUUnit_simple_noassert.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_types.all;

entity tb_ALUUnit is
end tb_ALUUnit;

architecture behavior of tb_ALUUnit is

  constant WIDTH : integer := 32;

  component ALUUnit 
  port(
    Alucontrol    : in  std_logic_vector(3 downto 0);
    flag_mux      : in  std_logic_vector(1 downto 0);
    input_A       : in  std_logic_vector (WIDTH-1 downto 0);
    input_B       : in  std_logic_vector (WIDTH-1 downto 0);
    output_result : out std_logic_vector (WIDTH-1 downto 0);
    flag          : out std_logic
  );
end component;

  signal Alucontrol    : std_logic_vector(3 downto 0);
  signal flag_mux      : std_logic_vector(1 downto 0);
  signal input_A       : std_logic_vector(WIDTH-1 downto 0);
  signal input_B       : std_logic_vector(WIDTH-1 downto 0);
  signal output_result : std_logic_vector(WIDTH-1 downto 0);
  signal flag          : std_logic;

begin

  -- Instantiate the ALUUnit
  uut: ALUUnit
    generic map(WIDTH => WIDTH)
    port map(
      Alucontrol    => Alucontrol,
      flag_mux      => flag_mux,
      input_A       => input_A,
      input_B       => input_B,
      output_result => output_result,
      flag          => flag
    );

  -- Stimulus process
  process
  begin

    -- Test 1: AND
    input_A    <= x"F0F0F0F0";
    input_B    <= x"0F0F0F0F";
    Alucontrol <= "0000";  -- AND
    flag_mux   <= "11";    -- ZERO
    wait for 10 ns;

    -- Test 2: OR
    Alucontrol <= "0001";  -- OR
    wait for 10 ns;

    -- Test 3: XOR
    Alucontrol <= "0010";  -- XOR
    wait for 10 ns;

    -- Test 4: ADD
    input_A    <= std_logic_vector(to_unsigned(5, WIDTH));
    input_B    <= std_logic_vector(to_unsigned(10, WIDTH));
    Alucontrol <= "0011";  -- ADD
    flag_mux   <= "10";    -- CARRY
    wait for 10 ns;

    -- Test 5: SUB
    input_A    <= std_logic_vector(to_unsigned(15, WIDTH));
    input_B    <= std_logic_vector(to_unsigned(5, WIDTH));
    Alucontrol <= "0100";  -- SUB
    flag_mux   <= "00";    -- NEG
    wait for 10 ns;

    -- Test 6: SUB (Zero result)
    input_A    <= std_logic_vector(to_unsigned(20, WIDTH));
    input_B    <= std_logic_vector(to_unsigned(20, WIDTH));
    Alucontrol <= "0100";  -- SUB
    flag_mux   <= "11";    -- ZERO
    wait for 10 ns;

    -- Stop simulation
    wait;
  end process;

end architecture;
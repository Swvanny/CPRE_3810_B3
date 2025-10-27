library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_types.all;

entity ALUUnit is
  generic (WIDTH : integer := DATA_WIDTH);
  port(
    Alucontrol    : in  std_logic_vector(3 downto 0);
    flag_mux      : in  std_logic_vector(1 downto 0);
    input_A       : in  std_logic_vector (WIDTH-1 downto 0);
    input_B       : in  std_logic_vector (WIDTH-1 downto 0);
    output_result : out std_logic_vector (WIDTH-1 downto 0);
    flag_zero     : out std_logic;
    flag_carry    : out std_logic;
    flag_negative : out std_logic;
    flag_overflow : out std_logic
  );
end ALUUnit;

architecture structural of ALUUnit is

  -- This is the 4×32 bus feeding the result mux (AND, OR, XOR, ADD/SUB)
  signal bus_in : t_bus_4x32;

  component nBit_ALU is
    port(
      nAdd_Sub   : in  std_logic;                        -- 0: ADD, 1: SUB
      input_A    : in  std_logic_vector(31 downto 0);
      input_B    : in  std_logic_vector(31 downto 0);
      output_Sum : out std_logic_vector(31 downto 0);
      flag_Z     : out std_logic;
      flag_N     : out std_logic;
      flag_C     : out std_logic;                        -- SUB: 1 = no-borrow
      flag_V     : out std_logic
    );
  end component;

  component and_32bit
    port(
      i_D0 : in  std_logic_vector(WIDTH-1 downto 0);
      i_D1 : in  std_logic_vector(WIDTH-1 downto 0);
      o_O  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component xor_32bit
    port(
      i_D0 : in  std_logic_vector(WIDTH-1 downto 0);
      i_D1 : in  std_logic_vector(WIDTH-1 downto 0);
      o_O  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component or_32bit
    port(
      i_D0 : in  std_logic_vector(WIDTH-1 downto 0);
      i_D1 : in  std_logic_vector(WIDTH-1 downto 0);
      o_O  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component mux4x32t1 is
    port(
      sel      : in  std_logic_vector(1 downto 0);
      bus_in   : in  t_bus_4x32;
      o_output : out std_logic_vector(31 downto 0)
    );
  end component;

  component mux2t1_N is
    generic (N : integer := 2);
    port(
      i_S  : in  std_logic;
      i_X0 : in  std_logic_vector(N-1 downto 0);
      i_X1 : in  std_logic_vector(N-1 downto 0);
      o_X  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component mux4t1
    port(
      i_D0 : in  std_logic;
      i_D1 : in  std_logic;
      i_D2 : in  std_logic;
      i_D3 : in  std_logic;
      i_S  : in  std_logic_vector(1 downto 0);
      o_Y  : out std_logic
    );
  end component;

  signal mux_control4t1, mux_control2t1 : std_logic_vector(1 downto 0);
  signal finalResult : std_logic_vector(WIDTH-1 downto 0);
  signal neg, zero : std_logic;
  signal adderZ, adderN, adderC, adderV : std_logic;
  signal is_add, is_sub : std_logic;

  -- Separate bit to select the adder result into the final mux
  -- Alucontrol(3) = 1 selects the adder path; 0 selects logic via Alucontrol(1 downto 0)
  signal adder_sel : std_logic;

begin

  -- Control signals
  mux_control2t1 <= Alucontrol(1 downto 0);  -- 00=AND, 01=OR, 10=XOR
  
  
  neg  <= finalResult(WIDTH-1);
  zero <= '1' when unsigned(finalResult) = 0 else '0';
is_add <= '0' when Alucontrol = "0011" else '0';
is_sub <= '1' when Alucontrol = "0100" else '0';

adder_sel      <= is_add or is_sub;

  -- Logical units populate bus_in(0..2)
  andUnit : and_32bit
    port map(
      i_D0 => input_A,
      i_D1 => input_B,
      o_O  => bus_in(0)
    );

  orUnit : or_32bit
    port map(
      i_D0 => input_A,
      i_D1 => input_B,
      o_O  => bus_in(1)
    );

  xorUnit : xor_32bit
    port map(
      i_D0 => input_A,
      i_D1 => input_B,
      o_O  => bus_in(2)
    );

  -- Adder/Subtractor populates bus_in(3); Alucontrol(2) selects ADD(0)/SUB(1)
  addsub : nBit_ALU
    port map(
      nAdd_Sub   => adder_sel,
      input_A    => input_A,
      input_B    => input_B,
      output_Sum => bus_in(3),
      flag_Z     => adderZ,
      flag_N     => adderN,
      flag_C     => adderC,
      flag_V     => adderV
    );

  -- If adder_sel=1 → force select "11" (ADD/SUB); else lower 2 bits select logic ops
  muxBeforeResult : mux2t1_N
    generic map(N => 2)
    port map(
      i_S  => adder_sel,
      i_X0 => mux_control2t1,  -- 00=AND, 01=OR, 10=XOR
      i_X1 => "11",            -- 11=ADD/SUB
      o_X  => mux_control4t1
    );

  -- Select final result among AND/OR/XOR/ADD(SUB)
  muxResult : mux4x32t1
    port map(
      sel      => mux_control4t1,
      bus_in   => bus_in,
      o_output => finalResult
    );

  -- Drive output results
  output_result <= input_B when Alucontrol = "1000" else finalResult;

  -- Dedicated flag outputs
  -- Negative/Zero reflect the final selected result (valid for all ops)
  -- Carry/Overflow are only meaningful when the adder path is selected
  flag_negative <= neg;
  flag_zero     <= zero;
  flag_carry    <= adderC when mux_control4t1 = "11" else '0';
  flag_overflow <= '0';


end architecture structural;
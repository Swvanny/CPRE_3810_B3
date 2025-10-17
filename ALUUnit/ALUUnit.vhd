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
    flag          : out std_logic
  );
end ALUUnit;

architecture structural of ALUUnit is

  -- Components 

  component nBit_ALU
    port(
      nAdd_Sub        : in  std_logic;
      input_A         : in  std_logic_vector(WIDTH-1 downto 0);
      input_B         : in  std_logic_vector(WIDTH-1 downto 0);
      output_Sum      : out std_logic_vector(WIDTH-1 downto 0);
      output_Carry    : out std_logic;
      output_Overflow : out std_logic
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
      i_D0 : in  std_logic_vector(N-1 downto 0);
      i_D1 : in  std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
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


  -- Signals

  signal mux_control4t1, mux_control2t1 : std_logic_vector(1 downto 0);
  signal finalResult                    : std_logic_vector(WIDTH-1 downto 0);
  signal neg, ovf, carry, zero         : std_logic;

  -- This is the 4×32 bus feeding the result mux (AND, OR, XOR, ADD/SUB)
  signal bus_in : t_bus_4x32;

begin

  -- Controls and flags

  mux_control2t1 <= Alucontrol(1 downto 0);      -- selects AND/OR/XOR when add/sub not chosen
  neg            <= finalResult(WIDTH-1);
  zero <= '1' when finalResult = (finalResult'range => '0') else '0';


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


  -- Adder/Subtractor goes to bus_in(3)

  addsub : nBit_ALU
    port map(
      nAdd_Sub        => Alucontrol(2),  -- 0:add, 1:sub (per your ALU)
      input_A         => input_A,
      input_B         => input_B,
      output_Sum      => bus_in(3),
      output_Carry    => carry,
      output_Overflow => ovf
    );


  -- If Alucontrol(2)=1 → force select "11" (ADD/SUB); else lower 2 bits select logic ops

  muxBeforeResult : mux2t1_N
    generic MAP(N => 2)
    port map(
      i_S  => Alucontrol(2),
      i_D0 => mux_control2t1,  -- 00=AND, 01=OR, 10=XOR
      i_D1 => "11",            -- 11=ADD/SUB
      o_O  => mux_control4t1
    );


  -- Select final result among AND/OR/XOR/ADD(SUB)

  muxResult : mux4x32t1
    port map(
      sel      => mux_control4t1,
      bus_in   => bus_in,
      o_output => finalResult  -- WIDTH must be 32 for a direct connect
    );

  -- Drive output
  output_result <= finalResult;


  -- Flag mux: 00=NEG, 01=OVF, 10=CARRY, 11=ZERO

  u_Flag_mux : mux4t1
    port map(
      i_D0 => neg,
      i_D1 => ovf,
      i_D2 => carry,
      i_D3 => zero,
      i_S  => flag_mux,
      o_Y  => flag
    );

end architecture;
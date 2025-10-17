library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nBit_ALU is

  generic(WIDTH : integer := 32);
 
  port(nAdd_Sub		: in std_logic;
       input_A 		: in std_logic_vector(WIDTH-1 downto 0);
       input_B 		: in std_logic_vector(WIDTH-1 downto 0);
       output_Sum	: out std_logic_vector(WIDTH-1 downto 0);
       output_Carry     : out std_logic;
       output_Overflow : out std_logic
       );

end nBit_ALU;

architecture structure of nBit_ALU is
  


  component Nbit_adder is
  generic (N : integer := 32);
  port (
    i_A : in  std_logic_vector(N-1 downto 0);
    i_B : in  std_logic_vector(N-1 downto 0);
    i_C : in  std_logic;
    o_S : out std_logic_vector(N-1 downto 0);
    o_C : out std_logic
  );
end component;

  component ones_complementor
  generic (N : integer := 32);
  port (
    i_A : in  std_logic_vector(N-1 downto 0);
    o_F : out std_logic_vector(N-1 downto 0)
  );
end component;

  component mux2t1_N is
  generic (N : integer := 32);
  port (
    i_S  : in  std_logic;
    i_D0 : in  std_logic_vector(N-1 downto 0);
    i_D1 : in  std_logic_vector(N-1 downto 0);
    o_O  : out std_logic_vector(N-1 downto 0)
  );
end component;

  signal s_B_OnesComp	: std_logic_vector(WIDTH-1 downto 0);
  signal s_mux_Out	: std_logic_vector(WIDTH-1 downto 0);
  signal s_A_sign, s_B_sign, s_SignResult : std_logic;
  signal s_Overflow_Add, s_Overflow_Sub   : std_logic;
  signal s_Sum : std_logic_vector(WIDTH-1 downto 0);

begin  
  
  g_B_OnesComp: ones_complementor
    generic map (N => WIDTH)
    port MAP(	i_A	=> input_B,
		o_F	=> s_B_OnesComp);

  g_B_mux: mux2t1_N
    generic map(N => WIDTH)
    port MAP(	i_S	=> nAdd_Sub,
		i_D0	=> input_B,
		i_D1	=> s_B_OnesComp,
		o_O	=> s_mux_Out);


 g_Adder: Nbit_adder
    generic MAP(N => WIDTH)
    port MAP(
      i_A  => input_A,
      i_B  => s_mux_Out,
      i_C  => nAdd_Sub,
      o_S  => s_Sum,
      o_C  => output_Carry
    );

  s_A_sign       <= input_A(WIDTH-1);
  s_B_sign       <= s_mux_Out(WIDTH-1);
  s_SignResult   <= s_Sum(WIDTH-1);
  output_Sum <= s_Sum;

  s_Overflow_Add <= (s_A_sign and s_B_sign and (not s_SignResult)) or
                    ((not s_A_sign) and (not s_B_sign) and s_SignResult);

  s_Overflow_Sub <= (s_A_sign and (not s_B_sign) and (not s_SignResult)) or
                    ((not s_A_sign) and s_B_sign and s_SignResult);

  output_Overflow <= (s_Overflow_Add and (not nAdd_Sub)) or
                     (s_Overflow_Sub and nAdd_Sub);

end structure;
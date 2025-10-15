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
  
  component nBit_Adder
        port(in_C   	: in std_logic;
             i_A 	: in std_logic_vector(WIDTH-1 downto 0);
             i_B 	: in std_logic_vector(WIDTH-1 downto 0);
             o_SUM 	: out std_logic_vector(WIDTH-1 downto 0);
             out_C      : out std_logic);
  end component;

  component OnesComp
	port(INPUT 	: in std_logic_vector(WIDTH-1 downto 0);
             OUTPUT 	: out std_logic_vector(WIDTH-1 downto 0));    
  end component;

  component mux2t1_N
    	port(i_S        : in std_logic;
             i_D0       : in std_logic_vector(WIDTH-1 downto 0);
             i_D1       : in std_logic_vector(WIDTH-1 downto 0);
             o_O        : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  signal s_B_OnesComp	: std_logic_vector(WIDTH-1 downto 0);
  signal s_mux_Out	: std_logic_vector(WIDTH-1 downto 0);
  signal s_A_sign, s_B_sign, s_SignResult : std_logic;
  signal s_Overflow_Add, s_Overflow_Sub   : std_logic;

begin  
  
  g_B_OnesComp: OnesComp
    port MAP(	INPUT	=> input_B,
		OUTPUT	=> s_B_OnesComp);

  g_B_mux: mux2t1_N
    port MAP(	i_S	=> nAdd_Sub,
		i_D0	=> input_B,
		i_D1	=> s_B_OnesComp,
		o_O	=> s_mux_out);

  g_Adder: nBit_Adder
    port MAP(	in_C	=> nAdd_Sub,
		i_A	=> input_A,
		i_B	=> s_mux_out,
		o_SUM	=> output_Sum,
		out_C	=> output_Carry);

  s_A_sign       <= input_A(WIDTH-1);
  s_B_sign       <= s_mux_out(WIDTH-1);
  s_SignResult   <= output_Sum(WIDTH-1);

  s_Overflow_Add <= (s_A_sign and s_B_sign and (not s_SignResult)) or
                    ((not s_A_sign) and (not s_B_sign) and s_SignResult);

  s_Overflow_Sub <= (s_A_sign and (not s_B_sign) and (not s_SignResult)) or
                    ((not s_A_sign) and s_B_sign and s_SignResult);

  output_Overflow <= (s_Overflow_Add and (not nAdd_Sub)) or
                     (s_Overflow_Sub and nAdd_Sub);

end structure;
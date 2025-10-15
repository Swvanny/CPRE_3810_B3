library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use RISCV_types.all;

entity ALUUnit is
 generic (WIDTH : integer := DATA_WIDTH);
 port(
    Alucontrol    : in std_logic_vector(3 downto 0);
    flag_mux      : in std_logic_vector(1 downto 0);
    input_A       : in std_logic_vector (WIDTH-1 downto 0);
    input_B       : in std_logic_vector (WIDTH-1 downto 0);
    output_result : out std_logic_vector (WIDTH-1 downto 0);
    flag          : out std_logic
 );
 end ALUUnit;

 architecture structural of ALUUnit is

    component nBit_ALU
        port(nAdd_Sub		: in std_logic;
            input_A 		: in std_logic_vector(WIDTH-1 downto 0);
            input_B 		: in std_logic_vector(WIDTH-1 downto 0);
            output_Sum	    : out std_logic_vector(WIDTH-1 downto 0);
            output_Carry    : out std_logic;
            output_Overflow : out std_logic
            );
    end component;

    component and_32bit
        port(
            i_D0 : in std_logic_vector(WIDTH-1 downto 0);
            i_D1 : in std_logic_vector (WIDTH-1 downto 0);
            o_O  : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component xor_32bit
        port(
            i_D0 : in std_logic_vector(WIDTH-1 downto 0);
            i_D1 : in std_logic_vector (WIDTH-1 downto 0);
            o_O  : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component or_32bit
        port(
            i_D0 : in std_logic_vector(WIDTH-1 downto 0);
            i_D1 : in std_logic_vector (WIDTH-1 downto 0);
            o_O  : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component mux4x32t1 is
        port(sel        : in std_logic_vector(1 downto 0);
        bus_in		    : in t_bus_4x32;
        o_output 	    : out std_logic_vector(31 downto 0));
    end component;

    component mux2t1_N is 
        port(
            i_S          : in std_logic;
            i_D0         : in std_logic_vector(1 downto 0);
            i_D1         : in std_logic_vector(1 downto 0);
            o_O          : out std_logic_vector(1 downto 0)
            );
    end component;

    component mux4t1
        port(
            i_D0 : in std_logic;
            i_D1 : in std_logic;
            i_D2 : in std_logic;
            i_D3 : in std_logic;
            i_S  : in std_logic_vector(1 downto 0);
            o_Y  : out std_logic
        );
    end component;




    signal mux_control4t1, mux_control2t1  :std_logic_vector(1 downto 0);
    signal finalResult : std_logic_vector(WIDTH-1 downto 0);
    signal neg,ovf,carry,zero : std_logic;

    begin
        mux_control2t1 <= Alucontrol(1 downto 0);
        neg <= finalResult(31);

          andUnit : and_32bit 
          port map(
            i_D0 => input_A,
            i_D1 => input_B,
            o_O => bus_in(0)
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
        norUnit : nor_32t1bit
        port map(
        i_D => finalResult,
        o_O => zero
        );

        addsub : nBit_ALU
        port map(
            nAdd_Sub     => Alucontrol(2), 
            input_A      => input_A,
            input_B      => input_B,
            output_Sum   => bus_in(3),
            output_Carry => carry
            output_Overflow => ovf
        );

        muxbeforeresult : mux2t1_N
        port map(
            i_S => Alucontrol(2),
            i_D0 => mux_control2t1,
            i_D1 => "11",
            o_O => mux_control4t1
        );

        muxResult : mux4x32t1
        port map(
            sel      => mux_control4t1,
            bus_in   => bus_in,
            o_output => finalResult
        );

        Flag_mux: mux4t1
        port map(
            i_D0 => neg,
            i_D1 => ovf,
            i_D2 => carry,
            i_D3 => zero,
            i_S  => flag_mux,
            o_Y => flag
        );













library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goblinBarrel is
    port (
        data_in  : in  std_logic_vector(31 downto 0);
        shift_in : in std_logic_vector(2 downto 0);
        shift_left_right : in std_logic_vector(1 downto 0); -- 00 = SLL, 01 = SRL, 10 = SRA
        shift_amount : in std_logic_vector(4 downto 0);
        data_out : out std_logic_vector(31 downto 0)

    );
end entity goblinBarrel;

architecture Behavioral of goblinBarrel is
component mux2t1_N
generic(N : integer := 32); 
  port(
        i_S          : in std_logic;
       i_X0         : in std_logic_vector(N-1 downto 0);
       i_X1         : in std_logic_vector(N-1 downto 0);
       o_X          : out std_logic_vector(N-1 downto 0));

end component;

signal shift_LR : std_logic;
signal stage_0, stage_1, stage_2, stage_3, stage_4 : std_logic_vector(31 downto 0);
signal sign_bit : std_logic;
signal in0, in1, in2, in3, in4 : STD_LOGIC_VECTOR(31 downto 0);
signal shift1, shift2, shift4, shift8, shift16 : STD_LOGIC_VECTOR(31 downto 0);



begin
    shift_LR <= shift_left_right(1);
    sign_bit <= data_in(31);


    shift1 <= 
    --SLL
    in0(30 downto 0) & '0' when shift_left_right = "00" else
    --SRL
    '0' & in0(31 downto 1) when shift_left_right = "01" else
    --SRA
    sign_bit & in0(31 downto 1);

    mux0: mux2t1_N 
    port map( 
        i_S => shift_amount(0),
        i_X0 => in0,
        i_X1 => shift1,
        o_X => stage_0
    );

    in1 <= stage_0;

-- CHANGE SHIFT_LEFT_RIGHT TO ACTUAL CONTROL VALUES LATER

    shift2 <= 
    --SLL
    in1(29 downto 0) & "00" when shift_left_right = "00" else
    --SRL
    "00" & in1(31 downto 2) when shift_left_right = "01" else
    --SRA
    (others => sign_bit)(1 downto 0 ) & in1(31 downto 2);

    mux1: mux2t1_N 
    port map( 
        i_S => shift_amount(1),
        i_X0 => in1,
        i_X1 => shift2,
        o_X => stage_1
    );

    in2 <= stage_1;



    shift4 <=
        in2(27 downto 0) & "0000" when shift_left_right = "00" else
        "0000" & in2(31 downto 4) when shift_left_right = "01" else
        (others => sign_bit)(3 downto 0) & in2(31 downto 4);

    mux2: mux2t1_N port map (
        i_S => shift_amount(2),
        i_X0   => in2,
        i_X1   => shift4,
        o_X   => stage_2
    );

  
    in3 <= stage_2;



    shift8 <=
        in3(23 downto 0) & X"00" when shift_left_right = "00" else
        X"00" & in3(31 downto 8) when shift_left_right = "01" else
        (others => sign_bit)(7 downto 0) & in3(31 downto 8);

    mux3: mux2t1_N port map (
        i_S => shift_amount(3),
        i_X0   => in3,
        i_X1   => shift8,
        o_X   => stage_3
    );

   
    in4 <= stage_3;



    shift16 <=
        in4(15 downto 0) & X"0000" when shift_left_right = "00" else
        X"0000" & in4(31 downto 16) when shift_left_right = "01" else
        (others => sign_bit)(15 downto 0) & in4(31 downto 16);

    MUX4: mux2_32 port map (
        i_S => shift_amount(4),
        i_X0   => in4,
        i_X1   => shift16,
        o_X   => stage_4
    );

    data_out <= stage_4;


end architecture Behavioral;



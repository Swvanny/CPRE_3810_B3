library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity goblinBarrel is
    port (
        data_in           : in  std_logic_vector(31 downto 0);
        shift_left_right  : in  std_logic_vector(3 downto 0); -- 00 = SLL, 01 = SRL, 10 = SRA
        shift_amount      : in  std_logic_vector(4 downto 0);
        data_out          : out std_logic_vector(31 downto 0)
    );
end entity goblinBarrel;

architecture Behavioral of goblinBarrel is


    component mux2t1_N
        generic(N : integer := 32); 
        port(
            i_S  : in  std_logic;
            i_X0 : in  std_logic_vector(N-1 downto 0);
            i_X1 : in  std_logic_vector(N-1 downto 0);
            o_X  : out std_logic_vector(N-1 downto 0)
        );
    end component;


    signal shift_LR : std_logic;
    signal sign_bit : std_logic;
    
    signal stage_0, stage_1, stage_2, stage_3, stage_4 : std_logic_vector(31 downto 0);
    signal in0, in1, in2, in3, in4 : std_logic_vector(31 downto 0);
    
    signal shift1, shift2, shift4, shift8, shift16 : std_logic_vector(31 downto 0);


    signal sign_extend_2   : std_logic_vector(1 downto 0);
    signal sign_extend_4   : std_logic_vector(3 downto 0);
    signal sign_extend_8   : std_logic_vector(7 downto 0);
    signal sign_extend_16  : std_logic_vector(15 downto 0);

begin


    shift_LR  <= shift_left_right(1);
    sign_bit  <= data_in(31);
    in0       <= data_in;


    sign_extend_2  <= (others => sign_bit);
    sign_extend_4  <= (others => sign_bit);
    sign_extend_8  <= (others => sign_bit);
    sign_extend_16 <= (others => sign_bit);

   
    shift1 <=
        -- SLL
        in0(30 downto 0) & '0' when shift_left_right = "0111" else
        -- SRL
        '0' & in0(31 downto 1) when shift_left_right = "0101" else
        -- SRA
        sign_bit & in0(31 downto 1) when shift_left_right = "0110" else; 

    mux0: mux2t1_N
        generic map(N => 32)
        port map(
            i_S  => shift_amount(0),
            i_X0 => in0,
            i_X1 => shift1,
            o_X  => stage_0
        );

    in1 <= stage_0;

    
    shift2 <=
        in1(29 downto 0) & "00" when shift_left_right = "0111" else
        "00" & in1(31 downto 2) when shift_left_right = "0101" else
        sign_extend_2 & in1(31 downto 2) when shift_left_right = "0110" else;

    mux1: mux2t1_N
        generic map(N => 32)
        port map(
            i_S  => shift_amount(1),
            i_X0 => in1,
            i_X1 => shift2,
            o_X  => stage_1
        );

    in2 <= stage_1;

    
    shift4 <=
        in2(27 downto 0) & "0000" when shift_left_right = "0111" else
        "0000" & in2(31 downto 4) when shift_left_right = "0101" else
        sign_extend_4 & in2(31 downto 4) when shift_left_right = "0110" else;

    mux2: mux2t1_N
        generic map(N => 32)
        port map(
            i_S  => shift_amount(2),
            i_X0 => in2,
            i_X1 => shift4,
            o_X  => stage_2
        );

    in3 <= stage_2;

    
    shift8 <=
        in3(23 downto 0) & x"00" when shift_left_right = "0110" else
        x"00" & in3(31 downto 8) when shift_left_right = "0101" else
        sign_extend_8 & in3(31 downto 8) when shift_left_right = "0110" else;

    mux3: mux2t1_N
        generic map(N => 32)
        port map(
            i_S  => shift_amount(3),
            i_X0 => in3,
            i_X1 => shift8,
            o_X  => stage_3
        );

    in4 <= stage_3;

   
    shift16 <=
        in4(15 downto 0) & x"0000" when shift_left_right = "0110" else
        x"0000" & in4(31 downto 16) when shift_left_right = "0101" else
        sign_extend_16 & in4(31 downto 16) when shift_left_right = "0110" else;

    mux4: mux2t1_N
        generic map(N => 32)
        port map(
            i_S  => shift_amount(4),
            i_X0 => in4,
            i_X1 => shift16,
            o_X  => stage_4
        );

    
    data_out <= stage_4;

end architecture Behavioral;
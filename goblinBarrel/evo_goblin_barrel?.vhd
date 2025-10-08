library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goblinBarrel is
    port (
        data_in          : in  std_logic_vector(31 downto 0);
        shift_left_right : in  std_logic_vector(1 downto 0); -- "00"=SLL, "01"=SRL, "10"=SRA
        shift_amount     : in  std_logic_vector(4 downto 0); -- RV32 uses 5 LSBs
        data_out         : out std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioral of goblinBarrel is
  component mux2t1_N
    generic ( N : integer := 32 );
    port (
      i_S  : in  std_logic;
      i_X0 : in  std_logic_vector(N-1 downto 0);
      i_X1 : in  std_logic_vector(N-1 downto 0);
      o_X  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  signal sign_bit                                         : std_logic;
  signal in0, in1, in2, in3, in4                          : std_logic_vector(31 downto 0);
  signal stage_0, stage_1, stage_2, stage_3, stage_4      : std_logic_vector(31 downto 0);
  signal shift1, shift2, shift4, shift8, shift16          : std_logic_vector(31 downto 0);

begin
  -- Inputs
  in0      <= data_in;
  sign_bit <= data_in(31);

  -----------------------------------------------------------------------------
  -- 1-bit stage
  -----------------------------------------------------------------------------
  shift1 <=
    -- SLL 1
    in0(30 downto 0) & '0'                          when shift_left_right = "00" else
    -- SRL 1
    '0' & in0(31 downto 1)                          when shift_left_right = "01" else
    -- SRA 1
    sign_bit & in0(31 downto 1);

  mux0 : mux2t1_N
    port map (
      i_S  => shift_amount(0),
      i_X0 => in0,
      i_X1 => shift1,
      o_X  => stage_0
    );

  in1 <= stage_0;

  -----------------------------------------------------------------------------
  -- 2-bit stage
  -----------------------------------------------------------------------------
  shift2 <=
    -- SLL 2
    in1(29 downto 0) & "00"                          when shift_left_right = "00" else
    -- SRL 2
    "00" & in1(31 downto 2)                          when shift_left_right = "01" else
    -- SRA 2
    (1 downto 0 => sign_bit) & in1(31 downto 2);

  mux1 : mux2t1_N
    port map (
      i_S  => shift_amount(1),
      i_X0 => in1,
      i_X1 => shift2,
      o_X  => stage_1
    );

  in2 <= stage_1;

  -----------------------------------------------------------------------------
  -- 4-bit stage
  -----------------------------------------------------------------------------
  shift4 <=
    -- SLL 4
    in2(27 downto 0) & x"0"                           when shift_left_right = "00" else
    -- SRL 4
    x"0" & in2(31 downto 4)                           when shift_left_right = "01" else
    -- SRA 4
    (3 downto 0 => sign_bit) & in2(31 downto 4);

  mux2 : mux2t1_N
    port map (
      i_S  => shift_amount(2),
      i_X0 => in2,
      i_X1 => shift4,
      o_X  => stage_2
    );

  in3 <= stage_2;

  -----------------------------------------------------------------------------
  -- 8-bit stage
  -----------------------------------------------------------------------------
  shift8 <=
    -- SLL 8
    in3(23 downto 0) & x"00"                          when shift_left_right = "00" else
    -- SRL 8
    x"00" & in3(31 downto 8)                          when shift_left_right = "01" else
    -- SRA 8
    (7 downto 0 => sign_bit) & in3(31 downto 8);

  mux3 : mux2t1_N
    port map (
      i_S  => shift_amount(3),
      i_X0 => in3,
      i_X1 => shift8,
      o_X  => stage_3
    );

  in4 <= stage_3;

  -----------------------------------------------------------------------------
  -- 16-bit stage
  -----------------------------------------------------------------------------
  shift16 <=
    -- SLL 16
    in4(15 downto 0) & x"0000"                        when shift_left_right = "00" else
    -- SRL 16
    x"0000" & in4(31 downto 16)                       when shift_left_right = "01" else
    -- SRA 16
    (15 downto 0 => sign_bit) & in4(31 downto 16);

  mux4 : mux2t1_N
    port map (
      i_S  => shift_amount(4),
      i_X0 => in4,
      i_X1 => shift16,
      o_X  => stage_4
    );

  data_out <= stage_4;

end architecture Behavioral;
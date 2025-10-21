library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nBit_ALU is
  port(
    nAdd_Sub        : in  std_logic;                           -- 0: ADD, 1: SUB (A + (~B) + 1)
    input_A         : in  std_logic_vector(31 downto 0);
    input_B         : in  std_logic_vector(31 downto 0);
    output_Sum      : out std_logic_vector(31 downto 0);
    flag_Z          : out std_logic;                           -- Zero flag
    flag_N          : out std_logic;                           -- Negative flag
    flag_C          : out std_logic;                           -- Carry (SUB: 1 = no-borrow)
    flag_V          : out std_logic                            -- Overflow flag
  );
end entity nBit_ALU;

architecture rtl of nBit_ALU is
  -- Effective B for add/sub: B_eff = B xor (nAdd_Sub replicated)
  signal B_eff         : std_logic_vector(31 downto 0);
  signal nAdd_Sub_vec  : std_logic_vector(31 downto 0);

  -- 33-bit addition for carry-out
  signal A_ext, B_ext, Sum_ext : unsigned(32 downto 0);
  signal Cin_ext               : unsigned(32 downto 0);

  -- Sign bits for overflow detection
  signal sA, sB_eff, sR : std_logic;

  -- Pre-made constants to avoid aggregate-in-operator issues
  constant ZERO32 : std_logic_vector(31 downto 0) := (others => '0');
  constant ZERO33 : unsigned(32 downto 0)         := (others => '0');
  constant ONE33C0: unsigned(32 downto 0)         := (0 => '1', others => '0'); -- add +1 on LSB
begin
  -- Replicate control bit into a vector first (avoids vcom-1389 on xor)
  nAdd_Sub_vec <= (others => nAdd_Sub);
  B_eff        <= input_B xor nAdd_Sub_vec;

  A_ext <= '0' & unsigned(input_A);
  B_ext <= '0' & unsigned(B_eff);

  -- Avoid aggregate literal directly in a conditional operator context
  Cin_ext <= ZERO33  when nAdd_Sub = '0' else
             ONE33C0;

  -- Perform addition/subtraction
  Sum_ext     <= A_ext + B_ext + Cin_ext;
  output_Sum  <= std_logic_vector(Sum_ext(31 downto 0));

  -- Carry / Borrow logic (for SUB: carry=1 means no borrow)
  flag_C <= Sum_ext(32);

  -- Overflow detection
  sA     <= input_A(31);
  sB_eff <= input_B(31) xor nAdd_Sub;  -- effective sign of B after optional inversion
  sR     <= output_Sum(31);
  flag_V <= ( sA and  sB_eff and (not sR)) or
            ((not sA) and (not sB_eff) and sR);

  -- Zero / Negative flags (avoid aggregate literal in '=')
  flag_Z <= '1' when output_Sum = ZERO32 else '0';
  flag_N <= output_Sum(31);
end architecture rtl;


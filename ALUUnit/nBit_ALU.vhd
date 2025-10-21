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
  signal B_eff   : std_logic_vector(31 downto 0);

  -- 33-bit addition for carry-out
  signal A_ext, B_ext, Sum_ext : unsigned(32 downto 0);
  signal Cin_ext               : unsigned(32 downto 0);

  -- Sign bits for overflow detection
  signal sA, sB_eff, sR : std_logic;
begin
  
  -- Form effective operands
  
  B_eff <= input_B xor (31 downto 0 => nAdd_Sub);

  A_ext <= '0' & unsigned(input_A);
  B_ext <= '0' & unsigned(B_eff);

  with nAdd_Sub select
    Cin_ext <= (others => '0')           when '0',
               (0 => '1', others => '0') when others;

  
  -- Perform addition/subtraction
  
  Sum_ext     <= A_ext + B_ext + Cin_ext;
  output_Sum  <= std_logic_vector(Sum_ext(31 downto 0));

  
  -- Carry / Borrow logic
  -- For subtraction: carry=1 means no borrow (standard convention)
  
  flag_C <= Sum_ext(32);

  
  -- Overflow detection (same formula works for ADD and SUB)
  
  sA     <= input_A(31);
  sB_eff <= input_B(31) xor nAdd_Sub;  -- flips for subtraction
  sR     <= output_Sum(31);

  flag_V <= ( sA and  sB_eff and (not sR)) or
            ((not sA) and (not sB_eff) and sR);

  
  -- Zero and Negative flags
  
  flag_Z <= '1' when output_Sum = (others => '0') else '0';
  flag_N <= output_Sum(31);

end architecture rtl;
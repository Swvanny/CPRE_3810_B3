library IEEE;
use IEEE.std_logic_1164.all;

entity mux4t1 is
    port(
        i_D0 : in std_logic;
        i_D1 : in std_logic;
        i_D2 : in std_logic;
        i_D3 : in std_logic;
        i_S  : in std_logic_vector(1 downto 0);
        o_Y  : out std_logic
    );
end mux4t1;

architecture structural of mux4t1 is

    -- Gate components
    component invg
        port(i_A : in std_logic;
             o_F : out std_logic);
    end component;

    component andg2
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    component org2
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    -- Internal signals
    signal s0_bar, s1_bar : std_logic;
    signal a0, a1, a2, a3 : std_logic;
    signal o_low, o_high  : std_logic;

    -- New intermediate signals for selector logic
    signal s00, s01, s10, s11 : std_logic;

begin

    -- Invert select bits
    U_INV0: invg port map(i_A => i_S(0), o_F => s0_bar);
    U_INV1: invg port map(i_A => i_S(1), o_F => s1_bar);

    -- Evaluate selection logic
    s00 <= s1_bar and s0_bar;
    s01 <= s1_bar and i_S(0);
    s10 <= i_S(1) and s0_bar;
    s11 <= i_S(1) and i_S(0);

    -- AND gates for selecting input
    U_AND0: andg2 port map(i_A => i_D0, i_B => s00, o_F => a0);
    U_AND1: andg2 port map(i_A => i_D1, i_B => s01, o_F => a1);
    U_AND2: andg2 port map(i_A => i_D2, i_B => s10, o_F => a2);
    U_AND3: andg2 port map(i_A => i_D3, i_B => s11, o_F => a3);

    -- Combine selected inputs
    U_OR0: org2 port map(i_A => a0, i_B => a1, o_F => o_low);
    U_OR1: org2 port map(i_A => a2, i_B => a3, o_F => o_high);
    U_OR2: org2 port map(i_A => o_low, i_B => o_high, o_F => o_Y);

end structural;
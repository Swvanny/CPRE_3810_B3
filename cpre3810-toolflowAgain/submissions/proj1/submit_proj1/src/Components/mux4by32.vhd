library IEEE;
use IEEE.std_logic_1164.all;

entity mux4t1_32 is
  port(
    i_S  : in  std_logic_vector(1 downto 0);  -- 2-bit select line
    i_X0 : in  std_logic_vector(31 downto 0); -- Input 0
    i_X1 : in  std_logic_vector(31 downto 0); -- Input 1
    i_X2 : in  std_logic_vector(31 downto 0); -- Input 2
    i_X3 : in  std_logic_vector(31 downto 0); -- Input 3
    o_X  : out std_logic_vector(31 downto 0)  -- Output
  );
end mux4t1_32;

architecture structural of mux4t1_32 is

  -----------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------

  component andg2 is
    port(i_A, i_B : in std_logic;
         o_F      : out std_logic);
  end component;

  component org2 is
    port(i_A, i_B : in std_logic;
         o_F      : out std_logic);
  end component;

  component invg is
    port(i_A : in std_logic;
         o_F : out std_logic);
  end component;


  -----------------------------------------------------------------------
  -- Internal control and data signals
  -----------------------------------------------------------------------

  -- Inverted select signals
  signal s_S0_bar, s_S1_bar : std_logic;

  -- Select line combinations
  signal s_sel0, s_sel1, s_sel2, s_sel3 : std_logic;

  -- Intermediate and/or outputs
  signal s_and0, s_and1, s_and2, s_and3 : std_logic_vector(31 downto 0);
  signal s_or0, s_or1 : std_logic_vector(31 downto 0);

begin

  -----------------------------------------------------------------------
  -- Invert select lines
  -----------------------------------------------------------------------

  INV_S0: invg port map(i_A => i_S(0), o_F => s_S0_bar);
  INV_S1: invg port map(i_A => i_S(1), o_F => s_S1_bar);

  -----------------------------------------------------------------------
  -- Decode select combinations
  -- sel0 = ¬S1 · ¬S0
  -- sel1 = ¬S1 ·  S0
  -- sel2 =  S1 · ¬S0
  -- sel3 =  S1 ·  S0
  -----------------------------------------------------------------------

  AND_SEL0: andg2 port map(i_A => s_S1_bar, i_B => s_S0_bar, o_F => s_sel0);
  AND_SEL1: andg2 port map(i_A => s_S1_bar, i_B => i_S(0),    o_F => s_sel1);
  AND_SEL2: andg2 port map(i_A => i_S(1),    i_B => s_S0_bar, o_F => s_sel2);
  AND_SEL3: andg2 port map(i_A => i_S(1),    i_B => i_S(0),    o_F => s_sel3);


  -----------------------------------------------------------------------
  -- Bitwise logic for 32-bit bus
  -----------------------------------------------------------------------

  G_MUX_BITS: for i in 0 to 31 generate
    -- Input AND gates
    AND0: andg2 port map(i_A => i_X0(i), i_B => s_sel0, o_F => s_and0(i));
    AND1: andg2 port map(i_A => i_X1(i), i_B => s_sel1, o_F => s_and1(i));
    AND2: andg2 port map(i_A => i_X2(i), i_B => s_sel2, o_F => s_and2(i));
    AND3: andg2 port map(i_A => i_X3(i), i_B => s_sel3, o_F => s_and3(i));

    -- Combine results using OR gates
    ORA: org2 port map(i_A => s_and0(i), i_B => s_and1(i), o_F => s_or0(i));
    ORB: org2 port map(i_A => s_and2(i), i_B => s_and3(i), o_F => s_or1(i));
    ORC: org2 port map(i_A => s_or0(i),  i_B => s_or1(i),  o_F => o_X(i));
  end generate G_MUX_BITS;

end structural;
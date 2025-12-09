library ieee;
use ieee.std_logic_1164.all;

entity PipelineRegister_logic_Flush is
  port(
    i_CLK   : in std_logic;
    i_RST   : in std_logic;
    i_WE    : in std_logic;    -- write enable
    i_FLUSH : in std_logic;    -- synchronous flush (bubble)
    i_D     : in std_logic;    -- data in
    o_Q     : out std_logic    -- data out
  );
end entity;

architecture Structural of PipelineRegister_logic_Flush is

  component falling_dffg is
    port(
      i_CLK : in std_logic;
      i_RST : in std_logic;
      i_WE  : in std_logic;
      i_D   : in std_logic;
      o_Q   : out std_logic
    );
  end component;

  component mux2t1 is
    port(
      i_S  : in std_logic;
      i_X0 : in std_logic;
      i_X1 : in std_logic;
      o_X  : out std_logic
    );
  end component;

  signal s_D_muxed : std_logic;
    signal s_WE_eff  : std_logic;

begin


  MUX_FLUSH: mux2t1
    port map(
      i_S  => i_FLUSH,  -- when '1', select bubble
      i_X0 => i_D,      -- normal data
      i_X1 => '0',      -- bubble = 0
      o_X  => s_D_muxed
    );

  s_WE_eff <= i_WE or i_FLUSH;

  DFF: falling_dffg
    port map(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => s_WE_eff,
      i_D   => s_D_muxed,
      o_Q   => o_Q
    );

end architecture Structural;

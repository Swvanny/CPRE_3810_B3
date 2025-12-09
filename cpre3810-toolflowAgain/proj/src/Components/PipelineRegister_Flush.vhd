library IEEE;
use IEEE.std_logic_1164.all;

entity PipelineRegister_Flush is
    generic (
        N : integer := 32
    );
    port(
        i_CLK   : in std_logic;
        i_RST   : in std_logic;
        i_WE    : in std_logic;
        i_FLUSH : in std_logic;  
        i_D     : in std_logic_vector(N-1 downto 0);
        o_Q     : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture Structural of PipelineRegister_Flush is

    signal s_zero    : std_logic_vector(N-1 downto 0);
    signal s_D_muxed : std_logic_vector(N-1 downto 0);
      signal s_WE_eff  : std_logic;

    component PipelineRegister is
        generic (N : integer := 32);
        port(
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE  : in std_logic;
            i_D   : in std_logic_vector(N-1 downto 0);
            o_Q   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component mux2t1_N is
      generic(N : integer := 32);
      port(i_S  : in std_logic;
           i_X0 : in std_logic_vector(N-1 downto 0);
           i_X1 : in std_logic_vector(N-1 downto 0);
           o_X  : out std_logic_vector(N-1 downto 0));
    end component;

begin

    -- A zero vector for bubbling (NOP)
    s_zero <= (others => '0');

    -- Choose between normal data and zero-bubble based on flush
    MUX_FLUSH: mux2t1_N
        generic map(N => N)
        port map(
            i_S  => i_FLUSH,
            i_X0 => i_D,
            i_X1 => s_zero,
            o_X  => s_D_muxed
        );

  s_WE_eff <= i_WE or i_FLUSH;

    -- Actual pipeline register storage (reuses your existing PipelineRegister)
    PIPE: PipelineRegister
        generic map(N => N)
        port map(
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => s_WE_eff,
            i_D   => s_D_muxed,
            o_Q   => o_Q
        );

end Structural;

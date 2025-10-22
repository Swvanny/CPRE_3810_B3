library IEEE;
use IEEE.std_logic_1164.all;

entity adder_subtractor is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       i_A1         : in std_logic_vector(N-1 downto 0);
       i_B1          : in std_logic_vector(N-1 downto 0);
       i_AddSub     : in std_logic;
       i_CAS           : in std_logic;
       o_CAS           : out std_logic;  
       o_SAS           : out std_logic_vector(N-1 downto 0)
  );
end adder_subtractor;

architecture structural of adder_subtractor is 
component Nbit_adder
    generic(N : integer := 32);
    port(
      i_A  : in std_logic_vector(N-1 downto 0);
      i_B  : in std_logic_vector(N-1 downto 0);
      i_C  : in std_logic;
      o_S  : out std_logic_vector(N-1 downto 0);
      o_C  : out std_logic
    );
  end component;

  component onescomp is
    generic(N : integer := 32);
    port(
      i_D0 : in std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component mux2t1_N is
    generic(N : integer := 32);
    port(i_S  : in std_logic;
         i_X0 : in std_logic_vector(N-1 downto 0);
         i_X1 : in std_logic_vector(N-1 downto 0);
         o_X  : out std_logic_vector(N-1 downto 0));
  end component;
  
  signal onescomp_out : std_logic_vector(N-1 downto 0);
  signal mux2_out : std_logic_vector(N-1 downto 0);
  signal mux2_in1 : std_logic_vector(N-1 downto 0);
signal carry : std_logic_vector(N downto 0);  

begin

  
--  carry(0) <= i_C;

  onescomp_inst: onescomp
    generic map(N => N)
      port map(
        i_D0 => i_B1,
        o_O => mux2_in1
      );


  mux_inst: mux2t1_N
    generic map(N => N)
      port map(
        i_S => i_AddSub,
        i_X0 => i_B1,
        i_X1 => mux2_in1,
        o_X => mux2_out
      );
  

  adder_inst: Nbit_adder
    generic map(N => N)
      port map(
        i_A => i_A1,
         i_B => mux2_out,
         i_C => i_CAS,
         o_C => o_CAS,
         o_S => o_SAS
      );
  

  --o_C <= carry(N);

        
        end structural;
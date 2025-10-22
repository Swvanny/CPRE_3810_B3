library IEEE;
use IEEE.std_logic_1164.all;

entity and_32bit is
    generic(WIDTH :integer := 32);
    port(
       i_D0 : in std_logic_vector(WIDTH-1 downto 0);
       i_D1 : in std_logic_vector (WIDTH-1 downto 0);
       o_O : out std_logic_vector(WIDTH-1 downto 0)
    );
end and_32bit;


architecture structural of and_32bit is
    component andg2
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    begin
        G1:for i in 0 to WIDTH-1 generate
        U_AND: andg2
        port map (
            i_A => i_D0(i),
            i_B => i_D1(i),
            o_F => o_O(i)
        );
    end generate G1;
end structural;
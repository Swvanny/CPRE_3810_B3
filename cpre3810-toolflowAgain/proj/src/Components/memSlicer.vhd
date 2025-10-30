library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memSlicer is
port (
    funct3 : in std_logic_vector(2 downto 0);
    addr : in std_logic_vector(1 downto 0);
    input : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0));

end memSlicer;

architecture Behavioral of memorySlicer is
    signal lb, lbu : std_logic_vector(7 downto 0);
    signal lh, lhu : std_logic_vector(15 downto 0);
    signal extlb, extlbu, extlh, extlhu : std_logic_vector(31 downto 0);

begin
    lb <= input(7 downto 0) when addr = "00" else
        input(15 downto 8) when addr = "01" else
        input(23 downto 16) when addr = "10" else
        input(31 downto 24);
    lbu <= input(7 downto 0) when addr = "00" else
        input(15 downto 8) when addr = "01" else
        input(23 downto 16) when addr = "10" else
        input(31 downto 24);
-- Halfword selection based on address bit 1 (addr[1])
    lh <= input(15 downto 0) when addr(1) = '0' else
        input(31 downto 16);
    lhu <= input(15 downto 0) when addr(1) = '0' else
        input(31 downto 16);

extlb <= std_logic_vector(resize(signed(lb), 32));
extlbu <= std_logic_vector(resize(unsigned(lbu), 32));
extlh <= std_logic_vector(resize(signed(lh), 32));
extlhu <= std_logic_vector(resize(unsigned(lhu), 32));


    output <= input when funct3 = "010" else
        extlb when funct3 = "000" else
        extlbu when funct3 = "100" else
        extlh when funct3 = "001" else
        extlhu when funct3 = "101" else
        input;
end architecture Behavioral;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_types.all;

entity barrel_shifter is
    generic(WIDTH : integer := DATA_WIDTH);

    port(
        input       : in std_logic_vector(WIDTH - 1 downto 0);
        shiftAmount : in std_logic_vector(WIDTH - 1 downto 0);
        ALUControl  : in std_logic_vector(3 downto 0);
        output      : out std_logic_vector(WIDTH - 1 downto 0)
    );
end barrel_shifter;

architecture dataflow of barrel_shifter is
    signal shiftLeftLog    : unsigned(WIDTH - 1 downto 0);
    signal shiftRightLog   : unsigned(WIDTH - 1 downto 0);
    signal shiftRightArith : signed(WIDTH - 1 downto 0);
    signal controlSlicer          : std_logic_vector(1 downto 0);

    begin

    controlSlicer <= ALUControl(1 downto 0);
    shiftLeftLog <= shift_left(unsigned(input), to_integer(unsigned(shiftAmount)));
    shiftRightLog <= shift_right(unsigned(input), to_integer(unsigned(shiftAmount)));
    shiftRightArith <= shift_right(signed(input), to_integer(unsigned(shiftAmount)));

    output <= std_logic_vector(shiftLeftLog) when (controlSlicer = "11") else
              std_logic_vector(shiftRightLog) when (controlSlicer = "01") else
              std_logic_vector(shiftRightArith) when (controlSlicer = "10") else
              input;
end dataflow;

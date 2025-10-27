library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_types.all;

entity bitExtender is
  port (
    data_in  : in  std_logic_vector(31 downto 0);  
    ctrl     : in  std_logic_vector(6 downto 0);   -- opcode from instruction
    data_out : out std_logic_vector(31 downto 0)
  );
end entity;

architecture Behavioral of bitExtender is
  constant OP_I_Type  : std_logic_vector(6 downto 0) := "0010011";
  constant OP_R_Type  : std_logic_vector(6 downto 0) := "0110011";
  constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
  constant OP_STORE   : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";
  constant OP_HALT    : std_logic_vector(6 downto 0) := "1110011";

  signal concatI, concatS : std_logic_vector(11 downto 0);

  signal concatSB         : std_logic_vector(12 downto 0);

  signal concatU          : std_logic_vector(19 downto 0);

  signal concatJ          : std_logic_vector(20 downto 0);

  signal outIType, outSType, outSBType, outUType, outJType, outAUIPC, shiftedAUIPC : std_logic_vector(31 downto 0);

begin


  concatI <= data_in(31 downto 20);

  concatS <= data_in(31 downto 25) & data_in(11 downto 7);

  concatSB <= data_in(31) & data_in(7) & data_in(30 downto 25) & data_in(11 downto 8) & '0';

  concatU <= data_in(31 downto 12);

  concatJ <= data_in(31) & data_in(19 downto 12) & data_in(20) & data_in(30 downto 21) & '0';

  outItype <= std_logic_vector(resize(signed(concatI), 32));
  outStype <= std_logic_vector(resize(signed(concatS), 32));
  outSBtype <= std_logic_vector(resize(signed(concatSB), 32));
  outUtype <= concatU & x"000";
  outJtype <= std_logic_vector(resize(signed(concatJ), 32));
  outAUIPC <= std_logic_vector(resize(signed(concatU), 32));

  shiftedAUIPC <= std_logic_vector(shift_left(signed(outAUIPC), 12));

  data_out <= outItype when (data_in(6 downto 0) = OP_I_Type or
                             data_in(6 downto 0) = OP_LOAD   or
                             data_in(6 downto 0) = OP_JALR)  else
              outStype when (data_in(6 downto 0) = OP_STORE) else
              outSBtype when (data_in(6 downto 0) = OP_BRANCH) else
              outUtype when (data_in(6 downto 0) = OP_LUI) else
              shiftedAUIPC when (data_in(6 downto 0) = OP_AUIPC) else
              x"00000000";

end architecture Behavioral;
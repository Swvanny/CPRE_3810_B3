library ieee;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;

entity bitExtender is
  port (
    data_in  : in  std_logic_vector(19 downto 0);  -- up to 20 bits pre-packed immediate
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
begin
  -- Select immediate type by opcode
  with ctrl select
    data_out <=
      -- I-type, Load, JALR: sign-extend 12 bits
      ((31 downto 12 => data_in(11)) & data_in(11 downto 0)) when OP_I_Type,
      ((31 downto 12 => data_in(11)) & data_in(11 downto 0)) when OP_LOAD,
      ((31 downto 12 => data_in(11)) & data_in(11 downto 0)) when OP_JALR,

      -- S-type (store): sign-extend 12 bits
      ((31 downto 12 => data_in(11)) & data_in(11 downto 0)) when OP_STORE,

      -- B-type (branch): sign-extend 12 bits (branch offset prepacked & bit0=0)
      ((31 downto 12 => data_in(11)) & data_in(11 downto 0)) when OP_BRANCH,

      -- U-type (LUI/AUIPC): 20-bit upper immediate shifted left 12
      (data_in & (11 downto 0 => '0')) when OP_LUI,
      (data_in & (11 downto 0 => '0')) when OP_AUIPC,

      -- J-type (JAL): sign-extend 20-bit + bit0=0
      ((31 downto 20 => data_in(19)) & data_in(19 downto 0)) when OP_JAL,

      -- R-type and HALT: no immediate
      (others => '0') when OP_R_Type,
      (others => '0') when OP_HALT,

      -- Default case (to avoid latch inference)
      (others => '0') when others;
end architecture Behavioral;
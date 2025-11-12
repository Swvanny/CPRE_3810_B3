library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.reg_array.all;


entity full_reg_file is
    port(
        i_data_in : in std_logic_vector(31 downto 0);
        i_write_addr : in std_logic_vector(4 downto 0);
        i_clk : in std_logic;
        i_write_en : in std_logic;
        i_rs1 : in std_logic_vector(4 downto 0);
        i_rs2 : in std_logic_vector(4 downto 0);

        o_rs1 : out std_logic_vector(31 downto 0);
        o_rs2 : out std_logic_vector(31 downto 0)
    );
end full_reg_file;

architecture structural of full_reg_file is

    component decoder5to32 is
        port(
            i_sel : in std_logic_vector(4 downto 0);
            i_en : in std_logic;
            o_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_32by32 is
    port(
        sel : in std_logic_vector(4 downto 0);
        data_in : in reg_array;
        data_out : out std_logic_vector(31 downto 0)
    );
end component;

component Nbit_reg is
  generic ( N : integer := 32 );                 -- register width
  port (
    i_CLK : in  std_logic;                       -- clock
    i_RST : in  std_logic;                       -- async active-high reset
    i_WE  : in  std_logic;                       -- write enable (applies to all bits)
    i_DataIn   : in  std_logic_vector(N-1 downto 0);  -- data in
    o_DataOut   : out std_logic_vector(N-1 downto 0)   -- data out
  );
end component Nbit_reg;

signal we_lines : std_logic_vector(31 downto 0);
signal reg_data : reg_array;

begin   
    decoder_inst: decoder5to32
        port map(
            i_sel => i_write_addr,
            i_en => i_write_en,
            o_out => we_lines
        );

        we_lines(0) <= '0';

    gen_regs: for i in 0 to 31 generate
        reg_inst : Nbit_reg
        generic map(N => 32)
        port map(
            i_CLK => i_clk,
            i_RST => '0',
            i_WE => we_lines(i),
            i_DataIn => i_data_in,
            o_DataOut => reg_data(i)
        );
    end generate;

    rs1_mux : mux_32by32
    port map(
        sel => i_rs1,
        data_in => reg_data,
        data_out => o_rs1
    );

    rs2_mux : mux_32by32
    port map(
        sel => i_rs2,
        data_in => reg_data,
        data_out => o_rs2
    );
end structural;
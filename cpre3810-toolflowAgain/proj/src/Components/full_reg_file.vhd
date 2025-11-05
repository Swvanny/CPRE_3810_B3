library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.reg_array.all;

entity full_reg_file is
    port(
        i_data_in   : in  std_logic_vector(31 downto 0);
        i_write_addr: in  std_logic_vector(4 downto 0);
        i_RST       : in  std_logic;
        i_clk       : in  std_logic;
        i_write_en  : in  std_logic;
        i_rs1       : in  std_logic_vector(4 downto 0);
        i_rs2       : in  std_logic_vector(4 downto 0);
        o_rs1       : out std_logic_vector(31 downto 0);
        o_rs2       : out std_logic_vector(31 downto 0)
    );
end full_reg_file;

architecture structural of full_reg_file is
    component decoder5to32 is
        port(
            i_sel : in  std_logic_vector(4 downto 0);
            i_en  : in  std_logic;
            o_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_32by32 is
        port(
            sel      : in  std_logic_vector(4 downto 0);
            data_in  : in  reg_array;
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component nbitRegister is
        generic ( N : integer := 32 );
        port (
            i_CLK : in  std_logic;
            i_RST : in  std_logic;
            i_WE  : in  std_logic;
            i_D   : in  std_logic_vector(N-1 downto 0);
            o_Q   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal we_lines    : std_logic_vector(31 downto 0);
    signal s_we_masked : std_logic_vector(31 downto 0);
    constant WRITE_MASK: std_logic_vector(31 downto 0) := (0 => '0', others => '1');
    signal reg_data    : reg_array;
begin
    -- one-hot write enables
    decoder_inst: decoder5to32
        port map(i_sel => i_write_addr, i_en => i_write_en, o_out => we_lines);

    -- mask off x0 writes
    s_we_masked <= we_lines and WRITE_MASK;

    -- x0 is hard-wired to 0
    reg_data(0) <= (others => '0');

    -- x1..x31 are real registers
    gen_regs: for i in 1 to 31 generate
        reg_inst: nbitRegister
            generic map(N => 32)
            port map(
                i_CLK => i_clk,
                i_RST => i_RST,
                i_WE  => s_we_masked(i),
                i_D   => i_data_in,
                o_Q   => reg_data(i)
            );
    end generate;

    -- read ports
    rs1_mux: mux_32by32 port map(sel => i_rs1, data_in => reg_data, data_out => o_rs1);
    rs2_mux: mux_32by32 port map(sel => i_rs2, data_in => reg_data, data_out => o_rs2);
end structural;

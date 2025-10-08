library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.reg_array.all;

entity datapathTwo_full_reg_file is
  port(
    i_data_in  : in  std_logic_vector(31 downto 0);
    i_write_addr : in std_logic_vector(4 downto 0);
    i_clk      : in  std_logic;
    i_write_en : in  std_logic;
    i_rs1      : in  std_logic_vector(4 downto 0);
    i_rs2      : in  std_logic_vector(4 downto 0);

    i_ALUSrc   : in  std_logic;
    i_AddSubSel: in  std_logic;
    i_imm      : in  std_logic_vector(11 downto 0);  -- 11->32 extender

    o_ALU_Sum  : out std_logic_vector(31 downto 0);
    o_ALU_Carry: out std_logic;

    signed_or_zero_select : in std_logic;
    mem_we    : in  std_logic;
    ALU_or_mem_sel : in std_logic
  );
end datapathTwo_full_reg_file;



architecture structural of datapathTwo_full_reg_file is
  --PC
component PCRegister
    generic (N : integer := 32);
  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic_vector;   
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
       );
end component;

component adder
      generic map(N : integer := 32);
      port map(
        i_D0 : in std_logic; 
        i_D1 : in std_logic; 
        i_C : in std_logic; 
        oC : out std_logic; 
        o_O : out std_logic 
      );
 end component;

  component decoder5to32 is
    port(i_sel: in std_logic_vector(4 downto 0);
         i_en : in std_logic;
         o_out: out std_logic_vector(31 downto 0));
  end component;

  component mux_32by32 is
    port(sel: in std_logic_vector(4 downto 0);
         data_in: in reg_array;
         data_out: out std_logic_vector(31 downto 0));
  end component;

  component Nbit_reg is
    generic ( N: integer := 32 );
    port(i_CLK: in std_logic; i_RST: in std_logic; i_WE: in std_logic;
         i_DataIn: in std_logic_vector(N-1 downto 0);
         o_DataOut: out std_logic_vector(N-1 downto 0));
  end component;

  component andg2 
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;

  component mux2t1_N is
    generic(N: integer := 16);
    port(i_S: in std_logic;
         i_D0, i_D1: in std_logic_vector(N-1 downto 0);
         o_O: out std_logic_vector(N-1 downto 0));
  end component;

  component adder_subtractor is
    generic(N: integer := 32);
    port(i_D0, i_D1: in std_logic_vector(N-1 downto 0);
         i_Sel: in std_logic;
         o_Sum: out std_logic_vector(N-1 downto 0);
         o_Cout: out std_logic);
  end component;

  component dmem is
    generic (DATA_WIDTH: natural := 32; ADDR_WIDTH: natural := 10);
    port(clk: in std_logic;
         addr: in std_logic_vector(ADDR_WIDTH-1 downto 0);
         data: in std_logic_vector(DATA_WIDTH-1 downto 0);
         we  : in std_logic := '1';
         q   : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  component Bit_Extender is
    port(din: in std_logic_vector(11 downto 0);
         ctrl: in std_logic;
         dout: out std_logic_vector(31 downto 0));
  end component;
--datapath 2 signals
  signal reg_data            : reg_array;
  signal B_or_imm            : std_logic_vector(31 downto 0);
  signal o_rs1, o_rs2        : std_logic_vector(31 downto 0);
  signal we_decoded, we_masked: std_logic_vector(31 downto 0);
  signal wb_data, wb_ALU, wb_mem: std_logic_vector(31 downto 0);
  signal bit_extended_imm    : std_logic_vector(31 downto 0);

  --fetch logic and pc function signals
  signal pc4_to_mux_in : std_logic_vector(31 downto 0);
  signal pc_line : std_logic_vector(31 downto 0);
  signal pc_adder_to_mux_in : std_logic_vector(31 downto 0);
  signal pc_to_mux_out : std_logic_vector(31 downto 0);
  signal pc_mux_sel : std_logic;
  signal FLAG_ZERO : std_logic;
  signal FLAG_CARRY : std_logic;
  signal FLAG_OVERFLOW : std_logic;
  signal FLAG_NEG : std_logic;
  signal FLAG_HALT : std_logic;
  signal flag_comp : std_logic_vector(1 downto 0); --NEED A COMPARATOR TO FIND GET THE RIGHT FLAG, DECODER?
  signal instr_mem_out : std_logic_vector(31 downto 0);

  
 
  
  --control logic signals
  signal OP_BRANCH : std_logic;




  constant WRITE_MASK : std_logic_vector(31 downto 0) := (0 => '0', others => '1');

begin
  -- write decoder
  decoder_inst: decoder5to32
    port map(i_sel => i_write_addr, i_en => i_write_en, o_out => we_decoded);

  we_masked <= we_decoded and WRITE_MASK;
  reg_data(0) <= (others => '0');

  gen_regs: for i in 1 to 31 generate
    reg_inst: Nbit_reg
      generic map(N => 32)
      port map(i_CLK => i_clk, i_RST => '0', i_WE => we_masked(i),
               i_DataIn => wb_data, o_DataOut => reg_data(i));
  end generate;

  rs1_mux: mux_32by32 port map(sel => i_rs1, data_in => reg_data, data_out => o_rs1);
  rs2_mux: mux_32by32 port map(sel => i_rs2, data_in => reg_data, data_out => o_rs2);


  pc_register_inst: PCRegister
       port map(
       i_CLK  => i_clk,
       i_RST => "0",
       i_WE => "1",
       i_D => pc_to_mux_out,
       o_Q => pc_line
       );

 inst_mem_inst: dmem
    port map(
      clk  => i_clk,
      addr => pc_line(11 downto 2),   -- word address (ADDR_WIDTH=10)
      data => "0",                 -- store data comes from rs2
      we   => "0",
      q    => instr_mem_out
    );

 fetch_adder_inst: adder
      generic map(N => N)
      port map(
       i_D0 => PC_line,
        i_D1 => i_Imm,
        i_C => "0",
        oC => "0",
        o_O => pc_adder_to_mux_in
      );

  pc_plus_4_adder: adder
      generic map(N => N)
      port map(
       i_D0 => pc_line,
        i_D1 => "0100",
        i_C => "0",
        oC => "0",
        o_O => pc4_to_mux_in
      );
  pc_add_mux_sel: andg2
  port map(
       i_A => OP_BRANCH,
       i_B => FLAG_ZERO,
       o_F => pc_mux_sel     
       );


  PC_add_mux_inst: mux2t1_N
    generic map(N => N)
      port map(
        i_S => pc_mux_sel,
        i_X0 => pc4_to_mux_in,
        i_X1 => pc_adder_to_mux_in,
        o_X => pc_to_mux_out
      );

  -- 16->32 extender
  bit_extender_inst: Bit_Extender
    port map(
        din => i_imm,  
        ctrl => signed_or_zero_select, 
        dout => bit_extended_imm
        );


  -- ALU B-input mux (32-bit)
  mux_inst: mux2t1_N
    generic map (N => 32)
    port map(i_S => i_ALUSrc, 
            i_D0 => o_rs2, 
            i_D1 => bit_extended_imm,  
            o_O => B_or_imm);

  -- ALU
  ALU_inst: adder_subtractor
    port map(i_D0 => o_rs1, 
             i_D1 => B_or_imm, 
             i_Sel => i_AddSubSel,
             o_Sum => wb_ALU, 
             o_Cout => o_ALU_Carry);

  -- Data memory
  mem_inst: dmem
    port map(
      clk  => i_clk,
      addr => wb_ALU(11 downto 2),   -- word address (ADDR_WIDTH=10)
      data => o_rs2,                 -- store data comes from rs2
      we   => mem_we,
      q    => wb_mem
    );

  -- Write-back mux (32-bit)
  mux_wb_inst: mux2t1_N
    generic map (N => 32)       
    port map(
      i_S  => ALU_or_mem_sel,
      i_D0 => wb_ALU,
      i_D1 => wb_mem,
      o_O  => wb_data
    );

  -- drive the top-level ALU sum output
  o_ALU_Sum <= wb_ALU;

end architecture;
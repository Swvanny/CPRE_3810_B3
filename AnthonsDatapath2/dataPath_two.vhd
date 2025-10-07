library IEEE;
use IEEE.std_logic_1164.all;
use work.reg_array.all;

entity dataPathFull is
  generic(
    N : integer := 32;
DATA_WIDTH : natural := 32; -- this is the data length stored in memory to manipulate. It is the same length as the registers
	ADDR_WIDTH : natural := 10 ); -- this is the length of the data is stored in memory. 
  
  port(
       i_clk        : in std_logic;    
       i_rst        : in std_logic;     
       i_writeAddr         : in std_logic_vector(4 downto 0);   
       i_writeEn         : in std_logic;
       i_data_in          : in std_logic_vector(31 downto 0);
       i_rs1  : in std_logic_vector(4 downto 0); --vector
       i_rs2  : in std_logic_vector(4 downto 0);
       i_memWrite : in std_logic;
       i_extend_ctrl : in std_logic;
      
       i_ALU_mem_sel : in std_logic;
       i_ALUsrc : in std_logic;
       i_Imm : in std_logic_vector(11 downto 0);
       i_AddSub     : in std_logic;
       i_CAS           : in std_logic;
       o_CAS           : out std_logic;  
       o_rs1_debug : out std_logic_vector(31 downto 0);
       o_rs2_debug : out std_logic_vector(31 downto 0);
       o_fin_out           : out std_logic_vector(N-1 downto 0)
  );
end dataPathFull;

architecture structural of dataPathFull is 

--PC
component PCRegister
    generic (
        N : integer := 32  
    );
  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic_vector(N-1 downto 0);     
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
       );
end component;

 component mux2t1_N 
    generic(N : integer := 32);
    port(i_S  : in std_logic;
         i_X0 : in std_logic_vector(N-1 downto 0);
         i_X1 : in std_logic_vector(N-1 downto 0);
         o_X  : out std_logic_vector(N-1 downto 0));
  end component;

component adder_subtractor
  generic(N : integer := 32); 
  port(
       i_A1         : in std_logic_vector(N-1 downto 0);
       i_B1          : in std_logic_vector(N-1 downto 0);
       i_AddSub     : in std_logic;
       i_CAS           : in std_logic;
       o_CAS           : out std_logic;  
       o_SAS           : out std_logic_vector(N-1 downto 0)
  );
end component;

component dmem
generic 
	(
		DATA_WIDTH : natural := 32; -- this is the data length stored in memory to manipulate. It is the same length as the registers
		ADDR_WIDTH : natural := 10  -- this is the length of the data is stored in memory. 
	);

	port 
	(
		clk		: in std_logic; --clock for the memory
		addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);  --this is where the address is stored in memory
		data	        : in std_logic_vector((DATA_WIDTH-1) downto 0); -- this is the data that is stored at that address.
		we		: in std_logic; -- this is the enable for the write memory
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0) -- this is the output of the memory file
	);
 

end component;

component bitExtender
port (
        data_in  : in  std_logic_vector(11 downto 0);
        ctrl : in  std_logic; -- '0' for zero-extend, '1' for sign-extend
        data_out : out std_logic_vector(31 downto 0)
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

  component registerFile
  generic (
        N : integer := 32
    );
    port(i_clk        : in std_logic;    
       i_rst        : in std_logic;    
       i_writeAddr         : in std_logic_vector(4 downto 0);     
       i_writeEn         : in std_logic;
       i_data_in          : in std_logic_vector(31 downto 0);    
       i_rs1  : in std_logic_vector(4 downto 0); 
       i_rs2  : in std_logic_vector(4 downto 0);
       o_rs1 : out std_logic_vector(31 downto 0);
       o_rs2 : out std_logic_vector(31 downto 0)
       );
    end component;
  
  
  signal rs2_out : std_logic_vector(31 downto 0);
  signal rs1_out : std_logic_vector(31 downto 0);
  signal data_back : std_logic_vector(31 downto 0);
  signal alu_muxOut : std_logic_vector(N-1 downto 0);
  signal alu_out : std_logic_vector(31 downto 0);
  signal extend_out : std_logic_vector(31 downto 0);
  signal wb_ALA : std_logic_vector(31 downto 0);
  signal wb_mem_out : std_logic_vector((DATA_WIDTH -1) downto 0);
  signal write_data_reg : std_logic_vector(31 downto 0);
  signal pc_mux_out : std_logic_vector(31 downto 0);

  

begin

  instr_mem: dmem
      port map (
      clk => i_clk,
      --addr => pc,
      --data => rs2_out,
      we => i_memWrite,
      q => wb_mem_out
      );

  registerFile_inst: registerFile
    generic map(N => N)
      port map(
       i_writeEn => i_writeEn,
       i_rst => i_rst,
        i_clk => i_clk,
        i_writeAddr => i_writeAddr,
        i_data_in => i_data_in,
        i_rs1 => i_rs1,
        i_rs2 => i_rs2,
        o_rs1 => rs1_out,
        o_rs2 => rs2_out
        
      );

      bitEx_inst: bitExtender
        port map (
            data_in  => i_Imm,
            ctrl     => i_extend_ctrl,
            data_out => extend_out
        );

        
      fetch_adder_inst: adder
      generic map(N => N)
      port map(
       -- i_D0 => PC line, (NOT MADE)
        i_D1 => i_Imm,
        --i_C => carry PC?,
        -- oC => not too important
        -- o_O => mux signal
      );

       PC_add_mux_inst: mux2t1_N
    generic map(N => N)
      port map(
        --i_S => ,
        --i_X0 => ,
        --i_X1 => ,
        --o_X => 
      );

      
      ALU_inst: mux2t1_N
    generic map(N => N)
      port map(
        i_S => i_ALUsrc,
        i_X0 => rs2_out,
        i_X1 => extend_out,
        o_X => alu_muxOut
      );



      AddSub_inst: adder_subtractor
      generic map(N => N)
      port map(
       i_A1 => rs1_out,
       i_B1 => alu_muxOut,
       i_AddSub => i_AddSub,
       i_CAS => i_CAS,
       o_CAS => o_CAS,
       o_SAS => alu_out
      
      );
      wb_ALA <= alu_out;

      mem_inst: dmem
      port map (
      clk => i_clk,
      addr => alu_out(9 downto 0),
      data => rs2_out,
      we => i_memWrite,
      q => wb_mem_out
      );

      mem_to_reg_inst: mux2t1_N
    generic map(N => N)
      port map(
        i_S => i_ALU_mem_sel,
        i_X0 => wb_mem_out,
        i_X1 => wb_ALA,
        o_X => write_data_reg
      );


      o_rs1_debug <= rs1_out;
      o_rs2_debug <= rs2_out;
      o_fin_out <= write_data_reg;

        end structural;
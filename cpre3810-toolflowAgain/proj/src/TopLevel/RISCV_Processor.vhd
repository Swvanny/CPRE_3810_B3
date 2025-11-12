-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;
use work.reg_array.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment


  --PC SIGNALS
  signal s_pc_write : std_logic;
  signal s_pc_reset : std_logic;
  signal s_pc_data_in : std_logic_vector(31 downto 0);
  signal s_pc4_out : std_logic_vector(31 downto 0);
  signal s_pc_or_zero_out : std_logic_vector(31 downto 0);
  signal s_pc_word_shift_out : std_logic_vector(31 downto 0);
  signal s_pc_or_word_adder_out : std_logic_vector(31 downto 0);
  signal s_pc_target_masked : std_logic_vector(31 downto 0); -- also for jalr


 --IFID SIGNALS
 signal IFID_sInst_out : std_logic_vector(31 downto 0);
 signal IFID_pc_out : std_logic_vector(31 downto 0);

 --IDEX SIGNALS
 signal IDEX_immGen_out : std_logic_vector(31 downto 0);
 signal IDEX_rs1_out : std_logic_vector(31 downto 0);
 signal IDEX_rs2_out : std_logic_vector(31 downto 0);
 signal IDEX_Branch_out : std_logic;
 signal IDEX_Jump_out : std_logic;
 signal IDEX_FlagNFlag_out : std_logic;
 signal IDEX_AndLink_out  : std_logic_vector(1 downto 0);
 signal IDEX_MemWrite_out : std_logic;
 signal IDEX_FlagMux_out : std_logic_vector(1 downto 0);
 signal IDEX_MemToReg_out : std_logic;
 signal IDEX_ALUSrc_out : std_logic;
 signal IDEX_Shift_out : std_logic;
 signal IDEX_ALUControl_out : std_logic_vector(3 downto 0);
 signal IDEX_JumpWithReg_out : std_logic;
 signal IDEX_PC_out : std_logic_vector(31 downto 0);
 signal IDEX_PC4_out : std_logic_vector(31 downto 0);
 signal IDEX_ALU_or_IMM_out : std_logic_vector(31 downto 0);
 signal IDEX_funct3_out : std_logic_vector(2 downto 0);

 --EXMEM SIGNALS
 signal EXMEM_ALU_Flag_out : std_logic;
 signal EXMEM_ALUOut : std_logic_vector(31 downto 0);
 signal EXMEM_Shift_out : std_logic;
 signal EXMEM_PC4_out std_logic_vector(31 downto 0);
 signal EXMEM_barrel_out : std_logic_vector(31 downto 0);
 signal EXMEM_PC_jump_adder_out : std_logic;
 signal EXMEM_Branch_out : std_logic;
 signal EXMEM_Jump_out : std_logic;
 signal EXMEM_FlagNFlag_out : std_logic;
 signal EXMEM_AndLink_out  : std_logic_vector(1 downto 0);
 signal EXMEM_MemWrite_out : std_logic;
signal EXMEM_MemToReg_out : std_logic;
signal EXMEM_funct3_out :  std_logic_vector(2 downto 0);

 --MEMWB
signal MEMWB_MemToReg_out : std_logic;
signal MEMWB_DMEM_out : std_logic_vector(31 downto 0);
signal MEMWB_4t1AndLink_out : std_logic_vector(31 downto 0);
signal pc_writeback_MEMWB_input : std_logic_vector(31 downto 0);
signal MEMWB_funct3_out : std_logic_vector(2 downto 0);
signal MEMWB_addr_out : std_logic_vector(1 downto 0);
 
 --Control Unit SIGNALS
  signal s_ALUSrc             : std_logic;
  signal s_ALUControl         : std_logic_vector(3 downto 0);
  signal s_AndLink            : std_logic_vector(1 downto 0);
  signal s_MemToReg           : std_logic;
  signal s_Branch             : std_logic;
  signal s_Jump               : std_logic;
  signal s_ALU_Or_Imm_Jump    : std_logic;
  signal s_Flag_Mux           : std_logic_vector(1 downto 0);
  signal s_Flag_Or_Nflag      : std_logic;
  signal s_Jump_With_Register : std_logic;
  signal s_Shift              : std_logic;
  signal is_jalr              : std_logic;


  signal s_zero_flag     : std_logic;
  signal s_negative_flag : std_logic;
  signal s_carry_flag    : std_logic;
  signal s_slt_flag      : std_logic;

  --Register File SIGNALS

  --signal reg_data : reg_array;
  constant WRITE_MASK : std_logic_vector(31 downto 0) := (0 => '0', others => '1');
  signal s_decoder_out : std_logic_vector(31 downto 0);
  signal s_we_masked : std_logic_vector(31 downto 0);
  signal s_out_rs1, s_out_rs2 : std_logic_vector(31 downto 0);


  --Extended Immediate SIGNALS

signal s_bitext_in : std_logic_vector(19 downto 0);
  signal s_extended_imm : std_logic_vector(31 downto 0);
  signal s_ALU_or_imm_shift_in : std_logic_vector(31 downto 0);
  
  signal sMemSlice : std_logic_vector(31 downto 0);

--ALU SIGNALS
 signal s_rs2_or_imm_mux_out : std_logic_vector(31 downto 0);
 signal s_4t1_and_link_out : std_logic_vector(31 downto 0);
 signal s_flag_mux_out : std_logic;
 signal s_negation_flag_out : std_logic;
 signal s_final_flag_out : std_logic;

 signal s_and_branch_out : std_logic;
 signal s_or_jump_out : std_logic;
signal s_slt_mux_out : std_logic_vector(31 downto 0);
signal s_sltiu_mux_out : std_logic_vector(31 downto 0);
signal s_slt_sltiu_mux_out : std_logic_vector(31 downto 0);
signal s_alu_out : std_logic_vector(31 downto 0);

--BARREL SHIFTER SIGNALS
 signal s_out_shifted_data : std_logic_vector(31 downto 0);

 signal s_exec_result : std_logic_vector(31 downto 0);



--REGISTER IMPLEMENTATION    

component PCRegister is
    generic (
        N : integer := 32  
    );
  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
       );
end component;

component PipelineRegister is
    generic (
        N : integer := 32  
    );

  port(i_CLK        : in std_logic;    
       i_RST        : in std_logic;
       i_WE         : in std_logic;     -- Write enable 
       i_D         : in std_logic_vector(N-1 downto 0);
       o_Q          : out std_logic_vector(N-1 downto 0)     -- Data 
       );

end component;

component IDEXRegister is 
port(
 i_CLK        : in std_logic;    
 i_RST        : in std_logic;
 

 IDEX_immGen  : in std_logic_vector(31 downto 0);
  IDEX_rs1  : in std_logic_vector(31 downto 0);
  IDEX_rs2  : in std_logic_vector(31 downto 0);
  IDEX_Branch  : in std_logic;
  IDEX_Jump  : in std_logic;
  IDEX_FlagNFlag  : in  std_logic;
  IDEX_AndLink   : in std_logic_vector(1 downto 0);
  IDEX_MemWrite  : in std_logic;
  IDEX_FlagMux  : in std_logic_vector(1 downto 0);
  IDEX_MemToReg  : in std_logic;
  IDEX_ALUSrc  : in std_logic;
  IDEX_Shift  : in std_logic;
  IDEX_ALUControl  : in std_logic_vector(3 downto 0);
  IDEX_JumpWithReg  : in std_logic;
  IDEX_PC  : in std_logic_vector(31 downto 0);
  IDEX_PC4  : in std_logic_vector(31 downto 0);
  IDEX_ALU_or_IMM : in std_logic_vector(31 downto 0);
  IDEX_funct3 : in std_logic_vector(2 downto 0);

  IDEX_funct3_out : out std_logic_vector(2 downto 0);
IDEX_ALU_or_IMM_out : out std_logic_vector(31 downto 0);
IDEX_immGen_out : out std_logic_vector(31 downto 0);
   IDEX_rs1_out : out std_logic_vector(31 downto 0);
   IDEX_rs2_out : out std_logic_vector(31 downto 0);
   IDEX_Branch_out : out std_logic;
   IDEX_Jump_out : out std_logic;
   IDEX_FlagNFlag_out : out std_logic;
   IDEX_AndLink_out  : out std_logic_vector(1 downto 0);
   IDEX_MemWrite_out :  out std_logic;
   IDEX_FlagMux_out : out std_logic_vector(1 downto 0);
   IDEX_MemToReg_out :  out std_logic;
   IDEX_ALUSrc_out : out std_logic;
   IDEX_Shift_out :  out std_logic;
   IDEX_ALUControl_out : out std_logic_vector(3 downto 0);
   IDEX_JumpWithReg_out : out std_logic;
   IDEX_PC_out : out std_logic_vector(31 downto 0);
   IDEX_PC4_out : out std_logic_vector(31 downto 0)
);

end component;

component EXMEMRegister is
  port(
    i_CLK  : in std_logic;
    i_RST  : in std_logic;

   
    EXMEM_ALU_Flag        : in  std_logic;
    EXMEM_ALUOut          : in  std_logic_vector(31 downto 0);
    EXMEM_Shift           : in  std_logic;
    EXMEM_PC4             : in  std_logic_vector(31 downto 0);
    EXMEM_barrel          : in  std_logic_vector(31 downto 0);
    EXMEM_PC_jump_adder   : in  std_logic;
    EXMEM_Branch          : in  std_logic;
    EXMEM_Jump            : in  std_logic;
    EXMEM_FlagNFlag       : in  std_logic;
    EXMEM_AndLink         : in  std_logic_vector(1 downto 0);
    EXMEM_MemWrite        : in  std_logic;
    EXMEM_MemToReg        : in  std_logic;
    EXMEM_funct3          : in std_logic_vector(2 downto 0);

    EXMEM_funct3_out      : out std_logic_vector(2 downto 0);
    EXMEM_ALU_Flag_out      : out std_logic;
    EXMEM_ALUOut_out        : out std_logic_vector(31 downto 0);
    EXMEM_Shift_out         : out std_logic;
    EXMEM_PC4_out           : out std_logic_vector(31 downto 0);
    EXMEM_barrel_out        : out std_logic_vector(31 downto 0);
    EXMEM_PC_jump_adder_out : out std_logic;
    EXMEM_Branch_out        : out std_logic;
    EXMEM_Jump_out          : out std_logic;
    EXMEM_FlagNFlag_out     : out std_logic;
    EXMEM_AndLink_out       : out std_logic_vector(1 downto 0);
    EXMEM_MemWrite_out      : out std_logic;
    EXMEM_MemToReg_out      : out std_logic
  );
end component;


  component nbitRegister is
    generic ( N: integer := 32 );
    port(i_CLK: in std_logic; i_RST: in std_logic; i_WE: in std_logic;
         i_D: in std_logic_vector(N-1 downto 0);
         o_Q: out std_logic_vector(N-1 downto 0));
  end component;

  component full_reg_file is
    port(
        i_data_in : in std_logic_vector(31 downto 0);
        i_write_addr : in std_logic_vector(4 downto 0);
        i_clk : in std_logic;
        i_RST : in std_logic;
        i_write_en : in std_logic;
        i_rs1 : in std_logic_vector(4 downto 0);
        i_rs2 : in std_logic_vector(4 downto 0);

        o_rs1 : out std_logic_vector(31 downto 0);
        o_rs2 : out std_logic_vector(31 downto 0)
    );
end component;

-- MUX'S IMPLEMENTATIONS

  component mux_32by32 is
    port(sel: in std_logic_vector(4 downto 0);
         data_in: in reg_array;
         data_out: out std_logic_vector(31 downto 0));
  end component;

    component mux2t1_N is
    generic(N: integer := 32);
    port(i_S: in std_logic;
         i_X0, i_X1: in std_logic_vector(N-1 downto 0);
         o_X: out std_logic_vector(N-1 downto 0));
  end component;

  component mux4t1_32 is
  port(
    i_S  : in  std_logic_vector(1 downto 0);  
    i_X0 : in  std_logic_vector(31 downto 0); 
    i_X1 : in  std_logic_vector(31 downto 0); 
    i_X2 : in  std_logic_vector(31 downto 0); 
    i_X3 : in  std_logic_vector(31 downto 0); 
    o_X  : out std_logic_vector(31 downto 0)  
  );
end component;

component mux4t1 is
    port(
        i_D0 : in std_logic;
        i_D1 : in std_logic;
        i_D2 : in std_logic;
        i_D3 : in std_logic;
        i_S  : in std_logic_vector(1 downto 0);
        o_Y  : out std_logic
    );
end component;

component mux2t1 is 
      port (
        i_X0 : in std_logic;
        i_X1 : in std_logic;
        i_S : in std_logic;
        o_X : out std_logic
      );
      end component;

  

  --SIGNED BIT EXTENDER IMPLEMENTATION

  component bitExtender
port (
        data_in  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
 end component;

--CONTROL IMPLEMENTATION

component Control_Unit_2 
  port (
    opcode   : in  std_logic_vector(6 downto 0);
    funct3   : in  std_logic_vector(2 downto 0);
    funct7   : in  std_logic_vector(6 downto 0);

    ALUSrc             : out std_logic;
    ALUControl         : out std_logic_vector(3 downto 0);
    --ImmType            : out std_logic_vector(6 downto 0);
    AndLink            : out std_logic_vector(1 downto 0);
    MemWrite           : out std_logic;
    RegWrite           : out std_logic;
    MemToReg           : out std_logic;
    Branch             : out std_logic;
    Jump               : out std_logic;
    ALU_Or_Imm_Jump    : out std_logic;
    Flag_Mux           : out std_logic_vector(1 downto 0);
    Flag_Or_Nflag      : out std_logic;
    Jump_With_Register : out std_logic;
    Halt               : out std_logic;
    Shift              : out std_logic
  );
end component;

--GOBLIN BARREL

component goblinBarrel 
    port (
        data_in           : in  std_logic_vector(31 downto 0);
        shift_left_right  : in  std_logic_vector(3 downto 0); 
        shift_amount      : in  std_logic_vector(4 downto 0);
        data_out          : out std_logic_vector(31 downto 0)
    );
end component;

--ADDERS FOR FETCH

component adder
      generic(N : integer := 32);
      port(
        i_D0 : in std_logic; 
        i_D1 : in std_logic; 
        i_C : in std_logic; 
        oC : out std_logic; 
        o_O : out std_logic 
      );
 end component;

 component Nbit_adder 
  generic (N : integer := 32);  
  port(
    i_A  : in std_logic_vector(N-1 downto 0);
    i_B  : in std_logic_vector(N-1 downto 0);
    i_C  : in std_logic;  
    o_S  : out std_logic_vector(N-1 downto 0);
    o_C  : out std_logic  
  );
end component;

--DECODER FOR REGISTER

component decoder5to32 is
    port(i_sel: in std_logic_vector(4 downto 0);
         i_en : in std_logic;
         o_out: out std_logic_vector(31 downto 0));
  end component;

-- ALU
component ALUUnit is
  generic (WIDTH : integer := DATA_WIDTH);
  port(
    Alucontrol    : in  std_logic_vector(3 downto 0);
    flag_mux      : in  std_logic_vector(1 downto 0);
    input_A       : in  std_logic_vector (WIDTH-1 downto 0);
    input_B       : in  std_logic_vector (WIDTH-1 downto 0);
    output_result : out std_logic_vector (WIDTH-1 downto 0);      
    flag_zero     : out std_logic;
    flag_carry    : out std_logic;
    flag_negative : out std_logic;
    flag_slt : out std_logic
  );
end component;


--GATES

component andg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component invg is
  port(i_A          : in std_logic;
       o_F          : out std_logic);
end component;

component org2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component zeroExtender_1to32 is
  port (
    data_in  : in  std_logic;                     -- single input bit
    data_out : out std_logic_vector(31 downto 0)  -- 32-bit zero-extended output
  );
end component;

component memSlicer is
  port (
    funct3 : in std_logic_vector(2 downto 0);
    addr   : in std_logic_vector(1 downto 0);
    input  : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0));

end component;

begin
  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 
PCCounter_inst: PCRegister
generic map( N => 32)
port map (
     i_CLK => iCLK,
     i_RST => iRST,
     i_WE => '1',
     i_D => s_pc_data_in,
     o_Q => s_NextInstAddr
  
);

--IFID REGISTER

IFID_S_Inst_Register: PipelineRegister
generic map(N => 32)
port map (
  i_CLK  => iCLK,
       i_RST  => iRST,
       i_WE => '1',
       i_D =>  s_Inst,     
       o_Q   => IFID_sInst_out
);

IFID_PC_Register: PipelineRegister
generic map(N => 32)
port map (
  i_CLK  => iCLK,
       i_RST  => iRST,
       i_WE => '1',
       i_D =>  s_NextInstAddr,     
       o_Q   => IFID_pc_out
);




pc4adder: Nbit_adder
generic map(N =>32)
port map(
    i_A  => s_NextInstAddr,
    i_B  => x"00000004",
    i_C  => '0',
    o_S  => s_pc4_out,
    o_C  => open
  );

Control_Unit_inst: Control_Unit_2
  port map(
    opcode   => IFID_sInst_out(6 downto 0),
    funct3   => IFID_sInst_out(14 downto 12),
    funct7   => IFID_sInst_out(31 downto 25),

    ALUSrc             => s_ALUSrc,
    ALUControl         => s_ALUControl,
    AndLink            => s_AndLink,
    MemWrite           => s_DMemWr,
    RegWrite           => s_RegWr,
    MemToReg           => s_MemToReg,
    Branch             => s_Branch,
    Jump               => s_Jump,
    ALU_Or_Imm_Jump    => s_ALU_Or_Imm_Jump,
    Flag_Mux           => s_Flag_Mux,
    Flag_Or_Nflag      => s_Flag_Or_Nflag,
    Jump_With_Register => s_Jump_With_Register,
    Halt               => s_Halt,
    Shift              => s_Shift
  );

  s_RegWrAddr <= IFID_sInst_out(11 downto 7);
  s_Ovfl <= '0';



-- Unmasked PC target from the adder:
-- s_pc_or_word_adder_out already computed

-- Mask bit 0 for JALR only:
s_pc_target_masked <= (s_pc_or_word_adder_out and x"FFFFFFFE") when is_jalr = '1'
                     else s_pc_or_word_adder_out;
  

 -- decoder_inst: decoder5to32
  --  port map(i_sel => s_RegWrAddr, i_en => s_RegWr, o_out => s_decoder_out);

 -- s_we_masked <= s_decoder_out and WRITE_MASK;
 -- reg_data(0) <= (others => '0');

 -- gen_regs: for i in 1 to 31 generate
  --  reg_inst: nbitRegister
  --    generic map(N => 32)
  --    port map(i_CLK => iCLK, i_RST => iRST, i_WE => s_we_masked(i),
 --              i_D => s_RegWrData, o_Q => reg_data(i));
 -- end generate;

 -- rs1_mux: mux_32by32 port map(sel => s_inst(19 downto 15), data_in => reg_data, data_out => s_out_rs1);
  --rs2_mux: mux_32by32 port map(sel => s_inst(24 downto 20), data_in => reg_data, data_out => s_out_rs2);

Register_inst: full_reg_file
port map(
       i_data_in => s_RegWrData,
        i_write_addr => s_RegWrAddr,
        i_clk => iCLK,
        i_RST => iRST,
        i_write_en => s_RegWr,
        i_rs1 => IFID_sInst_out(19 downto 15),
        i_rs2 => IFID_sInst_out(24 downto 20),

        o_rs1 => s_out_rs1,
        o_rs2 => s_out_rs2
);


  bitExtender_inst: bitExtender
    port map(
        data_in  => IFID_sInst_out,
        data_out => s_extended_imm
    );


    --IDEX REGISTER
  IDEXRegister_inst: IDEXRegister
  port map(
i_CLK => iCLK,         
 i_RST  => iRST,      

 IDEX_immGen  => s_extended_imm,
  IDEX_rs1 => s_rs1_out,
  IDEX_rs2  => s_rs2_out,
  IDEX_Branch => s_Branch,
  IDEX_Jump  =>s_Jump,
  IDEX_FlagNFlag => s_Flag_Or_Nflag,
  IDEX_AndLink   => s_AndLink,
  IDEX_MemWrite  => s_DMemWr,
  IDEX_FlagMux => s_Flag_Mux,
  IDEX_MemToReg => s_MemToReg,
  IDEX_ALUSrc => s_ALUSrc,
  IDEX_Shift  => s_Shift,
  IDEX_ALUControl =>  s_ALUControl,
  IDEX_JumpWithReg => s_Jump_With_Register,
  IDEX_PC  => IFID_pc_out,
  IDEX_PC4  => s_pc4_out,
  IDEX_ALU_or_IMM => s_ALU_Or_Imm_Jump,
  IDEX_funct3 => IFID_sInst_out(14 downto 12),

  IDEX_funct3_out => IDEX_funct3_out
IDEX_immGen_out => IDEX_immGen_out,
   IDEX_rs1_out => IDEX_rs1_out,
   IDEX_rs2_out => IDEX_rs2_out,
   IDEX_Branch_out => IDEX_Branch_out,
   IDEX_Jump_out => IDEX_Jump_out,
   IDEX_FlagNFlag_out => IDEX_FlagNFlag_out,
   IDEX_AndLink_out  => IDEX_AndLink_out,
   IDEX_MemWrite_out => IDEX_MemWrite_out,
   IDEX_FlagMux_out => IDEX_FlagMux_out,
   IDEX_MemToReg_out => IDEX_MemToReg_out,
   IDEX_ALUSrc_out => IDEX_ALUSrc_out,
   IDEX_Shift_out => IDEX_Shift_out,
   IDEX_ALUControl_out => IDEX_ALUControl_out,
   IDEX_JumpWithReg_out => IDEX_JumpWithReg_out,
   IDEX_PC_out => IDEX_PC_out,
   IDEX_ALU_or_IMM_out => IDEX_ALU_or_IMM_out,
   IDEX_PC4_out => IDEX_PC4_out

  );


    

    rs2_or_imm_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => IDEX_ALUSrc_out,
        i_X0 => IDEX_rs2_out,
        i_X1 => IDEX_immGen_out,
        o_X => s_rs2_or_imm_mux_out
    );

s_DMemData <= IDEX_rs2_out;

    ALU_inst : ALUUnit
    generic map(WIDTH => 32)
    port map(
        Alucontrol    => IDEX_ALUControl_out,
        flag_mux      => IDEX_FlagMux_out,
        input_A       => IDEX_rs1_out,
        input_B       => s_rs2_or_imm_mux_out,
        output_result => s_alu_out,
        flag_zero     => s_zero_flag,
        flag_carry    => s_carry_flag,
        flag_negative => s_negative_flag,
        flag_slt      => s_slt_flag
        

    );
    --oALUOut <= s_alu_out;
    s_DMemAddr <= s_exec_result;

    alu_flag_mux_flag_out : mux4t1
    port map(
        i_S  => s_Flag_Mux,
        i_D0 => s_negative_flag,
        i_D1 => s_slt_flag,
        i_D2 => s_carry_flag,
        i_D3 => s_zero_flag,
        o_Y  => s_flag_mux_out
    );


    EXMEMRegister_inst: EXMEMRegister
  port map(
    i_CLK => iCLK,
    i_RST => iRST,

    EXMEM_ALU_Flag      => s_flag_mux_out,
    EXMEM_ALUOut        => s_exec_result,
    EXMEM_Shift         => IDEX_Shift_out,
    EXMEM_PC4           => IDEX_PC4_out,
    EXMEM_barrel        => s_out_shifted_data,
    EXMEM_PC_jump_adder => s_pc_target_masked,
    EXMEM_Branch        => IDEX_Branch_out,
    EXMEM_Jump          => IDEX_Jump_out,
    EXMEM_FlagNFlag     => IDEX_FlagNFlag_out,
    EXMEM_AndLink       => IDEX_AndLink_out,
    EXMEM_MemWrite      => IDEX_MemWrite_out,
    EXMEM_MemToReg      => IDEX_MemToReg_out,
    EXMEM_funct3        => IDEX_funct3_out,

    EXMEM_funct3_out        => EXMEM_funct3_out
    EXMEM_ALU_Flag_out      => EXMEM_ALU_Flag_out,
    EXMEM_ALUOut_out        => EXMEM_ALUOut_out,
    EXMEM_Shift_out         => EXMEM_Shift_out,
    EXMEM_PC4_out           => EXMEM_PC4_out,
    EXMEM_barrel_out        => EXMEM_barrel_out,
    EXMEM_PC_jump_adder_out => EXMEM_PC_jump_adder_out,
    EXMEM_Branch_out        => EXMEM_Branch_out,
    EXMEM_Jump_out          => EXMEM_Jump_out,
    EXMEM_FlagNFlag_out     => EXMEM_FlagNFlag_out,
    EXMEM_AndLink_out       => EXMEM_AndLink_out,
    EXMEM_MemWrite_out      => EXMEM_MemWrite_out,
    EXMEM_MemToReg_out      => EXMEM_MemToReg_out
  );

    flag_negation_gate : invg
    port map(
        i_A => EXMEM_ALU_Flag_out,
        o_F => s_negation_flag_out
    );

    negation_mux : mux2t1
    port map(
        i_S => EXMEM_FlagNFlag_out,
        i_X0 => EXMEM_ALU_Flag_out,
        i_X1 => s_negation_flag_out,
        o_X => s_final_flag_out
    );

    branch_and_flag_gate : andg2
    port map(
        i_A => EXMEM_Branch_out,
        i_B => s_final_flag_out,
        o_F => s_and_branch_out
    );

    jump_or_gate : org2
    port map(
        i_A => EXMEM_Jump_out,
        i_B => s_and_branch_out,
        o_F => s_or_jump_out
    );

   
    --THIS IMPLEMENTATION COULD WORK, IF JUMP PROBLEMS THEN LOOK HERE
    bitExtend_or_ALU_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => IDEX_ALU_or_IMM_out,
        i_X0 => s_alu_out, --sketchy code
        i_X1 => IDEX_immGen_out,
        o_X => s_ALU_or_imm_shift_in
    );
    goblinBarrel_inst : goblinBarrel
    port map(
        data_in => IDEX_rs1_out,
        shift_left_right => IDEX_ALUControl_out,
        shift_amount => s_rs2_or_imm_mux_out(4 downto 0),
        data_out => s_out_shifted_data
    );

    s_exec_result <= s_out_shifted_data when s_Shift = '1' else s_alu_out;
    oALUOut <= s_exec_result;

    pc_or_zero_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => IDEX_JumpWithReg_out,
        i_X0 => IDEX_PC_out,
        i_X1 => X"00000000",
        o_X => s_pc_or_zero_out
    );

  

    pc_or_branch_adder : Nbit_adder
    generic map(N =>32)
    port map(
        i_A  => s_pc_or_zero_out,
        i_B  => s_ALU_or_imm_shift_in,  
        i_C  => '0',
        o_S  => s_pc_or_word_adder_out, --this and the execute signal could get sketchy, they might write THROUGH the register if done wrongly
        o_C  => open
    );

    pc4_or_branch_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => s_or_jump_out,
        i_X0 => s_pc4_out,
        i_X1 => EXMEM_PC_jump_adder_out,
        o_X => pc_writeback_MEMWB_input
    );


    mux4t1_and_link_mux : mux4t1_32
    port map(
        i_S  => EXMEM_AndLink_out,
        i_X0 => EXMEM_ALUOut_out,
        i_X1 => EXMEM_PC_jump_adder_out,
        i_X2 => s_slt_sltiu_mux_out,
        i_X3 => EXMEM_PC4_out,
        o_X  => s_4t1_and_link_out
    );

    memorySlicer : memSlicer
    port map(
      funct3 => MEMWB_funct3_out,
      addr => MEMWB_addr_out,
      input => MEMWB_DMEM_out,
      output => sMemSlice
    );



--MEMWB REGISTER x4
    MEMWB_MemToReg_Register : PipelineRegister
    generic map(N => 1)
    port map (
       i_CLK => iCLK,       
       i_RST => iRST,
       i_WE =>  '1',    
       i_D =>   EXMEM_MemToReg_out,  
       o_Q =>   MEMWB_MemToReg_out     
    );
    MEMWB_DMEM_Register : PipelineRegister
    generic map(N => 32)
    port map (
      i_CLK => iCLK,       
       i_RST => iRST,
       i_WE =>  '1',    
       i_D =>   s_DMemOut,  
       o_Q =>   MEMWB_DMEM_out  

    );
    MEMWB_funct3_Register : PipelineRegister
    generic map(N => 32)
    port map (
      i_CLK => iCLK,       
       i_RST => iRST,
       i_WE =>  '1',    
       i_D =>   EXMEM_funct3_out,  
       o_Q =>   MEMWB_funct3_out  

    );
    MEMWB_4t1AndLink_Register : PipelineRegister
    generic map(N => 32)
    port map (
      i_CLK => iCLK,       
       i_RST => iRST,
       i_WE =>  '1',    
       i_D =>   s_4t1_and_link_out,  
       o_Q =>   MEMWB_4t1AndLink_out  

    );
    MEMWB_PC4OrBranch_Register : PipelineRegister
    generic map(N => 32)
    port map (
      i_CLK => iCLK,       
       i_RST => iRST,
       i_WE =>  '1',    
       i_D =>   pc_writeback_MEMWB_input,  
       o_Q =>   s_pc_data_in  
    );
    MEMWB_addr_Register : PipelineRegister
    generic map(N => 32)
    port map (
      i_CLK => iCLK,       
       i_RST => iRST,
       i_WE =>  '1',    
       i_D =>   s_DMemAddr(1 downto 0),  
       o_Q =>   MEMWB_addr_out  

    );

    mem_to_reg_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => EXMEM_MemToReg_out,
        i_X0 => MEMWB_4t1AndLink_out,
        i_X1 => sMemSlice, --uhhhhhhhh
        o_X => s_RegWrData
    );

  zeroExtension_Flags : zeroExtender_1to32
  port map(
    data_in  => s_final_flag_out,                  -- single input bit
    data_out => s_slt_sltiu_mux_out
  );
    
end structure;



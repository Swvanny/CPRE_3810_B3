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
  signal s_pc_data : std_logic_vector(31 downto 0);
  signal s_read_address : std_logic_vector(31 downto 0);
  signal s_pc_write : std_logic;
  signal s_pc_reset : std_logic;
  signal s_pc_data_in : std_logic_vector(31 downto 0);
  signal s_pc4_out : std_logic_vector(31 downto 0);
  signal s_pc_or_zero_out : std_logic_vector(31 downto 0);
  signal s_pc_word_shift_out : std_logic_vector(31 downto 0);
  signal s_pc_or_word_adder_out : std_logic_vector(31 downto 0);


--Control Unit SIGNALS
  signal s_ALUSrc             : std_logic;
  signal s_ALUControl         : std_logic_vector(3 downto 0);
  signal s_ImmType            : std_logic_vector(1 downto 0);
  signal s_AndLink            : std_logic_vector(1 downto 0);
  signal s_MemToReg           : std_logic;
  signal s_Branch             : std_logic;
  signal s_Jump               : std_logic;
  signal s_ALU_Or_Imm_Jump    : std_logic;
  signal s_Flag_Mux           : std_logic_vector(1 downto 0);
  signal s_Flag_Or_Nflag      : std_logic;
  signal s_Jump_With_Register : std_logic;
  signal s_Shift              : std_logic;

  signal s_zero_flag : std_logic;
  signal s_negative_flag : std_logic;
  signal s_carry_flag : std_logic;

  --Register File SIGNALS
  signal reg_data : reg_array;
  constant WRITE_MASK : std_logic_vector(31 downto 0) := (0 => '0', others => '1');
  signal s_decoder_out : std_logic_vector(31 downto 0);
  signal s_we_masked : std_logic_vector(31 downto 0);
  signal s_out_rs1, s_out_rs2 : std_logic_vector(31 downto 0);

  --Extended Immediate SIGNALS
  signal s_extended_imm : std_logic_vector(31 downto 0);
  signal s_ALU_or_imm_shift_in : std_logic_vector(31 downto 0);

--ALU SIGNALS
 signal s_rs2_or_imm_mux_out : std_logic_vector(31 downto 0);
 signal s_4t1_and_link_out : std_logic_vector(31 downto 0);
 signal s_flag_mux_out : std_logic;
 signal s_negation_flag_out : std_logic;
 signal s_final_flag_out : std_logic;

 signal s_and_branch_out : std_logic;
 signal s_or_jump_out : std_logic;

--BARREL SHIFTER SIGNALS
 signal s_out_shifted_data : std_logic_vector(31 downto 0);

--REGISTER IMPLEMENTATION    

  component Nbit_reg is
    generic ( N: integer := 32 );
    port(i_CLK: in std_logic; i_RST: in std_logic; i_WE: in std_logic;
         i_DataIn: in std_logic_vector(N-1 downto 0);
         o_DataOut: out std_logic_vector(N-1 downto 0));
  end component;

--THREE MUX IMPLEMENTATIONS

  component mux_32by32 is
    port(sel: in std_logic_vector(4 downto 0);
         data_in: in reg_array;
         data_out: out std_logic_vector(31 downto 0));
  end component;

    component mux2t1_N is
    generic(N: integer := 32);
    port(i_S: in std_logic;
         i_D0, i_D1: in std_logic_vector(N-1 downto 0);
         o_O: out std_logic_vector(N-1 downto 0));
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

  

  --SIGNED BIT EXTENDER IMPLEMENTATION

  component bitExtender
port (
        data_in  : in  std_logic_vector(19 downto 0);
        ctrl : in  std_logic(1 downto 0); 
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
    ImmType            : out std_logic_vector(1 downto 0);
    AndLink            : out std_logic_vector(1 downto 0);
    MemWrite           : out std_logic;
    RegWrite           : out std_logic;
    MemToReg           : out std_logic;
    Branch             : out std_logic;
    Jump               : out std_logic;
    ALU_Or_Imm_Jump    : out std_logic;
    Flag_Mux           : out std_logic_vector(1 downto 0);
    Flag_Or_Nflag      : out std_logic;
    Jump_With_Register : out std_logic
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
      port map(
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
    flag_overflow : out std_logic
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

PCCounter_inst: Nbit_reg
generic map( N => 32)
port map (
     i_CLK => i_CLK,
     i_RST => s_pc_reset,
     i_WE => s_pc_write,
     i_DataIn => s_pc_data_in,
     o_DataOut => s_NextInstAddr
  
);

pc4adder : Nbit_adder
generic(N =>32)
port(
    i_A  => s_NextInstAddr,
    i_B  => x"00000004",
    i_C  => '0',
    o_S  => s_pc4_out,
    o_C  => open
  );

Control_Unit_inst: Control_Unit_2
  port map(
    opcode   => s_Inst(6 downto 0),
    funct3   => s_Inst(14 downto 12),
    funct7   => s_Inst(31 downto 25),

    ALUSrc             => s_ALUSrc,
    ALUControl         => s_ALUControl,
    ImmType            => s_ImmType,
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
    Shift              => s_Shift
  );

  decoder_inst: decoder5to32
    port map(i_sel => s_RegWrAddr, i_en => s_RegWr, o_out => s_decoder_out);

  s_we_masked <= s_decoder_out and WRITE_MASK;
  reg_data(0) <= (others => '0');

  gen_regs: for i in 1 to 31 generate
    reg_inst: Nbit_reg
      generic map(N => 32)
      port map(i_CLK => iCLK, iRST => '0', i_WE => s_we_masked(i),
               i_DataIn => s_RegWrData, o_DataOut => reg_data(i));
  end generate;

  rs1_mux: mux_32by32 port map(sel => s_inst(19 downto 15), data_in => reg_data, data_out => s_out_rs1);
  rs2_mux: mux_32by32 port map(sel => s_inst(24 downto 20), data_in => reg_data, data_out => s_out_rs2);

  bitExtender_inst: bitExtender
    port map(
        data_in  => s_Inst(31 downto 12),
        ctrl => s_ImmType,
        data_out => s_extended_imm
    );

    

    rs2_or_imm_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => ALUSrc,
        i_D0 => s_out_rs2,
        i_D1 => s_extended_imm,
        o_MuxOut => s_rs2_or_imm_mux_out
    );

    ALU_inst : ALUUnit
    generic map(WIDTH => 32)
    port map(
        Alucontrol    => s_ALUControl,
        flag_mux      => s_Flag_Mux,
        input_A       => s_out_rs1,
        input_B       => s_rs2_or_imm_mux_out,
        output_result => oALUOut,
        flag_zero     => s_zero_flag,
        flag_carry    => s_carry_flag,
        flag_negative => s_negative_flag,
        flag_overflow => s_Ovfl
        

    );

    alu_flag_mux_flag_out : mux4t1_32
    port map(
        i_S  => s_Flag_Mux,
        i_X0 => s_negative_flag & (others => '0'),
        i_X1 => s_Ovfl & (others => '0'),
        i_X2 => s_carry_flag & (others => '0'),
        i_X3 => s_zero_flag & (others => '0'),
        o_X  => s_flag_mux_out
    );

    flag_negation_gate : invg
    port map(
        i_A => s_flag_mux_out,
        o_F => s_negation_flag_out
    );

    negation_mux : mux2t1_N
    generic map(N => 1)
    port map(
        i_S => s_Flag_Or_Nflag,
        i_D0 => s_flag_mux_out(0),
        i_D1 => s_negation_flag_out(0),
        o_MuxOut => s_final_flag_out
    );

    branch_and_flag_gate : andg2
    port map(
        i_A => s_Branch,
        i_B => s_final_flag_out,
        o_F => s_and_branch_out
    );

    jump_or_gate : org2
    port map(
        i_A => s_Jump,
        i_B => s_and_branch_out,
        o_F => s_or_jump_out
    );

    bitExtend_or_ALU_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => s_ALU_Or_Imm_Jump,
        i_D0 => oALUOut,
        i_D1 => s_extended_imm,
        o_MuxOut => s_ALU_or_imm_shift_in
    );
    goblinBarrel_inst : goblinBarrel
    port map(
        data_in => s_out_rs1,
        shift_left_right => s_ALUControl,
        shift_amount => s_rs2_or_imm_mux_out(4 downto 0),
        data_out => s_out_shifted_data
    );

    ALU_BS_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => s_Shift,
        i_D0 => oALUOut,
        i_D1 => s_out_shifted_data,
        o_MuxOut => s_DMemAddr
    );

    pc_or_zero_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => s_Jump_With_Register,
        i_D0 => s_NextInstAddr,
        i_D1 => X"00000000",
        o_MuxOut => s_pc_or_zero_out
    );

    shift_jump_barrel : goblinBarrel
    port map(
        data_in => s_ALU_or_imm_shift_in,
        shift_left_right => "0111", 
        shift_amount => "00010",
        data_out => s_pc_word_shift_out
    );

    pc_or_branch_adder : Nbit_adder
    generic map(N =>32)
    port map(
        i_A  => s_pc_or_zero_out,
        i_B  => s_pc_word_shift_out,
        i_C  => '0',
        o_S  => s_pc_or_word_adder_out,
        o_C  => open
    );

    pc4_or_branch_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => s_or_jump_out,
        i_D0 => s_pc4_out,
        i_D1 => s_pc_or_word_adder_out,
        o_MuxOut => s_pc_data_in
    );

--TO DO: LINK MUX AND MEM TO REG MUX

    mux4t1_and_link_mux : mux4t1_32
    port map(
        i_S  => s_AndLink,
        i_X0 => oALUOut,
        i_X1 => s_pc_or_word_adder_out,
        i_X2 => s_flag_mux_out,
        i_X3 => s_pc4_out,
        o_X  => s_4t1_and_link_out
    );

    mem_to_reg_mux : mux2t1_N
    generic map(N =>32)
    port map(
        i_S => s_MemToReg,
        i_D0 => s_4t1_and_link_out,
        i_D1 => s_DMemOut,
        o_MuxOut => s_RegWrData
    );

    
end structure;


-- tb_control_unit_simple.vhd
library ieee;
use ieee.std_logic_1164.all;

entity tb_control_unit_simple is
end entity;

architecture sim of tb_control_unit_simple is
  -- DUT ports
  signal opcode   : std_logic_vector(6 downto 0);
  signal funct3   : std_logic_vector(2 downto 0);
  signal funct7   : std_logic_vector(6 downto 0);

  signal ALUSrc             : std_logic;
  signal ALUControl         : std_logic_vector(3 downto 0);
  signal ImmType            : std_logic_vector(1 downto 0);
  signal AndLink            : std_logic_vector(1 downto 0);
  signal MemWrite           : std_logic;
  signal RegWrite           : std_logic;
  signal MemToReg           : std_logic;
  signal Branch             : std_logic;
  signal Jump               : std_logic;
  signal ALU_Or_Imm_Jump    : std_logic;
  signal Flag_Mux           : std_logic_vector(1 downto 0);
  signal Flag_Or_Nflag      : std_logic;
  signal Jump_With_Register : std_logic;

  -- constants (match your control_unit)
  constant OP_I_Type  : std_logic_vector(6 downto 0) := "0010011";
  constant OP_R_Type  : std_logic_vector(6 downto 0) := "0110011";
  constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
  constant OP_STORE   : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";

  -- ALU ops (must match your ALUControl encodings)
  constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
  constant ALU_OR  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0010";
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0011";
  constant ALU_CMP : std_logic_vector(3 downto 0) := "0100"; -- SUB/compare
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_LUIc: std_logic_vector(3 downto 0) := "1000";

  -- ImmType encodings
  constant IMM_12S : std_logic_vector(1 downto 0) := "01";
  constant IMM_20U : std_logic_vector(1 downto 0) := "10";
  constant IMM_20S : std_logic_vector(1 downto 0) := "11";
begin
  -- DUT
  dut : entity work.control_unit
    port map (
      opcode, funct3, funct7,
      ALUSrc, ALUControl, ImmType, AndLink, MemWrite, RegWrite, MemToReg,
      Branch, Jump, ALU_Or_Imm_Jump, Flag_Mux, Flag_Or_Nflag, Jump_With_Register
    );

  -- Simple combinational stimulus
  stim : process
  begin
    ----------------------------------------------------------------
    -- R-type: ADD (funct3=000, funct7=0000000)
    ----------------------------------------------------------------
    opcode <= OP_R_Type; funct3 <= "000"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUControl = ALU_ADD        report "ADD: ALUControl" severity error;
    assert RegWrite   = '1'            report "ADD: RegWrite"   severity error;
    assert ALUSrc     = '0'            report "ADD: ALUSrc"     severity error;
    assert Branch     = '0' and Jump='0' report "ADD: Branch/Jump" severity error;
    assert MemWrite   = '0' and MemToReg='0' report "ADD: Mem" severity error;

    ----------------------------------------------------------------
    -- R-type: SUB (funct3=000, funct7=0100000)
    ----------------------------------------------------------------
    opcode <= OP_R_Type; funct3 <= "000"; funct7 <= "0100000";
    wait for 1 ns;
    assert ALUControl = ALU_CMP report "SUB: ALUControl" severity error;

    ----------------------------------------------------------------
    -- R-type: SRA (funct3=101, funct7=0100000)
    ----------------------------------------------------------------
    opcode <= OP_R_Type; funct3 <= "101"; funct7 <= "0100000";
    wait for 1 ns;
    assert ALUControl = ALU_SRA report "SRA: ALUControl" severity error;

    ----------------------------------------------------------------
    -- I-type: SLLI (funct3=001, funct7=0000000)
    ----------------------------------------------------------------
    opcode <= OP_I_Type; funct3 <= "001"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUSrc     = '1'      report "SLLI: ALUSrc" severity error;
    assert ALUControl = ALU_SLL  report "SLLI: ALUControl" severity error;
    assert RegWrite   = '1'      report "SLLI: RegWrite" severity error;
    assert ImmType    = IMM_12S  report "SLLI: ImmType" severity error;
    assert MemToReg   = '0'      report "SLLI: MemToReg" severity error;

    ----------------------------------------------------------------
    -- I-type: SRLI (funct3=101, funct7=0000000)
    ----------------------------------------------------------------
    opcode <= OP_I_Type; funct3 <= "101"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUControl = ALU_SRL report "SRLI: ALUControl" severity error;

    ----------------------------------------------------------------
    -- I-type: SRAI (funct3=101, funct7=0100000)
    ----------------------------------------------------------------
    opcode <= OP_I_Type; funct3 <= "101"; funct7 <= "0100000";
    wait for 1 ns;
    assert ALUControl = ALU_SRA report "SRAI: ALUControl" severity error;

    ----------------------------------------------------------------
    -- LUI
    ----------------------------------------------------------------
    opcode <= OP_LUI; funct3 <= "000"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUControl = ALU_LUIc report "LUI: ALUControl" severity error;
    assert ALUSrc     = '1'      report "LUI: ALUSrc"     severity error;
    assert RegWrite   = '1'      report "LUI: RegWrite"   severity error;
    assert MemToReg   = '1'      report "LUI: MemToReg"   severity error;
    assert ImmType    = IMM_20U  report "LUI: ImmType"    severity error;

    ----------------------------------------------------------------
    -- AUIPC
    ----------------------------------------------------------------
    opcode <= OP_AUIPC; funct3 <= "000"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUControl      = ALU_ADD report "AUIPC: ALUControl" severity error;
    assert RegWrite        = '1'     report "AUIPC: RegWrite"   severity error;
    assert ALU_Or_Imm_Jump = '1'     report "AUIPC: ALU_Or_Imm_Jump" severity error;
    assert ImmType         = IMM_20S report "AUIPC: ImmType"    severity error;
    assert MemToReg        = '0'     report "AUIPC: MemToReg"   severity error;

    ----------------------------------------------------------------
    -- LOAD (e.g., LW)
    ----------------------------------------------------------------
    opcode <= OP_LOAD; funct3 <= "010"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUSrc   = '1' report "LOAD: ALUSrc" severity error;
    assert RegWrite = '1' report "LOAD: RegWrite" severity error;
    assert MemToReg = '1' report "LOAD: MemToReg" severity error;
    assert MemWrite = '0' report "LOAD: MemWrite" severity error;
    assert ALUControl = ALU_ADD report "LOAD: ALUControl" severity error;

    ----------------------------------------------------------------
    -- STORE (e.g., SW)
    ----------------------------------------------------------------
    opcode <= OP_STORE; funct3 <= "010"; funct7 <= "0000000";
    wait for 1 ns;
    assert ALUSrc   = '1' report "STORE: ALUSrc" severity error;
    assert RegWrite = '0' report "STORE: RegWrite" severity error;
    assert MemWrite = '1' report "STORE: MemWrite" severity error;
    assert ALUControl = ALU_ADD report "STORE: ALUControl" severity error;

    ----------------------------------------------------------------
    -- BRANCH: BEQ (funct3=000)
    ----------------------------------------------------------------
    opcode <= OP_BRANCH; funct3 <= "000"; funct7 <= "0000000";
    wait for 1 ns;
    assert Branch        = '1'    report "BEQ: Branch" severity error;
    assert Flag_Mux      = "11"   report "BEQ: Flag_Mux (ZERO)" severity error; -- ZERO
    assert Flag_Or_Nflag = '0'    report "BEQ: Flag_Or_Nflag" severity error;
    assert RegWrite      = '0'    report "BEQ: RegWrite" severity error;

    ----------------------------------------------------------------
    -- BRANCH: BNE (funct3=001)
    ----------------------------------------------------------------
    opcode <= OP_BRANCH; funct3 <= "001"; funct7 <= "0000000";
    wait for 1 ns;
    assert Branch        = '1'    report "BNE: Branch" severity error;
    assert Flag_Mux      = "11"   report "BNE: Flag_Mux (ZERO)" severity error; -- ZERO
    assert Flag_Or_Nflag = '1'    report "BNE: Flag_Or_Nflag invert" severity error;

    ----------------------------------------------------------------
    -- JAL
    ----------------------------------------------------------------
    opcode <= OP_JAL; funct3 <= "000"; funct7 <= "0000000";
    wait for 1 ns;
    assert Jump            = '1'   report "JAL: Jump" severity error;
    assert AndLink         = "01"  report "JAL: AndLink" severity error;
    assert Jump_With_Register = '0' report "JAL: Jump_With_Register" severity error;
    assert ALU_Or_Imm_Jump = '1'   report "JAL: ALU_Or_Imm_Jump" severity error;
    assert RegWrite        = '1'   report "JAL: RegWrite" severity error;

    ----------------------------------------------------------------
    -- JALR
    ----------------------------------------------------------------
    opcode <= OP_JALR; funct3 <= "000"; funct7 <= "0000000";
    wait for 1 ns;
    assert Jump            = '1'   report "JALR: Jump" severity error;
    assert AndLink         = "01"  report "JALR: AndLink" severity error;
    assert Jump_With_Register = '1' report "JALR: Jump_With_Register" severity error;
    assert ALUSrc          = '1'   report "JALR: ALUSrc" severity error;
    assert ALU_Or_Imm_Jump = '0'   report "JALR: ALU_Or_Imm_Jump" severity error;

    report "tb_control_unit_simple: DONE (check for any ERRORs above)" severity note;
    wait;
  end process;
end architecture;


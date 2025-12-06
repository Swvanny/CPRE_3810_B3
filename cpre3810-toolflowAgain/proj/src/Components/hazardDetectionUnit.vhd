library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazardDetectUnit is 
    port(
        rs1_IFID, rs2_IFID      : in std_logic_vector(4 downto 0);  -- source regs (typically IF/ID.rs1/rs2)
        rd_IDEX               : in std_logic_vector(4 downto 0);  -- dest reg in EX stage (ID/EX.rd)
        rd_EXMEM               : in std_logic_vector(4 downto 0);  -- dest reg in MEM/WB
        memRead_IDEX           : in std_logic;                     -- MemRead for EX stage (ID/EX.MemRead)
        memRead_EXMEM           : in std_logic;                     -- MemRead for MEM/WB (often unused)

        branch_taken            : in std_logic;                     -- asserted when branch/jump is taken

        -- Outputs
        stall_IFID              : out std_logic;  -- control for IF/ID (stall/flush)
        flush_IDEX              : out std_logic   -- control for ID/EX (bubble)
    );
end entity;

architecture Structural of hazardDetectUnit is

    component org2 is
      port(i_A : in std_logic;
           i_B : in std_logic;
           o_F : out std_logic);
    end component;

    component andg2 is
      port(i_A : in std_logic;
           i_B : in std_logic;
           o_F : out std_logic);
    end component;

    -- Equality flags
    signal rs1_eq_EXMEM, rs2_eq_EXMEM : std_logic;
    signal rs1_eq_IDEX, rs2_eq_IDEX : std_logic;

    -- Combined match flags
    signal rs_match_ID : std_logic;
    signal rs_match_EX : std_logic;

    -- Load-use hazard flags
    signal load_use_ID  : std_logic;
    signal load_use_EX : std_logic;

    -- Combined load hazard
    signal load_hazard  : std_logic;

    -- Combined hazard / branch
    signal hazard_or_branch : std_logic;

begin

    --------------------------------------------------------------------
    -- Compare IF/ID source regs to EX dest (rd_EXMEM) and MEM/WB dest.
    --------------------------------------------------------------------
    rs1_eq_IDEX <= '1' when (rs1_IFID = rd_IDEX and rd_IDEX /= "00000") else '0';
    rs2_eq_IDEX <= '1' when (rs2_IFID = rd_IDEX and rd_IDEX /= "00000") else '0';

    rs1_eq_EXMEM <= '1' when (rs1_IFID = rd_EXMEM and rd_EXMEM /= "00000") else '0';
    rs2_eq_EXMEM <= '1' when (rs2_IFID = rd_EXMEM and rd_EXMEM /= "00000") else '0';

    -- OR matches in EX stage
    EX_MATCH_OR: org2
        port map(
            i_A => rs1_eq_IDEX,
            i_B => rs2_eq_IDEX,
            o_F => rs_match_ID
        );

    -- OR matches in MEM/WB stage
    MEM_MATCH_OR: org2
        port map(
            i_A => rs1_eq_EXMEM,
            i_B => rs2_eq_EXMEM,
            o_F => rs_match_EX
        );

    --------------------------------------------------------------------
    -- Load-use hazards from EX and MEM/WB
    --------------------------------------------------------------------
    LOAD_EX_AND: andg2
        port map(
            i_A => memRead_EXMEM,
            i_B => rs_match_EX,
            o_F => load_use_EX
        );

    LOAD_ID_AND: andg2
        port map(
            i_A => memRead_IDEX,
            i_B => rs_match_ID,
            o_F => load_use_ID
        );

    -- Combine load hazards (EX or MEM/WB)
    LOAD_HAZARD_OR: org2
        port map(
            i_A => load_use_EX,
            i_B => load_use_ID,
            o_F => load_hazard
        );

    --------------------------------------------------------------------
    -- Combine load hazard with branch_taken
    --------------------------------------------------------------------
    HAZARD_BRANCH_OR: org2
        port map(
            i_A => load_hazard,
            i_B => branch_taken,
            o_F => hazard_or_branch
        );

    -- Drive outputs
    stall_IFID <= hazard_or_branch;
    flush_IDEX <= hazard_or_branch;

end architecture Structural;
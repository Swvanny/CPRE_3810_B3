library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazardDetectUnit is 
port(
        rs1_IDEX, rs2_IDEX      : in std_logic_vector(4 downto 0);  -- Registers used in ID/EX stage (for register operands)
        rd_EXMEM                : in std_logic_vector(4 downto 0);  -- Destination register from EX/MEM stage (to check if write-back happens)
        rd_MEMWB                : in std_logic_vector(4 downto 0);  -- Destination register from MEM/WB stage (to check if write-back happens)
        memRead_EXMEM           : in std_logic;                    -- EXMEM stage: signal indicating memory read (load)
        memRead_MEMWB           : in std_logic;                    -- MEMWB stage: signal indicating memory read (load)

         branch_taken   : in std_logic;

        -- Outputs
        stall_Fwd                : out std_logic;  -- Stall signal to control forwarding logic
        stall_IFID               : out std_logic;  -- Stall signal for IF/ID register (flush or hold)
        flush_IDEX               : out std_logic   -- Flush the ID/EX register (e.g., on a control hazard)
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
    signal rs1_eq_MEMWB, rs2_eq_MEMWB : std_logic;

    -- Combined match flags
    signal rs_match_EX  : std_logic;
    signal rs_match_MEM : std_logic;

    -- Load-use hazard flags
    signal load_use_EX  : std_logic;
    signal load_use_MEM : std_logic;

    -- Internal control lines
    signal stall_IFID_int : std_logic;
    signal stall_Fwd_int  : std_logic;
    signal flush_IDEX_int : std_logic;

begin

    rs1_eq_EXMEM <= '1' when (rs1_IDEX = rd_EXMEM and rd_EXMEM /= "00000") else '0';
    rs2_eq_EXMEM <= '1' when (rs2_IDEX = rd_EXMEM and rd_EXMEM /= "00000") else '0';

    rs1_eq_MEMWB <= '1' when (rs1_IDEX = rd_MEMWB and rd_MEMWB /= "00000") else '0';
    rs2_eq_MEMWB <= '1' when (rs2_IDEX = rd_MEMWB and rd_MEMWB /= "00000") else '0';


    EX_MATCH_OR: org2
        port map(
            i_A => rs1_eq_EXMEM,
            i_B => rs2_eq_EXMEM,
            o_F => rs_match_EX
        );


    MEM_MATCH_OR: org2
        port map(
            i_A => rs1_eq_MEMWB,
            i_B => rs2_eq_MEMWB,
            o_F => rs_match_MEM
        );


    LOAD_EX_AND: andg2
        port map(
            i_A => memRead_EXMEM,
            i_B => rs_match_EX,
            o_F => load_use_EX
        );


    LOAD_MEM_AND: andg2
        port map(
            i_A => memRead_MEMWB,
            i_B => rs_match_MEM,
            o_F => load_use_MEM
        );


    STALL_OR: org2
        port map(
            i_A => load_use_EX,
            i_B => load_use_MEM,
            o_F => stall_IFID_int
        );

    stall_IFID <= stall_IFID_int;

    flush_IDEX_int <= branch_taken;
    flush_IDEX     <= flush_IDEX_int;


    FWD_OR: org2
        port map(
            i_A => rs1_eq_EXMEM,
            i_B => rs2_eq_EXMEM,
            o_F => stall_Fwd_int
        );

    stall_Fwd <= stall_Fwd_int;

end architecture Structural;

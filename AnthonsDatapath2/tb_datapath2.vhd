library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.reg_array.all;

entity tb_dataRegister2 is
end tb_dataRegister2;

architecture behavior of tb_dataRegister2 is

    component dataPathFull
        generic(N : integer := 32);
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
       o_rs1_debug : out std_logic_vector(31 downto 0);
       o_rs2_debug :  out std_logic_vector(31 downto 0);
       o_CAS           : out std_logic;  
       o_fin_out           : out std_logic_vector(N-1 downto 0)
        );
    end component;


  signal i_clk          : std_logic := '0';
  signal i_rst          : std_logic := '1';
  signal i_writeAddr    : std_logic_vector(4 downto 0);
  signal i_writeEn      : std_logic;
  signal i_data_in      : std_logic_vector(31 downto 0);
  signal i_rs1          : std_logic_vector(4 downto 0);
  signal i_rs2          : std_logic_vector(4 downto 0);
  signal i_memWrite     : std_logic := '0';
  signal i_extend_ctrl  : std_logic := '0';  
  signal i_ALU_mem_sel  : std_logic := '1';  
  signal i_ALUsrc       : std_logic := '1';  
  signal i_Imm          : std_logic_vector(11 downto 0);
  signal i_AddSub       : std_logic := '0'; 
  signal i_CAS          : std_logic := '0';
  signal o_CAS          : std_logic;
  signal o_rs1_debug :  std_logic_vector(31 downto 0);
  signal o_rs2_debug :  std_logic_vector(31 downto 0);
  signal o_fin_out      : std_logic_vector(31 downto 0);



constant clk_period : time := 10 ns;

begin

  
    uut: dataPathFull
        generic map(N => 32)
        port map(
     i_clk       => i_clk,
      i_rst       => i_rst,
      i_writeAddr => i_writeAddr,
      i_writeEn   => i_writeEn,
      i_data_in   => i_data_in,
      i_rs1       => i_rs1,
      i_rs2       => i_rs2,
      i_memWrite  => i_memWrite,
      i_extend_ctrl => i_extend_ctrl,
      i_ALU_mem_sel => i_ALU_mem_sel,
      i_ALUsrc    => i_ALUsrc,
      i_Imm       => i_Imm,
      i_AddSub    => i_AddSub,
      i_CAS       => i_CAS,
      o_CAS       => o_CAS,
      o_rs1_debug => o_rs1_debug,
      o_rs2_debug => o_rs2_debug,
      o_fin_out   => o_fin_out
        );




clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for 5 ns;
            i_clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

        stimulus : process
begin
  
-- Initialization
i_rst <= '1';
wait for 10 ns;
i_rst <= '0';

    
  -- Set up ALU to compute x0 + 0 => 0
i_rs1 <= (others => '0'); -- rs1 = x0
i_rs2 <= (others => '0'); -- rs2 = don't care
i_Imm <= std_logic_vector(to_unsigned(0, 12));
i_ALUsrc <= '1'; -- use immediate
i_ALU_mem_sel <= '1'; -- select ALU result
i_AddSub <= '0'; -- addition
i_extend_ctrl <= '0'; -- zero extend
i_memWrite <= '0';

wait for 10 ns; -- let ALU compute

-- Now store result in register x25
i_writeAddr <= std_logic_vector(to_unsigned(25, 5));
i_data_in <= o_fin_out;
i_writeEn <= '1';
wait for 10 ns;
i_writeEn <= '0';
wait for 10 ns;


-- Step 1: Set up ALU inputs
i_rs1 <= "00000"; -- x0
i_Imm <= std_logic_vector(to_unsigned(256, 12));
i_ALUsrc <= '1'; -- use immediate
i_ALU_mem_sel <= '1'; -- use ALU output
i_AddSub <= '0'; -- add
i_extend_ctrl <= '0'; -- zero-extend
i_memWrite <= '0';
i_writeEn <= '0'; -- not writing yet

wait for 10 ns; -- let ALU output settle

-- Step 2: Store result of ALU (o_fin_out) into x26
i_writeAddr <= std_logic_vector(to_unsigned(26, 5)); -- x26
i_rs1 <= std_logic_vector(to_unsigned(26, 5));
i_data_in <= o_fin_out;
i_writeEn <= '1';
wait for 10 ns;
i_writeEn <= '0';
wait for 10 ns;



    -- Test 3: lw 1, 0(26)
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_rs2 <= "00000";
    i_Imm <= std_logic_vector(to_unsigned(0, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0'; -- select memory output
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 4: lw 2, 4(26)
    i_writeAddr <= std_logic_vector(to_unsigned(2, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_Imm <= std_logic_vector(to_unsigned(4, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 5: add 1, 1, 2
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(1, 5));
    i_rs2 <= std_logic_vector(to_unsigned(2, 5));
    i_ALUsrc <= '0';  -- select rs2
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 6: sw 1, 0(26)
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_unsigned(0, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    -- Test 7: lw 2, 8(25)
    i_writeAddr <= std_logic_vector(to_unsigned(2, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(25, 5));
    i_Imm <= std_logic_vector(to_unsigned(8, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 8: add 1, 1, 2
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(1, 5));
    i_rs2 <= std_logic_vector(to_unsigned(2, 5));
    i_ALUsrc <= '0';
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 9: sw 1, 4(26)
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_unsigned(4, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    -- Test 10: lw 2, 12(25)
    i_writeAddr <= std_logic_vector(to_unsigned(2, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(25, 5));
    i_Imm <= std_logic_vector(to_unsigned(12, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 11: add 1, 1, 2
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(1, 5));
    i_rs2 <= std_logic_vector(to_unsigned(2, 5));
    i_ALUsrc <= '0';
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 12: sw 1, 8(26)
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_unsigned(8, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    -- Test 13: lw 2, 16(25)
    i_writeAddr <= std_logic_vector(to_unsigned(2, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(25, 5));
    i_Imm <= std_logic_vector(to_unsigned(16, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 14: add 1, 1, 2
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(1, 5));
    i_rs2 <= std_logic_vector(to_unsigned(2, 5));
    i_ALUsrc <= '0';
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 15: sw 1, 12(26)
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_unsigned(12, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    -- Test 16: lw 2, 20(25)
    i_writeAddr <= std_logic_vector(to_unsigned(2, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(25, 5));
    i_Imm <= std_logic_vector(to_unsigned(20, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 17: add 1, 1, 2
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(1, 5));
    i_rs2 <= std_logic_vector(to_unsigned(2, 5));
    i_ALUsrc <= '0';
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 18: sw 1, 16(26)
    i_rs1 <= std_logic_vector(to_unsigned(26, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_unsigned(16, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    -- Test 19: lw 2, 24(25)
    i_writeAddr <= std_logic_vector(to_unsigned(2, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(25, 5));
    i_Imm <= std_logic_vector(to_unsigned(24, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 20: add 1, 1, 2
    i_writeAddr <= std_logic_vector(to_unsigned(1, 5));
    i_writeEn <= '1';
    i_rs1 <= std_logic_vector(to_unsigned(1, 5));
    i_rs2 <= std_logic_vector(to_unsigned(2, 5));
    i_ALUsrc <= '0';
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 21: addi 27, zero, 512
    i_writeAddr <= std_logic_vector(to_unsigned(27, 5));
    i_writeEn <= '1';
    i_rs1 <= (others => '0');
    i_rs2 <= (others => '0');
    i_Imm <= std_logic_vector(to_unsigned(512, 12));
    i_ALUsrc <= '1';
    i_ALU_mem_sel <= '1';
    i_AddSub <= '0';
    i_memWrite <= '0';
    i_extend_ctrl <= '0';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_writeEn <= '0';
    wait for 10 ns;

    -- Test 22: sw 1, -4(27)
    i_rs1 <= std_logic_vector(to_unsigned(27, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_signed(-4, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    -- Test 23: sw 1, -4(27)
    i_rs1 <= std_logic_vector(to_unsigned(27, 5));
    i_rs2 <= std_logic_vector(to_unsigned(1, 5));
    i_Imm <= std_logic_vector(to_signed(-4, 12));
    i_ALUsrc <= '1';
    i_memWrite <= '1';
    wait for 10 ns;
    i_data_in <= o_fin_out;
    wait for 10 ns;
    i_memWrite <= '0';
    wait for 10 ns;

    wait; -- End simulation
end process;
end behavior;

--test cases written by chat gpt 4 using "using this style write the rest of the following tests"
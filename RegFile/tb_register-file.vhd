library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.reg_array.all;

entity tb_registerFile is
end tb_registerFile;

architecture behavior of tb_registerFile is

    component registerFile
        port(
            i_clk        : in std_logic;
            i_rst        : in std_logic;
            i_writeAddr  : in std_logic_vector(4 downto 0);
            i_writeEn    : in std_logic;
            i_data_in    : in std_logic_vector(31 downto 0);
            i_rs1        : in std_logic_vector(4 downto 0);
            i_rs2        : in std_logic_vector(4 downto 0);
            o_rs1        : out std_logic_vector(31 downto 0);
            o_rs2        : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals for DUT
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal writeAddr   : std_logic_vector(4 downto 0);
    signal writeEn     : std_logic;
    signal data_in     : std_logic_vector(31 downto 0);
    signal rs1         : std_logic_vector(4 downto 0);
    signal rs2         : std_logic_vector(4 downto 0);
    signal rs1_out     : std_logic_vector(31 downto 0);
    signal rs2_out     : std_logic_vector(31 downto 0);

    -- Clock generation
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    dut : registerFile
        port map (
            i_clk       => clk,
            i_rst       => rst,
            i_writeAddr => writeAddr,
            i_writeEn   => writeEn,
            i_data_in   => data_in,
            i_rs1       => rs1,
            i_rs2       => rs2,
            o_rs1       => rs1_out,
            o_rs2       => rs2_out
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

   
     stimulus : process
    begin
        -- Initial reset (at start of simulation)
        writeAddr <= "00000";
        rs1 <= "00000";
        rs2 <= "00000";
        data_in <= X"00000000";  -- Initial value

        rst <= '1';
        wait for clk_period; 
        rst <= '0';
        wait for clk_period;  

        -----------------------------------------------------
       
        writeAddr <= "00001";
        data_in   <= X"DECAFFFF";
        writeEn   <= '1';    
        wait for clk_period / 2;  
        
      
        writeEn   <= '0';
        wait for clk_period;  -- Allow another clock cycle for the value to propagate

  
        rs1 <= "00001";
        wait for clk_period;  -- Wait for a clock cycle to read data
      

        -----------------------------------------------------
       
        writeAddr <= "00010";
        data_in   <= X"CAFEBABE";
        writeEn   <= '1';
        wait for clk_period;  

       
        writeEn   <= '0';
        wait for clk_period;  -- Allow another clock cycle for propagation

        -- Read from register 2 (rs2 = 00010)
        rs2 <= "00010";
        wait for clk_period;
         

        -----------------------------------------------------
    
        writeAddr <= "00011";
        data_in   <= X"FFFFFFFF";
        writeEn   <= '1';
        wait for clk_period ;

       
        writeEn   <= '0';
        wait for clk_period;
        

        
        rs1 <= "00010";
        rs2 <= "00011";
        wait for clk_period;
   

        -----------------------------------------------------
       
        writeAddr <= "00000";
        data_in   <= X"11111111";
        writeEn   <= '1';
        wait for clk_period;
        
        writeEn <= '0';
        wait for clk_period;

        rs1 <= "00000";
        rs2 <= "00000";
        wait for clk_period;
  

       
        wait;
    end process;

end behavior;
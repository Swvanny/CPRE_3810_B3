library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity goblinBarrel_tb is
end goblinBarrel_tb;

architecture Behavioral of goblinBarrel_tb is

    
    component goblinBarrel is
        port (
            data_in           : in  std_logic_vector(31 downto 0);
            shift_left_right  : in  std_logic_vector(3 downto 0); -- 00 = SLL, 01 = SRL, 10 = SRA(outdated)
            shift_amount      : in  std_logic_vector(4 downto 0);
            data_out          : out std_logic_vector(31 downto 0)
        );
    end component;


    signal tb_data_in          : std_logic_vector(31 downto 0);
    signal tb_shift_left_right : std_logic_vector(3 downto 0);
    signal tb_shift_amount     : std_logic_vector(4 downto 0);
    signal tb_data_out         : std_logic_vector(31 downto 0);

begin


    uut: goblinBarrel
        port map (
            data_in          => tb_data_in,
            shift_left_right => tb_shift_left_right,
            shift_amount     => tb_shift_amount,
            data_out         => tb_data_out
        );

   
    stimulus: process
    begin
        -- Wait for global reset
        wait for 10 ns;

  
        -- TEST 1: Logical Left Shift (SLL)
    
        tb_data_in <= x"00000001";         -- 0b...0001
        tb_shift_left_right <= "0111";       -- SLL
        tb_shift_amount <= "00001";      
        wait for 20 ns;

        tb_data_in <= x"00000001";
        tb_shift_amount <= "00100";       
        wait for 20 ns;

        tb_data_in <= x"80000000";
        tb_shift_amount <= "00001";       
        wait for 20 ns;

        
        -- TEST 2: Logical Right Shift (SRL)
        
        tb_data_in <= x"80000000";
        tb_shift_left_right <= "0101";       -- SRL
        tb_shift_amount <= "00001";        
        wait for 20 ns;

        tb_data_in <= x"F0000000";
        tb_shift_amount <= "00100";        
        wait for 20 ns;

       
        -- TEST 3: Arithmetic Right Shift (SRA)
       
        tb_data_in <= x"F0000000";         -- Negative number (MSB = 1)
        tb_shift_left_right <= "0110";       -- SRA
        tb_shift_amount <= "00001";        
        wait for 20 ns;

        tb_shift_amount <= "00100";        
        wait for 20 ns;

        tb_data_in <= x"00000001";         -- Positive number (MSB = 0)
        tb_shift_amount <= "00100";        
        wait for 20 ns;

     
        wait;
    end process;

end Behavioral;
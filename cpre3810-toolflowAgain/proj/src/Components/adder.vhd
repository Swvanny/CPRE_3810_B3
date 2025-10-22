-------------------------------------------------------------------------
-- Anthon Worsham
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- andg2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is my 2:1 mux
--
--
-- NOTES:

-------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;

entity adder is 
      port (
        i_D0 : in std_logic;
        i_D1 : in std_logic;
        i_C : in std_logic;
        oC : out std_logic;
        o_O : out std_logic
      );
      end adder;

      architecture Structural of adder is
      
        component andg2
          port ( 
            i_A : in std_logic;
             i_B : in std_logic;
             o_F: out std_logic
        
          );

          end component;

      component org2
          port ( 
            i_A : in std_logic;
             i_B : in std_logic;
             o_F: out std_logic
        
          );

          end component;
      component xorg2
          port (
      i_A   : in std_logic;
      i_B   : in std_logic;
      o_F  : out std_logic);
       end component;


    
        signal and1_out : std_logic;
        signal and2_out : std_logic;
        signal xor1_out : std_logic;

      begin
       

      P1: andg2 port map (
          i_A => i_D0,
          i_B => i_D1,
          o_F => and1_out
      );
      P2: xorg2 port map ( 
          i_A => i_D0,
          i_B => i_D1,
          o_F => xor1_out
      );
      P3: andg2 port map ( 
          i_A => i_C,
          i_B => xor1_out,
          o_F => and2_out
      );
      P4: xorg2 port map ( 
          i_A => xor1_out,
          i_B => i_C,
          o_F => o_O
      );
      
      P5: org2 port map ( 
          i_A => and2_out,
          i_B => and1_out,
          o_F => oC
      );
      
      


      end Structural;
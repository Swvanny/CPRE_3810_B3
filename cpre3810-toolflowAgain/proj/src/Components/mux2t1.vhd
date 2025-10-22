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

entity mux2t1 is 
      port (
        i_X0 : in std_logic;
        i_X1 : in std_logic;
        i_S : in std_logic;
        o_X : out std_logic
      );
      end mux2t1;

      architecture Structural of mux2t1 is
      
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

      component invg
          port ( 
            i_A : in std_logic;
             o_F: out std_logic
    
          );
          end component;

          signal not_sel : std_logic;
           signal and1_out : std_logic;
         signal and2_out : std_logic;

      begin
        P1: invg port map (
          i_A => i_S,
          o_F => not_sel
      );

      P2: andg2 port map (
          i_A => i_X0,
          i_B => not_sel,
          o_F => and1_out
      );

      P3: andg2 port map (
          i_A => i_X1,
          i_B => i_S,
          o_F => and2_out
      );
      
      P4: org2 port map (
          i_A => and1_out,
          i_B => and2_out,
          o_F => o_X
      );


      end Structural;
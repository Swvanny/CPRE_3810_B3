-------------------------------------------------------------------------
-- Drew Swanson
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

  entity mux2t1_dataflow is
    port(SEL                  : in std_logic;
         iA                 : in std_logic;
         iB                 : in std_logic;
         OUTPUT                  : out std_logic);
  end mux2t1_dataflow;
  
  architecture dataflow of mux2t1_dataflow is
begin
  --if Sel == 1, Y == B, else if Sel ==0, Y == A, else X
  OUTPUT <= iB when Sel = '1' else
       iA when Sel = '0' else
       'X';
end dataflow;

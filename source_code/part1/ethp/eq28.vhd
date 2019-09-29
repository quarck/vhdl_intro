library ieee;
use ieee.std_logic_1164.all;
entity eq28 is 
	port ( 
		v 		: in std_logic_vector(4 downto 0);
		eq		: out std_logic
		);
end eq28;
architecture dataflow of eq28 is 
begin
	eq <= (not v(0)) and (not v(1)) and v(2) and v(3) and v(4);
end;

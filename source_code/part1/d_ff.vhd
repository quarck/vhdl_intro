
library ieee;
use ieee.std_logic_1164.all;

entity d_ff is 
	port (
		x, clk 	: 	in 	std_logic; 
		z			: 	out	std_logic
);
end d_ff;

architecture behavior of d_ff is 
begin
 
	z <= x when clk = '1' and clk'event;
	
	-- process (x, clk) 
	-- begin 
	--	if clk'event and clk = '1' then 
	--		z <= x;
	--	end if; 
	--end process;
end behavior;

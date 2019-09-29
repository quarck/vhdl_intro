
library ieee;
use ieee.std_logic_1164.all;

entity fsm is 
	port (
		x, clk 	: 	in 	std_logic; 
		z		: 	out	std_logic
);
end fsm;

architecture fsm_behavior of fsm is 
	type state_type is (S0, S1, S2, S3); 
	signal y: state_type;
begin 
	process (clk) 
	begin 
		if clk'event and clk = '1' then 
			case y is
				when S0 => 
					if x = '1' then y <= S1; 
					else y <= S0; 
					end if;
					
				when S1 => 
					if x = '1' then y <= S2; 
					else y <= S0; 
					end if;
				
				when S2 =>
					if x = '1' then y <= S3; 
					else y <= S0; 
					end if;
				
				when S3 =>
					if x = '1' then y <= S3; 
					else y <= S0; 
					end if;				
			end case;
		end if; 
	end process;
	
	z <= '1' when y = S3 else '0';

end fsm_behavior;

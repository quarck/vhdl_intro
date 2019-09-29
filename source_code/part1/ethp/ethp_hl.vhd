library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ethp_hl is 
	port (
		x, clk 	: 	in 	std_logic; 
		o			: 	out	std_logic);
end ethp_hl;
architecture beh of ethp_hl is 
	type machine_state is (IDLE, SEEN_1, SEEN_0, DETECTED_PATTERN); 	
	signal state	: machine_state;
	signal counter	: std_logic_vector(4 downto 0) := "00000"; 
begin 
	process (clk, x) 
	begin 
		if rising_edge(clk) then 
			case state is
				when IDLE => 
					counter <= "00000";
					if x = '1' then state <= SEEN_1; end if;
				when SEEN_1 => 
					if x = '0' then 
						state <= SEEN_0;
						counter <= counter + 1;
					else 
						state <= IDLE;
					end if; 
				when SEEN_0 =>
					if counter = 28 then
						state <= DETECTED_PATTERN; 
					elsif x = '1' then 
						state <= SEEN_1;
					else 
						state <= IDLE;
					end if;
				when DETECTED_PATTERN =>
					state <= IDLE;
			end case;
		end if; 
	end process;
	o <= '1' when state = DETECTED_PATTERN else '0';
end beh;

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;

entity sevenseg is
	port
	(
		clk						: in std_logic; 
		rst						: in std_logic;
		segment_select			: in std_logic_vector(7 downto 0); -- binary encoded 
		segments_active_high	: in std_logic_vector(7 downto 0);
		sel_port_out			: out std_logic_vector(7 downto 0);
		data_port_out			: out std_logic_vector(7 downto 0)
	);
end sevenseg;



architecture behaviour of sevenseg is	
	
	subtype counter_type is integer range 0 to 4095;	
	type seven_seg_state is ( DISPLAYING_DG_0, DISPLAYING_DG_1, DISPLAYING_DG_2 );
	type digits_array is array (2 downto 0) of std_logic_vector(7 downto 0); 

	signal counter: counter_type := 0;

	signal state : seven_seg_state := DISPLAYING_DG_0;
	signal digits : digits_array := (others => (others => '0')); 	
begin
	-- first process - state machine handling output refreshes
	process (clk)
	begin
		if rst = '1' then 
			counter <= 0;
			state <= DISPLAYING_DG_0;
		elsif rising_edge(clk) then 
			-- defaults to prevent extra ff
			sel_port_out <= "00000001";
			data_port_out <= digits(0);
			
			case state is 
				when DISPLAYING_DG_0 => 
					sel_port_out <= "00000001";
					data_port_out <= digits(0);

					if counter = counter_type'high then 
						counter <= 0;
						state <= DISPLAYING_DG_1;
					else
						counter <= counter + 1;
					end if;

				when DISPLAYING_DG_1 => 
					sel_port_out <= "00000010";
					data_port_out <= digits(1);

					if counter = counter_type'high then 
						counter <= 0;
						state <= DISPLAYING_DG_2;
					else
						counter <= counter + 1;
					end if;
					
				when DISPLAYING_DG_2 => 
					sel_port_out <= "00000100";
					data_port_out <= digits(2);

					if counter = counter_type'high then 
						counter <= 0;
						state <= DISPLAYING_DG_0;
					else
						counter <= counter + 1;
					end if;
					
				when others => 
					state <= DISPLAYING_DG_0;
			end case;
		end if;		
	end process;

	-- second process - handling internal register updates 
	process (clk, segment_select, segments_active_high)
		variable idx : integer := 0;
	begin
		if rst = '1' then 
			digits <= (others => (others => '0'));
		elsif rising_edge(clk) then 

			idx := to_integer(unsigned(segment_select(1 downto 0)));
			if idx >= 0 and idx <= 2 then 
				digits(idx) <= not segments_active_high; -- it should be active low on the wire
			end if;

			
-- 			case segment_select(1 downto 0) is 
-- 				when "00" =>  digits(0) <= not segments_active_high; -- it should be active low on the wire
-- 				when "01" =>  digits(1) <= not segments_active_high; 
-- 				when "10" =>  digits(2) <= not segments_active_high; 
-- 				when  others =>
-- 			end case;
			
		end if;		
	end process;

end behaviour;

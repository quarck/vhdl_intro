library ieee;
use ieee.std_logic_1164.all;

entity TB is
end TB;

architecture behavior of TB is
    -- Component Declaration for the Unit Under Test (UUT)
   component ethp_hl is 
		port (
			x, clk 	: 	in 	std_logic; 
			o		: 	out	std_logic);
	end component;
	component ethp is 
		port (
			x, clk 	: 	in 	std_logic; 
			o		: 	out	std_logic);
	end component;
	--Inputs
	signal x : std_logic := '0';
	signal clk : std_logic := '0';
	signal z_ll : std_logic := '0';
	signal z_hl : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns; 
begin
 	-- Instantiate the Unit(s) Under Test (UUT)
	uut0: ethp_hl PORT MAP (x => x, clk => clk, o => z_hl); -- high level impl
	uut1: ethp PORT MAP (x => x, clk => clk, o => z_ll); -- low level impl

	clock_process: process -- clock generator process 
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

   stim_proc: process   -- Stimulus process
   begin		
      -- hold reset state for 100 ns.
		wait for 100 ns;	
		wait for clk_period*10; -- and a few more
		wait for clk_period/4;  -- offset from the clock edge
		for repeat in 1 to 2 loop		
			for i in 1 to 28 loop
				x <= '1'; 
				wait for clk_period;		
				x <= '0';		
				wait for clk_period;		
			end loop;
			for i in 1 to 20 loop
				x <= '0'; 
				wait for clk_period;		
			end loop;
		end loop;
      wait;
   end process;
end;

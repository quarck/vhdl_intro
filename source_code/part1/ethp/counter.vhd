library ieee;
use ieee.std_logic_1164.all;
entity counter is 
	port ( 
		enable		: in std_logic; 
		clk			: in std_logic;
		reset		: in std_logic;
		cnt 		: out std_logic_vector(4 downto 0));
end counter;
architecture dataflow of counter is 
	signal q 		: std_logic_vector(4 downto 0) := "00000"; 
	signal toggle	: std_logic_vector(4 downto 0) := "00000";	
begin
	toggle(0) <= enable;
	-- The "for-generate" statement would have the same effect as 
	-- a sequence of individual assignments: 
	-- toggle(1) <= toggle(0) and q(0);
	-- toggle(2) <= toggle(0) and q(0) and q(1);
	-- toggle(3) <= toggle(0) and q(0) and q(1) and q(2);
	-- toggle(4) <= toggle(0) and q(0) and q(1) and q(2) and q(3);
	gen_toggle:
	for i in 1 to 4 generate 
		toggle(i) <= toggle(i-1) and q(i-1);
	end generate gen_toggle;		
	gen_cnt: -- would normally have a blank line, but this is powerpoint!
	for i in 0 to 4 generate 
		q(i) <= '0' when reset = '1' else 
				  (q(i) xor toggle(i)) when rising_edge(clk);
	end generate gen_cnt;
	cnt <= q;
end;

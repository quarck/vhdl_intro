library ieee;
use ieee.std_logic_1164.all;
entity ethp is 
	port (
		x, clk 	: 	in 	std_logic; 
		o		: 	out	std_logic);
end ethp;
architecture structural of ethp is 	
	component counter is 
		port ( 
			enable		: in std_logic; 
			clk			: in std_logic;
			reset		: in std_logic;
			cnt 		: out std_logic_vector(4 downto 0));
	end component;
	component eq28 is 
		port ( v : in std_logic_vector(4 downto 0); eq : out std_logic);
	end component;
	signal S1 : std_logic := '0';
	signal S0 : std_logic := '0';
	signal C_I, C_R, C_E : std_logic;
	signal cnt	: std_logic_vector (4 downto 0); 
begin 
	cntr: counter port map(enable => C_I, clk => clk, reset => C_R, cnt => cnt);
	e28: eq28 port map(v => cnt, eq => C_E);
	S1 <= (not S1 and not C_E and X) or (not S1 and S0 and (X or C_E)) when rising_edge(clk);
	S0 <= (not S1 and S0 and C_E) or (S1 and not S0 and not X) when rising_edge(clk);
	C_R <= not S1 and not S0;
	C_I <= S1 and not S0;
	O <= S1 and S0;
end structural;

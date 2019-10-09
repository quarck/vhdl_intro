library ieee ;
use ieee.std_logic_1164.all ;

entity pio is 
	port (
		clk			: in std_logic;
		address 	: in std_logic_vector(7 downto 0);
		data_w		: in std_logic_vector(7 downto 0); -- data entering IO port 
		data_r		: out std_logic_vector(7 downto 0);
		write_enable	: in std_logic;
		read_enable		: in std_logic;
		io_ready		: out std_logic;
		gpio_a			: in std_logic_vector (7 downto 0);
		gpio_b			: in std_logic_vector (7 downto 0);
		gpio_c			: out std_logic_vector (7 downto 0);
		gpio_d			: out std_logic_vector (7 downto 0)		
	);
end pio;

architecture beh of pio is 
begin	
	process (clk, write_enable, read_enable)
	begin
		if rising_edge(clk) then
			io_readdy  <= '1';
			data_r <= "00001111"; -- we don't have a proper IO yet
		end if;
	end;
end beh;
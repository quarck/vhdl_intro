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
		io_ready			: out std_logic;
		
		in_port_0		: in std_logic_vector (7 downto 0); -- dp switches 
		in_port_1		: in std_logic_vector (7 downto 0);	-- push btns
		in_port_2		: in std_logic_vector (7 downto 0); -- pin header 6
		in_port_3		: in std_logic_vector (7 downto 0); -- pin header 7

		out_port_4			: out std_logic_vector (7 downto 0); -- individual leds
		out_port_5			: out std_logic_vector (7 downto 0); -- 7-segment digits 
		out_port_6			: out std_logic_vector (7 downto 0); -- 7-segment enable signals 
		out_port_7			: out std_logic_vector (7 downto 0); -- pin header 8
		out_port_8			: out std_logic_vector (7 downto 0) -- pin header 9
	);
end pio;

architecture beh of pio is 
begin	
	process (clk, write_enable, read_enable)
	begin
		if rising_edge(clk) then
			io_ready  <= '1';
			data_r <= "00001111"; -- we don't have a proper IO yet
		end if;
	end process;
end beh;
library ieee;
use ieee.std_logic_1164.all;

entity Adders is 
	port (
		A : in std_logic_vector(1 downto 0);
		B : in std_logic_vector(1 downto 0);
		S: out std_logic_vector(2 downto 0)
	); 
end Adders;


architecture dataflow of Adders is 	
	signal carries: std_logic_vector(1 downto 0);
begin
	-- first bit is using dataflow implementation 
	b0: entity work.full_adder(dataflow) 
		 port map(A => A(0), B => B(0), C_in => '0', S => S(0), C_out => carries(0));
		 
	-- second bit is using structural
	b1: entity work.full_adder(structural) 
		 port map(A => A(1), B => B(1), C_in => carries(0), S => S(1), C_out => S(2));

end dataflow;


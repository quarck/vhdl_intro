library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity simple_alu is 
	port (
		A, B 	: in 	std_logic_vector(4 downto 0); 
		opcode	: in	std_logic_vector(1 downto 0);
		res		: out	std_logic_vector(4 downto 0));
end simple_alu;
architecture dataflow of simple_alu is 	
begin 
	with opcode select
		res <= 	A + B 	when "00",
				A - B 	when "01",
				A and B	when "10",
				A or B 	when "11";
end dataflow;


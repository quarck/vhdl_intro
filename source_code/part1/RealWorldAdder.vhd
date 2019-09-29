library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RealWorldAdder is 
	port ( 
		A		: in std_logic_vector(15 downto 0); 
		B		: in std_logic_vector(15 downto 0); 
		S		: out std_logic_vector(15 downto 0)
		);
end RealWorldAdder;

architecture dataflow of RealWorldAdder is 
begin
	S <= A + B;
end;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------
-- Entity declaration - an interface to a component 
----------------------------------------------------

entity full_adder is 
	port (
		A, B, C_in 		: 	in 	std_logic; 
		S, C_out		: 	out	std_logic );
end full_adder;


----------------------------------------------------
--- first implementation - dataflow model
----------------------------------------------------

architecture dataflow of full_adder is 	
begin 
	S <= A xor B xor C_in;	
	C_out <= ((A xor B) and C_in) or (A and B);	
end dataflow;


----------------------------------------------------
--- second implementation - structural model
----------------------------------------------------
architecture structural of full_adder is
	component AND_GATE
		port(L, R: in std_logic; 
			Z : out std_logic); 
	end component;	
	component OR_GATE
		port(L, R: in std_logic; 
			 Z : out std_logic); 
	end component;	
	component XOR_GATE
		port(L, R: in std_logic; 
			Z : out std_logic); 
	end component;

	signal T0, T1, T2: std_logic;
begin	
	X1: XOR_GATE port map(L => A, R => B, Z => T0); 	
	X2: XOR_GATE port map(L => T0, R => C_in, Z => S); 
	A1: AND_GATE port map(T0, C_in, T1);
	A2: AND_GATE port map(A, B, T2);
	O1: OR_GATE port map(T1, T2, C_out);
end structural;



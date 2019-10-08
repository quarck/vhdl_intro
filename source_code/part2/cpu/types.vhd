library ieee ;
use ieee.std_logic_1164.all ;


package types is



	type ALU_flags is record
		negative		: std_logic;
		zero 			: std_logic;
		carry_out 		: std_logic; -- means "borrow out" for sub
		overflow 		: std_logic;
	end record ALU_flags;
	
end package types;
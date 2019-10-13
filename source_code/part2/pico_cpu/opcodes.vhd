-- FibPU

library ieee ;
use ieee.std_logic_1164.all ;


package opcodes is

	type alu_opcode_type is (
			ALU_ADD, 		-- add
			ALU_SUB,		-- sub Left-Right
			ALU_OR, 		-- bitwise OR
			ALU_AND, 		-- .. AND
			ALU_NOT, 		-- .. NOT			
			ALU_NOP			-- no operation
		);

	-- constant definition for various CPU instructions 
		
	-- load and store instructions 
	-- prefix 011
	constant OP_STA 		: std_logic_vector(7 downto 0):="01100000";
	constant OP_LDA 		: std_logic_vector(7 downto 0):="01101000";
	constant OP_LDC 		: std_logic_vector(7 downto 0):="01110000";
	
	-- math instructions 
	-- prefix 010
	constant OP_ADD 		: std_logic_vector(7 downto 0):="01000000";
	constant OP_ADDC 		: std_logic_vector(7 downto 0):="01000100";
	constant OP_SUB 		: std_logic_vector(7 downto 0):="01001000";
	constant OP_SUBC 		: std_logic_vector(7 downto 0):="01001100";
	
	-- logical and bit instructions 
	-- prefix 11
	constant OP_OR  		: std_logic_vector(7 downto 0):="11000000";
	constant OP_AND			: std_logic_vector(7 downto 0):="11001000";
	constant OP_NOT			: std_logic_vector(7 downto 0):="11010000";

	
	-- branching instructions 
	-- prefix 1010
	constant OP_JMP 		: std_logic_vector(7 downto 0):="10100000";
	constant OP_JNZ  		: std_logic_vector(7 downto 0):="10100100";
	constant OP_JZ 			: std_logic_vector(7 downto 0):="10100101";
	
	
	-- special instructions 
	-- prefix 10111
	constant OP_HLT 		: std_logic_vector(7 downto 0):="10111000";
	constant OP_NOP 		: std_logic_vector(7 downto 0):="10111001";

	
end package opcodes;
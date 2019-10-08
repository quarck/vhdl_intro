library ieee ;
use ieee.std_logic_1164.all ;


package opcodes is

	type alu_opcode_type is (
			ALU_ADD, 		-- add
			ALU_SUB,		-- sub Left-Right
			ALU_SUBR,		-- sub Right-Left
			ALU_NEG,		-- negative 

			ALU_OR, 		-- bitwise OR
			ALU_AND, 		-- .. AND
			ALU_XOR,		-- .. XOR
			ALU_NOT, 		-- .. NOT
			
			ALU_SHL,		-- shift left
			ALU_SHR,		-- shift right 
			ALU_SHCL,		-- rotate-carry-left
			ALU_SHCR,		-- rotate-carry-right

			ALU_NOP			-- no operation
		);

	-- constant definition for various CPU instructions 
		
	-- load and store instructions 
	-- prefix 011
	constant OP_STA 		: std_logic_vector(7 downto 0):="01100000";
	constant OP_LDA 		: std_logic_vector(7 downto 0):="01101000";
	constant OP_LDC 		: std_logic_vector(7 downto 0):="01110000";
	constant OP_LDCARRY 	: std_logic_vector(7 downto 0):="01111000";
	
	-- math instructions 
	-- prefix 010
	constant OP_ADD 		: std_logic_vector(7 downto 0):="01000000";
	constant OP_SUB 		: std_logic_vector(7 downto 0):="01001000";
	constant OP_SUBR 		: std_logic_vector(7 downto 0):="01010000";
	constant OP_NEG 		: std_logic_vector(7 downto 0):="01011000";

	-- logical and bit instructions 
	-- prefix 11
	constant OP_OR  		: std_logic_vector(7 downto 0):="11000000";
	constant OP_AND			: std_logic_vector(7 downto 0):="11001000";
	constant OP_NOT			: std_logic_vector(7 downto 0):="11010000";
	constant OP_XOR			: std_logic_vector(7 downto 0):="11011000";
	constant OP_SHR 		: std_logic_vector(7 downto 0):="11100000";
	constant OP_SHL 		: std_logic_vector(7 downto 0):="11101000";
	constant OP_SHCR 		: std_logic_vector(7 downto 0):="11110000";
	constant OP_SHCL 		: std_logic_vector(7 downto 0):="11111000";

	
	-- branching instructions 
	-- prefix 1010
	constant OP_JMP 		: std_logic_vector(7 downto 0):="10100000";
	constant OP_JN  		: std_logic_vector(7 downto 0):="10100001";
	constant OP_JP  		: std_logic_vector(7 downto 0):="10100010";
	constant OP_JV  		: std_logic_vector(7 downto 0):="10100011";
	constant OP_JNV 		: std_logic_vector(7 downto 0):="10100100";
	constant OP_JZ  		: std_logic_vector(7 downto 0):="10100101";
	constant OP_JNZ 		: std_logic_vector(7 downto 0):="10100110";
	constant OP_JC  		: std_logic_vector(7 downto 0):="10100111";
	constant OP_JNC 		: std_logic_vector(7 downto 0):="10101000";
	
	
	-- port i/o instructions 
	-- prefix 10110
	constant OP_IN 			: std_logic_vector(7 downto 0):="10110000";
	constant OP_OUT 		: std_logic_vector(7 downto 0):="10110001";
	
	-- special instructions 
	-- prefix 10111
	constant OP_HLT 		: std_logic_vector(7 downto 0):="10111000";
	constant OP_NOP 		: std_logic_vector(7 downto 0):="10111001";

	
end package opcodes;
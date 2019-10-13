library ieee ;
use ieee.std_logic_1164.all ;


package opcodes is

	type alu_opcode_type is (
			ALU_ADD, 		-- add
			ALU_SUB,		-- sub Left-Right
			ALU_NEG,		-- negative 

			ALU_OR, 		-- bitwise OR
			ALU_AND, 		-- .. AND
			ALU_XOR,		-- .. XOR
			ALU_NOT, 		-- .. NOT
			
			ALU_SHL,		-- shift left
			ALU_SHR,		-- shift right 
			ALU_ROL,		-- rotate left
			ALU_ROR,		-- rotate right 
			ALU_RCL,		-- rotate-carry-left
			ALU_RCR,		-- rotate-carry-right

			ALU_NOP			-- no operation
		);

	-- constant definition for various CPU instructions 
		
	-- load and store instructions 
	-- prefix 011
	constant OP_STA 		: std_logic_vector(7 downto 0):="01100000";  -- mem[arg] = A
	constant OP_LDA 		: std_logic_vector(7 downto 0):="01100001";  -- A = mem[arg]
	constant OP_LDC 		: std_logic_vector(7 downto 0):="01100010";  -- A = arg
	
	-- math instructions 
	-- prefix 010
	constant OP_ADD 		: std_logic_vector(7 downto 0):="01000000";  -- A = A + arg
	constant OP_ADDC 		: std_logic_vector(7 downto 0):="01000100";  -- A = A + arg + carry
	constant OP_SUB 		: std_logic_vector(7 downto 0):="01001000";  -- A = arg - A
	constant OP_SUBC 		: std_logic_vector(7 downto 0):="01001100";  -- A = arg - A - carry
	constant OP_NEG 		: std_logic_vector(7 downto 0):="01011000";  -- A = - A
	
	-- logical and bit instructions 
	-- prefix 1100
	constant OP_OR  		: std_logic_vector(7 downto 0):="11000000";  -- A = A or arg
	constant OP_AND			: std_logic_vector(7 downto 0):="11000001";  -- A = A and arg
	constant OP_NOT			: std_logic_vector(7 downto 0):="11000010";  -- A = not A
	constant OP_XOR			: std_logic_vector(7 downto 0):="11000011";  -- A = A xor arg
	constant OP_SHR 		: std_logic_vector(7 downto 0):="11000100";  -- shift A right by arg
	constant OP_SHL 		: std_logic_vector(7 downto 0):="11000101";  -- shift A left by arg
	constant OP_ROL 		: std_logic_vector(7 downto 0):="11000111";  -- rotate right
	constant OP_ROR 		: std_logic_vector(7 downto 0):="11001000";  -- rotate left
	constant OP_RCL 		: std_logic_vector(7 downto 0):="11001001";  -- rotate through carry right
	constant OP_RCR 		: std_logic_vector(7 downto 0):="11001010";  -- rotate through carry left

	
	-- branching instructions 
	-- prefix 1010
	constant OP_JMP 		: std_logic_vector(7 downto 0):="10100001"; -- jump to arg
	constant OP_JMP_A		: std_logic_vector(7 downto 0):="10100000"; -- jump to arg + A
	
	constant OP_JN  		: std_logic_vector(7 downto 0):="10100010";  -- jump to arg if negative 
	constant OP_JP  		: std_logic_vector(7 downto 0):="10100011";	 -- jump to arg if positive 
	constant OP_JV  		: std_logic_vector(7 downto 0):="10100101";  -- jump to arg if overflow 
	constant OP_JNV 		: std_logic_vector(7 downto 0):="10100100";  -- jump to arg if no overflow 
	constant OP_JZ  		: std_logic_vector(7 downto 0):="10100111";  -- jump to arg if zero
	constant OP_JNZ 		: std_logic_vector(7 downto 0):="10100110";  -- jump to arg if non zero
	constant OP_JC  		: std_logic_vector(7 downto 0):="10101001";  -- jump to arg if carry
	constant OP_JNC 		: std_logic_vector(7 downto 0):="10101000";  -- jump to arg if no carry
	
	
	-- port i/o instructions 
	-- prefix 10110
	constant OP_IN 			: std_logic_vector(7 downto 0):="10110000";
	constant OP_OUT 		: std_logic_vector(7 downto 0):="10110001";
	
	-- special instructions 
	-- prefix 10111
	constant OP_HLT 		: std_logic_vector(7 downto 0):="10111000";
	constant OP_NOP 		: std_logic_vector(7 downto 0):="10111001";

	
end package opcodes;
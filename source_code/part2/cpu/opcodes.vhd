library ieee ;
use ieee.std_logic_1164.all ;


package opcodes is

	constant ALU_NO_OP 	: std_logic_vector(3 downto 0):="0000";
	constant ALU_ADD 	: std_logic_vector(3 downto 0):="0001";
	constant ALU_SUB  : std_logic_vector(3 downto 0):="0010";
	constant ALU_OR   : std_logic_vector(3 downto 0):="0011";
	constant ALU_AND  : std_logic_vector(3 downto 0):="0100";
	constant ALU_NOT  : std_logic_vector(3 downto 0):="0101";
	constant ALU_SHRC : std_logic_vector(3 downto 0):="0110";
	constant ALU_SHRZ : std_logic_vector(3 downto 0):="0111";
	constant ALU_SHLC : std_logic_vector(3 downto 0):="1000";
	constant ALU_SHLZ : std_logic_vector(3 downto 0):="1001";

	constant OP_NOP : std_logic_vector(7 downto 0):="00000000";
	constant OP_STA : std_logic_vector(7 downto 0):="00010000";
	constant OP_LDA : std_logic_vector(7 downto 0):="00100000";
	constant OP_ADD : std_logic_vector(7 downto 0):="00110000";
	constant OP_OR  : std_logic_vector(7 downto 0):="01000000";
	constant OP_AND	: std_logic_vector(7 downto 0):="01010000";
	constant OP_NOT	: std_logic_vector(7 downto 0):="01100000";
	constant OP_SUB : std_logic_vector(7 downto 0):="01110000";
	constant OP_JMP : std_logic_vector(7 downto 0):="10000000";
	constant OP_JN  : std_logic_vector(7 downto 0):="10010000";
	constant OP_JP  : std_logic_vector(7 downto 0):="10010100";
	constant OP_JV  : std_logic_vector(7 downto 0):="10011000";
	constant OP_JNV : std_logic_vector(7 downto 0):="10011100";
	constant OP_JZ  : std_logic_vector(7 downto 0):="10100000";
	constant OP_JNZ : std_logic_vector(7 downto 0):="10100100";
	constant OP_JC  : std_logic_vector(7 downto 0):="10110000";
	constant OP_JNC : std_logic_vector(7 downto 0):="10110100";
	constant OP_SHR : std_logic_vector(7 downto 0):="11100000";
	constant OP_SHL : std_logic_vector(7 downto 0):="11100001";
	constant OP_ROR	: std_logic_vector(7 downto 0):="11100010";
	constant OP_ROL	: std_logic_vector(7 downto 0):="11100011";
	constant OP_HLT : std_logic_vector(7 downto 0):="11110000";
	
end package opcodes;
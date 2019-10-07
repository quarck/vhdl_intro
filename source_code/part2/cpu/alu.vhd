library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity ALU is
	port
	(
		operation			: in std_logic_vector (3 downto 0);
		left_arg				: in std_logic_vector(7 downto 0);
		right_arg			: in std_logic_vector(7 downto 0);
		carry_in				: in std_logic;
		result				: out std_logic_vector(7 downto 0);
		negative_flag		: out std_logic;
		zero_flag 			: out std_logic;
		carry_out 			: out std_logic;
		borrow_out 			: out std_logic;
		overflow_flag 		: out std_logic
		
	);
end ALU;


architecture behaviour of ALU is

	constant OP_ADD 	: std_logic_vector(3 downto 0):="0001";
	constant OP_SUB  	: std_logic_vector(3 downto 0):="0010";
	constant OP_OR   	: std_logic_vector(3 downto 0):="0011";
	constant OP_AND   	: std_logic_vector(3 downto 0):="0100";
	constant OP_NOT  	: std_logic_vector(3 downto 0):="0101";
	constant OP_SHRC  	: std_logic_vector(3 downto 0):="0110";
	constant OP_SHRZ  	: std_logic_vector(3 downto 0):="0111";
	constant OP_SHLC  	: std_logic_vector(3 downto 0):="1000";
	constant OP_SHLZ  	: std_logic_vector(3 downto 0):="1001";

	signal internal_result : std_logic_vector(7 downto 0);
	
begin
	process (left_arg, right_arg, operation, carry_in)
		variable temp : std_logic_vector(8 downto 0);
	begin
		case operation is
		when OP_ADD =>
			temp := ('0' & left_arg) + ('0' & right_arg); -- not adding carry_in?
			internal_result <= temp(7 downto 0);
			carry_out <= temp(8);
			
			if left_arg(7)=right_arg(7) then 
				overflow_flag <= (left_arg(7) xor temp(7));
			else 
				overflow_flag <= '0';
			end if;
			
		when OP_SUB =>
			temp := ('0'&left_arg) - ('0'&right_arg);
			internal_result <= temp(7 downto 0);
			borrow_out <= temp(8);			
			
			if left_arg(7) /= right_arg(7) then 
				overflow_flag <= (left_arg(7) xor temp(7));
			else
				overflow_flag <= '0';
			end if;
			
		when OP_OR =>
			internal_result <= left_arg or right_arg;
			
		when OP_AND =>
			internal_result <= left_arg and right_arg;
			
		when OP_NOT =>
			internal_result <= not left_arg;
			
		when OP_SHRC =>
			carry_out <= left_arg(7);
			internal_result(7 downto 1) <= left_arg(6 downto 0);
			internal_result(0) <= carry_in;
			
		when OP_SHRZ =>
			carry_out <= left_arg(7);
			internal_result(7 downto 1) <= left_arg(6 downto 0);
			internal_result(0) <= '0';
			
		when OP_SHLC =>
			carry_out <= left_arg(0);
			internal_result(6 downto 0) <= left_arg(7 downto 1); 
			internal_result(7) <= carry_in;
			
		when OP_SHLZ =>
			carry_out <= left_arg(0);
			internal_result(6 downto 0) <= left_arg(7 downto 1); 
			internal_result(7) <= '0';		
			
		when others =>
			internal_result <= "00000000";
			carry_out <= '0';
			overflow_flag <= '0';
			borrow_out <= '0';
		end case;
	end process;

	result <= internal_result;
	zero_flag <= '1' when internal_result="00000000" else '0';		
	negative_flag <= internal_result(7);
	
end behaviour;

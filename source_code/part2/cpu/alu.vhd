library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

use work.opcodes.all;

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
		carry_out 			: out std_logic; -- means "borrow out" for sub
		overflow_flag 		: out std_logic
		
	);
end ALU;


architecture behaviour of ALU is	
begin
	process (left_arg, right_arg, operation, carry_in)
		variable temp : std_logic_vector(8 downto 0);
	begin
	
		overflow_flag <= '0';

		case operation is
			when ALU_ADD =>
				temp := ('0' & left_arg) + ('0' & right_arg);
				
				if left_arg(7)=right_arg(7) then 
					overflow_flag <= (left_arg(7) xor temp(7));
				else 
					overflow_flag <= '0';
				end if;
				
			when ALU_SUB =>
				temp := ('0'&left_arg) - ('0'&right_arg);
				
				if left_arg(7) /= right_arg(7) then 
					overflow_flag <= (left_arg(7) xor temp(7));
				else
					overflow_flag <= '0';
				end if;
				
			when ALU_OR =>
				temp := ('0' & left_arg) or ('0' & right_arg);
				
			when ALU_AND =>
				temp := ('0' & left_arg) and ('0' & right_arg);
				
			when ALU_NOT =>
				temp := not ('0' & left_arg);
				
			when ALU_SHRC =>
				temp := left_arg(7 downto 0) & carry_in;
				
			when ALU_SHRZ =>
				temp := left_arg(7 downto 0) & '0';
				
			when ALU_SHLC =>
				temp := left_arg(0) & carry_in & left_arg(7 downto 1); 
				
			when ALU_SHLZ =>
				temp := left_arg(0) & '0' & left_arg(7 downto 1); 
				
			when others =>
				temp := "000000000";
		end case;

		if temp(7 downto 0) = "00000000" then 
			zero_flag <= '1';
		else 
			zero_flag <= '0';
		end if;
		
		negative_flag <= temp(7);
		
		result <= temp(7 downto 0);
		carry_out <= temp(8);
		
	end process;

	
end behaviour;

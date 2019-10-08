library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

use work.opcodes.all;
use work.types.all;

entity ALU is
	port
	(
		operation			: in alu_opcode_type;
		left_arg				: in std_logic_vector(7 downto 0);
		right_arg			: in std_logic_vector(7 downto 0);
		carry_in				: in std_logic;
		result				: out std_logic_vector(7 downto 0);
		flags					: out ALU_flags
	);
end ALU;


architecture behaviour of ALU is	
begin
	process (left_arg, right_arg, operation, carry_in)
		variable temp : std_logic_vector(8 downto 0);
	begin
	
		flags.overflow <= '0';

		case operation is
			when ALU_ADD =>
				temp := ('0' & left_arg) + ('0' & right_arg);
				
				if left_arg(7)=right_arg(7) then 
					flags.overflow <= (left_arg(7) xor temp(7));
				else 
					flags.overflow <= '0';
				end if;
				
			when ALU_SUB =>
				temp := ('0'&left_arg) - ('0'&right_arg);
				
				if left_arg(7) /= right_arg(7) then 
					flags.overflow <= (left_arg(7) xor temp(7));
				else
					flags.overflow <= '0';
				end if;

			when ALU_SUBR =>
				temp :=  ('0'&right_arg) - ('0'&left_arg);
				
				if left_arg(7) /= right_arg(7) then 
					flags.overflow <= (right_arg(7) xor temp(7));
				else
					flags.overflow <= '0';
				end if;

			when ALU_NEG =>
				temp :=  0 - ('0'&left_arg);				
				
						
				
			when ALU_OR =>
				temp := ('0' & left_arg) or ('0' & right_arg);
				
			when ALU_AND =>
				temp := ('0' & left_arg) and ('0' & right_arg);

			when ALU_XOR =>
				temp := ('0' & left_arg) xor ('0' & right_arg);
				
			when ALU_NOT =>
				temp := not ('0' & left_arg);
			
			when ALU_SHL => 
				temp := left_arg(0) & '0' & left_arg(7 downto 1); 
			
			when ALU_SHR => 
				temp := left_arg(7 downto 0) & '0';
			
			when ALU_SHCL => 
				temp := left_arg(0) & carry_in & left_arg(7 downto 1); 
				
			when ALU_SHCR => 
				temp := left_arg(7 downto 0) & carry_in;
						
			when others =>
				temp := "000000000";
		end case;

		if temp(7 downto 0) = "00000000" then 
			flags.zero <= '1';
		else 
			flags.zero <= '0';
		end if;		
		
		flags.carry_out <= temp(8);
		flags.negative <= temp(7);

		result <= temp(7 downto 0);
		
	end process;
	
end behaviour;

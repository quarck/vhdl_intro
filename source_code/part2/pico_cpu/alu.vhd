-- FibPU

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

use work.opcodes.all;
use work.types.all;

entity ALU is
	port
	(
		operation			: in alu_opcode_type;
		left_arg			: in std_logic_vector(7 downto 0);
		right_arg			: in std_logic_vector(7 downto 0);
		carry_in			: in std_logic;
		result				: out std_logic_vector(7 downto 0);
		flags				: out ALU_flags
	);
end ALU;

architecture behaviour of ALU is	
begin
	process (left_arg, right_arg, operation, carry_in)
		variable temp : std_logic_vector(8 downto 0);
	begin
		case operation is
			when ALU_ADD =>
				temp := ('0' & left_arg) + ('0' & right_arg) + ("00000000" & carry_in);
			when ALU_SUB =>
				temp := ('0'&left_arg) - ('0'&right_arg) - ("00000000" & carry_in);
			when ALU_OR =>
				temp := ('0' & left_arg) or ('0' & right_arg);
			when ALU_AND =>
				temp := ('0' & left_arg) and ('0' & right_arg);
			when ALU_NOT =>
				temp := not ('0' & left_arg);
			when others =>
				temp := "000000000";
		end case;

		if temp(7 downto 0) = "00000000" then  flags.zero <= '1';
		else  flags.zero <= '0';
		end if;		
		
		flags.carry_out <= temp(8);
		result <= temp(7 downto 0);
	end process;
end behaviour;

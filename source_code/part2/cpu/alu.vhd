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
	
		flags.overflow <= '0';

		case operation is
			when ALU_ADD =>
				temp := ('0' & left_arg) + ('0' & right_arg) + ("00000000" & carry_in);
				
				if left_arg(7)=right_arg(7) then 
					flags.overflow <= (left_arg(7) xor temp(7));
				else 
					flags.overflow <= '0';
				end if;
				
			when ALU_SUB =>
				temp := ('0'&left_arg) - ('0'&right_arg) - ("00000000" & carry_in);
				
				if left_arg(7) /= right_arg(7) then 
					flags.overflow <= (left_arg(7) xor temp(7));
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
				-- a bit wordy...
				case right_arg is 
					when "00000001" => temp := left_arg(0) & '0' & left_arg(7 downto 1); 
					when "00000010" => temp := left_arg(1) & "00" & left_arg(7 downto 2); 
					when "00000011" => temp := left_arg(2) & "000" & left_arg(7 downto 3); 
					when "00000100" => temp := left_arg(3) & "0000" & left_arg(7 downto 4); 
					when "00000101" => temp := left_arg(4) & "00000" & left_arg(7 downto 5); 
					when "00000110" => temp := left_arg(5) & "000000" & left_arg(7 downto 6); 
					when "00000111" => temp := left_arg(6) & "0000000" & left_arg(7); 
					when "00001000" => temp := left_arg(7) & "00000000"; 
					when others 	=> temp := "000000000";
				end case;
			
			when ALU_SHR => 
				-- a bit wordy... also... 
				case right_arg is 
					when "00000001" => temp := left_arg(7 downto 0) & '0';
					when "00000010" => temp := left_arg(6 downto 0) & "00";
					when "00000011" => temp := left_arg(5 downto 0) & "000";
					when "00000100" => temp := left_arg(4 downto 0) & "0000"; 
					when "00000101" => temp := left_arg(3 downto 0) & "00000";
					when "00000110" => temp := left_arg(2 downto 0) & "000000";
					when "00000111" => temp := left_arg(1 downto 0) & "0000000";
					when "00001000" => temp := left_arg(0) & "00000000";
					when others 	=> temp := "000000000";
				end case;

			when ALU_ROL => 
				-- a bit wordy...
				case right_arg is 
					when "00000001" => temp := '0' & left_arg(0) & left_arg(7 downto 1); 
					when "00000010" => temp := '0' & left_arg(1 downto 0 ) & left_arg(7 downto 2); 
					when "00000011" => temp := '0' & left_arg(2 downto 0 ) & left_arg(7 downto 3); 
					when "00000100" => temp := '0' & left_arg(3 downto 0 ) & left_arg(7 downto 4); 
					when "00000101" => temp := '0' & left_arg(4 downto 0 ) & left_arg(7 downto 5); 
					when "00000110" => temp := '0' & left_arg(5 downto 0 ) & left_arg(7 downto 6); 
					when "00000111" => temp := '0' & left_arg(6 downto 0 ) & left_arg(7); 
					when others 	=> temp := "000000000";
				end case;
			
			when ALU_ROR => 
				-- a bit wordy... also... 
				case right_arg is 
					when "00000001" => temp := '0' & left_arg(7 downto 1) & left_arg(0);
					when "00000010" => temp := '0' & left_arg(7 downto 2) & left_arg(1 downto 0);
					when "00000011" => temp := '0' & left_arg(7 downto 3) & left_arg(2 downto 0);
					when "00000100" => temp := '0' & left_arg(7 downto 4) & left_arg(3 downto 0);
					when "00000101" => temp := '0' & left_arg(7 downto 5) & left_arg(4 downto 0);
					when "00000110" => temp := '0' & left_arg(7 downto 6) & left_arg(5 downto 0);
					when "00000111" => temp := '0' & left_arg(7) & left_arg(6 downto 0);
					when others 	=> temp := "000000000";
				end case;

			
			when ALU_RCL => 
				-- a bit wordy...
				case right_arg is 
					when "00000001" => temp := left_arg(0) & carry_in & left_arg(7 downto 1); 
					when "00000010" => temp := left_arg(1 downto 0 ) & carry_in &  left_arg(7 downto 2); 
					when "00000011" => temp := left_arg(2 downto 0 ) & carry_in & left_arg(7 downto 3); 
					when "00000100" => temp := left_arg(3 downto 0 ) & carry_in & left_arg(7 downto 4); 
					when "00000101" => temp := left_arg(4 downto 0 ) & carry_in & left_arg(7 downto 5); 
					when "00000110" => temp := left_arg(5 downto 0 ) & carry_in & left_arg(7 downto 6); 
					when "00000111" => temp := left_arg(6 downto 0 ) & carry_in & left_arg(7); 
					when others 	=> temp := "000000000";
				end case;
			
			when ALU_RCR => 
				-- a bit wordy... also... 
				case right_arg is 
					when "00000001" => temp := left_arg(7 downto 1) & carry_in & left_arg(0);
					when "00000010" => temp := left_arg(7 downto 2) & carry_in & left_arg(1 downto 0);
					when "00000011" => temp := left_arg(7 downto 3) & carry_in & left_arg(2 downto 0);
					when "00000100" => temp := left_arg(7 downto 4) & carry_in & left_arg(3 downto 0);
					when "00000101" => temp := left_arg(7 downto 5) & carry_in & left_arg(4 downto 0);
					when "00000110" => temp := left_arg(7 downto 6) & carry_in & left_arg(5 downto 0);
					when "00000111" => temp := left_arg(7) & carry_in & left_arg(6 downto 0);
					when others 	=> temp := "000000000";
				end case;

						
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

-- Ahmes VHDL


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

use work.opcodes.all;

entity ahmes is
	port
	(
		clk				: in std_logic;
		reset			: in std_logic;
		error			: out std_logic;
		
		address_bus		: out std_logic_vector(7 downto 0);
		data_in			: in std_logic_vector(7 downto 0);
		data_out		: out std_logic_vector(7 downto 0);
		mem_write		: out std_logic;
		
		alu_opcode 		: out std_logic_vector (3 downto 0);
		alu_left		: out std_logic_vector(7 downto 0);
		alu_right		: out std_logic_vector(7 downto 0);
		alu_result		: in std_logic_vector(7 downto 0);
		
		carry_out				: out std_logic;
		alu_result_is_negative 	: in std_logic;
		alu_result_is_zero 		: in std_logic;
		alu_flag_carry 			: in std_logic;
		alu_flag_overflow 		: in std_logic
	);
end ahmes;

architecture cpu of ahmes is

	type cpu_state_type is (
		FETCH_0,
		FETCH_1, 
		DECODE,
		EXECUTE_STA_1, EXECUTE_STA_2, EXECUTE_STA_3, EXECUTE_STA_4,
		EXECUTE_LDA_1, EXECUTE_LDA_2, EXECUTE_LDA_3,
		EXECUTE_ADD_1, EXECUTE_ADD_2, EXECUTE_ADD_3,
		EXECUTE_SUB_1, EXECUTE_SUB_2, EXECUTE_SUB_3,
		EXECUTE_OR_1, EXECUTE_OR_2, EXECUTE_OR_3,
		EXECUTE_AND_1, EXECUTE_AND_2, EXECUTE_AND_3,
		EXECUTE_JMP,					
		EXECUTE_SHR_1,  				
		EXECUTE_SHL_1,  				
		EXECUTE_ROR_1, 				
		EXECUTE_ROL_1, 				
		STORE_0, 
		STOP
		);

	signal cpu_state 			: cpu_state_type;
	signal program_counter 		: std_logic_vector(7 downto 0);
	signal accumulator 			: std_logic_vector(7 downto 0);
	signal instruction_register	: std_logic_vector(7 downto 0);
	signal data_register		: std_logic_vector(7 downto 0);
	
begin
	process (clk, reset, program_counter, accumulator, instruction_register)		
		
	begin
		if reset = '1' 
		then
			cpu_state <= FETCH_0;
			program_counter <= "00000000";
			mem_write <= '0';
			address_bus <= "00000000";
			data_out <= "00000000";	
			alu_opcode <= ALU_NO_OP;

		elsif rising_edge(clk) 
		then
			case cpu_state is
				when STOP => 
					cpu_state <= STOP;
					
				when FETCH_0 =>
					address_bus <= program_counter;
					error <= '0';
					cpu_state <= FETCH_1;
					
				when FETCH_1 =>
					instruction_register <= data_in;
					cpu_state <= DECODE;
					
				when DECODE =>
					case instruction_register is
						when OP_NOP =>						
							program_counter <= program_counter + 1;
							cpu_state <= FETCH_0;	
							
						when OP_STA =>						
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_STA_1;
							
						when OP_LDA =>						
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_LDA_1;
							
						when OP_ADD =>						
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_ADD_1;
							
						when OP_SUB =>						
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_SUB_1;
							
						when OP_OR =>						
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_OR_1;
							
						when OP_AND =>
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_AND_1;
							
						when OP_NOT =>					
							alu_left <= accumulator;	
							alu_opcode <= ALU_NOT;
							program_counter <= program_counter + 1;
							cpu_state <= STORE_0;
							
						when OP_JMP =>						
							address_bus <= program_counter + 1;
							cpu_state <= EXECUTE_JMP;

						when OP_JN =>						
							if (alu_result_is_negative='1') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;	
							end if;
							
						when OP_JP =>						
							if (alu_result_is_negative='0') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;
							end if;
						when OP_JV =>						
							if (alu_flag_overflow='1') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;
							end if;

						when OP_JNV =>						
							if (alu_flag_overflow='0') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;	
							else
								program_counter <= program_counter + 2;	
								cpu_state <= FETCH_0;
							end if;
							
						when OP_JZ =>	
							if (alu_result_is_zero='1') then
								address_bus <= program_counter + 1;	
								cpu_state <= EXECUTE_JMP;	
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;
							end if;

						when OP_JNZ =>	
							if (alu_result_is_zero='0') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;
							end if;
							
						when OP_JC =>
							if (alu_flag_carry='1') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;
							end if;
							
						when OP_JNC =>
							if (alu_flag_carry='0') then
								address_bus <= program_counter + 1;
								cpu_state <= EXECUTE_JMP;
							else
								program_counter <= program_counter + 2;
								cpu_state <= FETCH_0;
							end if;
							
						when OP_SHR =>	
							cpu_state <= EXECUTE_SHR_1;
							
						when OP_SHL =>
							cpu_state <= EXECUTE_SHL_1;
							
						when OP_ROR =>
							carry_out <= alu_flag_carry;
							cpu_state <= EXECUTE_ROR_1;
							
						when OP_ROL =>
							carry_out <= alu_flag_carry;
							cpu_state <= EXECUTE_ROL_1;	

						when OP_HLT =>
							cpu_state <= STOP;

						when others =>
							program_counter <= program_counter + 1;	
							error <= '1';
							cpu_state <= FETCH_0;
					end case;

				when EXECUTE_STA_1 =>
					data_register <= data_in;
					cpu_state <= EXECUTE_STA_2;	
					
				when EXECUTE_STA_2 =>				
					address_bus <= data_register;
					data_out <= accumulator;	
					program_counter <= program_counter + 1;
					cpu_state <= EXECUTE_STA_3;
					
				when EXECUTE_STA_3 =>
					mem_write <= '1';	
					program_counter <= program_counter + 1;
					cpu_state <= EXECUTE_STA_4;
					
				when EXECUTE_STA_4 =>
					mem_write <= '0';	
					cpu_state <= FETCH_0;	
					
				when EXECUTE_LDA_1 =>
					data_register <= data_in;
					cpu_state <= EXECUTE_LDA_2;
					
				when EXECUTE_LDA_2 =>
					address_bus <= data_register;
					program_counter <= program_counter + 1;
					cpu_state <= EXECUTE_LDA_3;
					
				when EXECUTE_LDA_3 =>
					accumulator <= data_in;	
					program_counter <= program_counter + 1;	
					cpu_state <= FETCH_0;
					
				when EXECUTE_ADD_1 =>
					data_register <= data_in;
					cpu_state <= EXECUTE_ADD_2;
					
				when EXECUTE_ADD_2 =>
					address_bus <= data_register;	
					cpu_state <= EXECUTE_ADD_3;
					
				when EXECUTE_ADD_3 =>
					alu_left <= data_in;
					alu_right <= accumulator;
					alu_opcode <= ALU_ADD;
					program_counter <= program_counter + 1;
					cpu_state <= STORE_0;
					
				when EXECUTE_SUB_1 =>
					data_register <= data_in;
					cpu_state <= EXECUTE_SUB_2;
					
				when EXECUTE_SUB_2 =>
					address_bus <= data_register;
					cpu_state <= EXECUTE_SUB_3;
					
				when EXECUTE_SUB_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;	
					alu_opcode <= ALU_SUB;
					program_counter <= program_counter + 1;
					cpu_state <= STORE_0;
					
				when EXECUTE_OR_1 =>
					data_register <= data_in;
					cpu_state <= EXECUTE_OR_2;
					
				when EXECUTE_OR_2 =>
					address_bus <= data_register;
					cpu_state <= EXECUTE_OR_3;
					
				when EXECUTE_OR_3 =>
					alu_left <= accumulator;	
					alu_right <= data_in;	
					alu_opcode <= ALU_OR;
					program_counter <= program_counter + 1;
					cpu_state <= STORE_0;
					
				when EXECUTE_AND_1 =>
					data_register <= data_in;
					cpu_state <= EXECUTE_AND_2;
					
				when EXECUTE_AND_2 =>
					address_bus <= data_register;
					cpu_state <= EXECUTE_AND_3;
					
				when EXECUTE_AND_3 =>
					alu_left <= accumulator;	
					alu_right <= data_in;
					alu_opcode <= ALU_AND;
					program_counter <= program_counter + 1;
					cpu_state <= STORE_0;
					
				when EXECUTE_JMP =>
					program_counter <= data_in;
					cpu_state <= FETCH_0;
					
				when EXECUTE_SHR_1 =>
					alu_left <= accumulator;
					alu_opcode <= ALU_SHRZ;
					cpu_state <= STORE_0;
					
				when EXECUTE_SHL_1 =>	
					alu_left <= accumulator;	
					alu_opcode <= ALU_SHLZ;	
					cpu_state <= STORE_0;
					
				when EXECUTE_ROR_1 =>	
					alu_left <= accumulator;	
					alu_opcode <= ALU_SHRC;
					cpu_state <= STORE_0;
					
				when EXECUTE_ROL_1 =>	
					alu_left <= accumulator;	
					alu_opcode <= ALU_SHLZ;
					cpu_state <= STORE_0;					
					
				when STORE_0 =>
					accumulator <= alu_result;
					program_counter <= program_counter + 1;
					cpu_state <= FETCH_0;
			end case;
		end if;
	end process;
end cpu;
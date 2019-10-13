-- FibPU Core 

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

use work.opcodes.all;
use work.types.all;

entity core is
	port
	(
		clk				: in std_logic;
		reset			: in std_logic;
		error			: out std_logic;
		
		address_bus		: out std_logic_vector(7 downto 0);
		data_in			: in std_logic_vector(7 downto 0);
		data_out		: out std_logic_vector(7 downto 0);
		mem_write		: out std_logic;

		alu_opcode 		: out alu_opcode_type;
		alu_carry_in	: out std_logic;		
		alu_left		: out std_logic_vector(7 downto 0);
		alu_right		: out std_logic_vector(7 downto 0);
		alu_result		: in std_logic_vector(7 downto 0);
		alu_flags_in	: in ALU_flags;
		
		debug_program_counter		: out std_logic_vector(7 downto 0);
		debug_accumulator	 		: out std_logic_vector(7 downto 0);
		debug_instruction_code		: out std_logic_vector(7 downto 0); 
		debug_cpu_state				: out cpu_state_type
	);
end core;

architecture ahmes of core is

	signal cpu_state 				: cpu_state_type;
	signal program_counter	 		: std_logic_vector(7 downto 0);
	signal accumulator	 			: std_logic_vector(7 downto 0);
	signal flags					: ALU_flags := (others => '0');

	signal instruction_code			: std_logic_vector(7 downto 0);
		
begin

	debug_program_counter <= program_counter;
	debug_accumulator	 <= accumulator;
	debug_instruction_code <=	instruction_code;
	debug_cpu_state <= cpu_state;

	process (clk, reset, program_counter, accumulator)		
		
	begin
		if reset = '1' 
		then
			cpu_state <= FETCH_0;
			program_counter <= "00000000";
			mem_write <= '0';
			address_bus <= "00000000";
			data_out <= "00000000";	
			alu_opcode <= ALU_NOP;
						
			flags <= (others => '0');
			error <= '0';

		elsif rising_edge(clk) 
		then
			case cpu_state is
				when STOP => 
					cpu_state <= STOP;

				when FETCH_0 =>
					-- set instruction address on the memory bus
					address_bus <= program_counter;
					program_counter <= program_counter + 1;
					cpu_state <= FETCH_1;
					
				when FETCH_1 =>
					-- set instruction address on the memory bus, 
					-- data from the FETCH_0 is still travelling through FF-s
					address_bus <= program_counter;
					program_counter <= program_counter + 1;

					cpu_state <= DECODE;

				when DECODE =>
					-- instruction code would have just arrive by now in the data IN
					instruction_code <= data_in;
				
					case data_in is
						when OP_NOP =>
							cpu_state <= FETCH_0;

						when OP_STA =>
							cpu_state <= EXECUTE_STA_1;

						when OP_LDA =>	
							cpu_state <= EXECUTE_LDA_1;

						when OP_LDC => 
							cpu_state <= EXECUTE_LDC_1;

						when OP_ADD =>
							alu_carry_in <= '0';
							alu_opcode <= ALU_ADD;
							cpu_state <= EXECUTE_ALU_REGMEM_1;

						when OP_ADDC =>
							alu_carry_in <= flags.carry_out;
							alu_opcode <= ALU_ADD;
							cpu_state <= EXECUTE_ALU_REGMEM_1;

						when OP_SUB =>
							alu_carry_in <= '0';
							alu_opcode <= ALU_SUB;
							cpu_state <= EXECUTE_ALU_REGMEM_1;

						when OP_SUBC =>
							alu_carry_in <= flags.carry_out;
							alu_opcode <= ALU_SUB;
							cpu_state <= EXECUTE_ALU_REGMEM_1;

						when OP_OR =>
							alu_opcode <= ALU_OR;
							cpu_state <= EXECUTE_ALU_REGMEM_1;

						when OP_AND =>
							alu_opcode <= ALU_AND;
							cpu_state <= EXECUTE_ALU_REGMEM_1;

						when OP_NOT =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NOT;
							cpu_state <= STORE;

						when OP_JMP =>
							cpu_state <= EXECUTE_JMP;

						when OP_JZ | OP_JNZ =>
							if flags.zero = data_in(0) then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_HLT =>
							cpu_state <= STOP;

						when others =>
							error <= '1';
							cpu_state <= STOP;

					end case;

				when EXECUTE_STA_1 =>
					address_bus <= data_in;
					data_out <= accumulator;	
					mem_write <= '1';
					cpu_state <= EXECUTE_STA_2;	

				when EXECUTE_STA_2 =>
					mem_write <= '0';
					cpu_state <= FETCH_0;


				when EXECUTE_LDA_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_LDA_2;

				when EXECUTE_LDA_2 =>
					cpu_state <= EXECUTE_LDA_3;

				when EXECUTE_LDA_3 =>
					accumulator <= data_in;	
					cpu_state <= FETCH_0;

				when EXECUTE_LDC_1 =>
					accumulator <= data_in;
					cpu_state <= FETCH_0;


				when EXECUTE_ALU_REGMEM_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_ALU_REGMEM_2;
					
				when EXECUTE_ALU_REGMEM_2 =>
					cpu_state <= EXECUTE_ALU_REGMEM_3;
					
				when EXECUTE_ALU_REGMEM_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					cpu_state <= STORE;

				when EXECUTE_JMP =>
					program_counter <= data_in;
					cpu_state <= FETCH_0;

				when STORE =>
					accumulator <= alu_result;
					flags <= alu_flags_in;					
					cpu_state <= FETCH_0;
					
					-- note: a tiny optimisation would be to do: 
					-- 
					--   address_bus <= program_counter;
					--   program_counter <= program_counter + 1;
					--   cpu_state <= FETCH_1
					--
					-- thus, skipping FETCH_0 at all


			end case;
		end if;
	end process;
end ahmes;

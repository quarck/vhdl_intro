-- Ahmes VHDL

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
		alu_flags		: in ALU_flags;
		
		pio_address 	: out std_logic_vector(7 downto 0);
		pio_data_w		: out std_logic_vector(7 downto 0); -- data entering IO port 
		pio_data_r		: in std_logic_vector(7 downto 0);
		pio_write_enable	: out std_logic;
		pio_read_enable		: out std_logic;
		pio_io_ready		: in std_logic
	);
end core;

architecture ahmes of core is

	type cpu_state_type is (
		FETCH,
		DECODE,
		
		EXECUTE_STA_1, EXECUTE_STA_2,
		EXECUTE_LDA_1, EXECUTE_LDA_2, 
		EXECUTE_LDC_1, 
		
		EXECUTE_ADD_1, EXECUTE_ADD_2, 
		EXECUTE_SUB_1, EXECUTE_SUB_2, 
		EXECUTE_SUBR_1, EXECUTE_SUBR_2,
		
		EXECUTE_OR_1, EXECUTE_OR_2, 
		EXECUTE_AND_1, EXECUTE_AND_2, 
		EXECUTE_XOR_1, EXECUTE_XOR_2,
		
		EXECUTE_JMP,
				
		STORE, 
		
		STOP
		);

	signal cpu_state 				: cpu_state_type;
	signal program_counter	 		: std_logic_vector(7 downto 0);
	signal accumulator	 			: std_logic_vector(7 downto 0);
	signal data_register			: std_logic_vector(7 downto 0);
		
begin
	process (clk, reset, program_counter, accumulator)		
		
	begin
		if reset = '1' 
		then
			cpu_state <= FETCH;
			program_counter <= "00000000";
			mem_write <= '0';
			address_bus <= "00000000";
			data_out <= "00000000";	
			alu_opcode <= ALU_NOP;

		elsif rising_edge(clk) 
		then
			case cpu_state is
				when STOP => 
					cpu_state <= STOP;

				when FETCH =>
					-- set instruction address on the memory bus
					address_bus <= program_counter;

					-- and in parallel - start incrementing PC to point to 
					-- the next location 
					program_counter <= program_counter + 1;
					error <= '0';
					cpu_state <= DECODE;

				when DECODE =>
					-- As we enter here, program_counter is pointing  to the 
					-- byte that is following the 1st byte of the instruction.
					-- Thus, preload the next byte - most instructions would use 
					-- it, so by the time we move to the next state, data would 
					-- be already waiting on the BUS
					address_bus <= program_counter;

					case data_in is
						when OP_NOP =>
							-- we already did preload the next byte, just move 
							-- the PC to point the byte after it, and we are 
							-- good to skip FETCH and jump directly into DECODE 
							-- again for the next instruction
							cpu_state <= DECODE;	
							program_counter <= program_counter + 1;

						when OP_STA =>
							-- adjust PC to point to the byte after the argument 
							-- (for the next instruction), and jump to the 
							-- execution state - we don't have data yet to do 
							-- anything else, instruction argument is yet to 
							-- travel from the memory
							program_counter <= program_counter + 1;
							cpu_state <= EXECUTE_STA_1;

						when OP_LDA =>	
							program_counter <= program_counter + 1;
							cpu_state <= EXECUTE_LDA_1;

						when OP_LDC => 
							program_counter <= program_counter + 1;
							cpu_state <= EXECUTE_LDC_1;

						when OP_ADD =>
							program_counter <= program_counter + 1;
							alu_carry_in <= '0';
							cpu_state <= EXECUTE_ADD_1;

						when OP_ADDC =>
							program_counter <= program_counter + 1;
							alu_carry_in <= alu_flags.carry_out;
							cpu_state <= EXECUTE_ADD_1;

						when OP_SUB =>
							program_counter <= program_counter + 1;
							alu_carry_in <= '0';
							cpu_state <= EXECUTE_SUB_1;

						when OP_SUBC =>
							program_counter <= program_counter + 1;
							alu_carry_in <= alu_flags.carry_out;
							cpu_state <= EXECUTE_SUB_1;

						when OP_SUBR =>
							program_counter <= program_counter + 1;
							alu_carry_in <= '0';
							cpu_state <= EXECUTE_SUBR_1;

						when OP_SUBCR =>
							program_counter <= program_counter + 1;
							alu_carry_in <= alu_flags.carry_out;
							cpu_state <= EXECUTE_SUBR_1;

						when OP_NEG =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NEG;
							cpu_state <= STORE;

						when OP_OR =>
							program_counter <= program_counter + 1;
							cpu_state <= EXECUTE_OR_1;

						when OP_AND =>
							program_counter <= program_counter + 1;
							cpu_state <= EXECUTE_AND_1;

						when OP_XOR =>
							program_counter <= program_counter + 1;
							cpu_state <= EXECUTE_XOR_1;

						when OP_NOT =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NOT;
							cpu_state <= STORE;

						when OP_JMP =>
							-- we are jumping - but address to jump is not yet 
							-- known, thus we move into EXECUTE_JMP state
							cpu_state <= EXECUTE_JMP;

						when OP_JN =>
							if alu_flags.negative = '1' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;


						when OP_JP =>
							if alu_flags.negative = '0' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_JV =>
							if alu_flags.overflow = '1' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_JNV =>
							if alu_flags.overflow = '0' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_JZ =>
							if alu_flags.zero = '1' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_JNZ =>
							if alu_flags.zero = '0' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_JC =>
							if alu_flags.carry_out = '1' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_JNC =>
							if alu_flags.carry_out = '0' then
								-- same as for unconditional jump
								cpu_state <= EXECUTE_JMP;
							else
								-- not jumping -- go to FETCH now
								program_counter <= program_counter + 1;
								cpu_state <= FETCH;
							end if;

						when OP_SHR =>
							alu_left <= accumulator;
							alu_opcode <= ALU_SHR;
							cpu_state <= STORE;

						when OP_SHL =>
							alu_left <= accumulator;
							alu_opcode <= ALU_SHL;
							cpu_state <= STORE;

						when OP_SHCR =>
							alu_left <= accumulator;
							alu_carry_in <= alu_flags.carry_out;
							alu_opcode <= ALU_SHCR;
							cpu_state <= STORE;

						when OP_SHCL =>
							alu_left <= accumulator;
							alu_carry_in <= alu_flags.carry_out;
							alu_opcode <= ALU_SHCL;
							cpu_state <= STORE;

						when OP_HLT =>
							cpu_state <= STOP;

						when others =>
							error <= '1';
							cpu_state <= STOP;

					end case;

				when EXECUTE_STA_1 =>
					-- data_in is an argument of the instruction 
					-- - address to store data into
					address_bus <= data_in;
					data_out <= accumulator;	
					mem_write <= '1';
					cpu_state <= EXECUTE_STA_2;	

				when EXECUTE_STA_2 =>
					mem_write <= '0';
					cpu_state <= FETCH;


				when EXECUTE_LDA_1 =>
					-- data_in is an argument of the instruction 
					-- - address to load data from
					address_bus <= data_in;
					cpu_state <= EXECUTE_LDA_2;

				when EXECUTE_LDA_2 =>
					accumulator <= data_in;	
					cpu_state <= FETCH;


				when EXECUTE_LDC_1 =>
					-- data_in is an argument of the instruction 
					-- - actual value to load into the accumulator
					accumulator <= data_in;
					cpu_state <= FETCH;


				when EXECUTE_ADD_1 =>
					-- data_in is an argument of the instruction 
					-- - address of the second argument 
					address_bus <= data_in;
					cpu_state <= EXECUTE_ADD_2;

				when EXECUTE_ADD_2 =>
					-- now data_in is an argument to add 
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_ADD;
					cpu_state <= STORE;

				when EXECUTE_SUB_1 =>
					-- data_in is an argument of the instruction 
					-- - address of the second argument 
					address_bus <= data_in;
					cpu_state <= EXECUTE_SUB_2;

				when EXECUTE_SUB_2 =>
					-- now data_in is an argument to sub
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_SUB;
					cpu_state <= STORE;

				when EXECUTE_SUBR_1 =>
					-- data_in is an argument of the instruction 
					-- - address of the second argument 
					address_bus <= data_in;
					cpu_state <= EXECUTE_SUBR_2;

				when EXECUTE_SUBR_2 =>
					-- now data_in is an argument to sub
					alu_left <= data_in;
					alu_right <= accumulator;
					alu_opcode <= ALU_SUB;
					cpu_state <= STORE;


				when EXECUTE_OR_1 =>
					-- data_in is an argument of the instruction 
					-- - address of the second argument 
					address_bus <= data_in;
					cpu_state <= EXECUTE_OR_2;

				when EXECUTE_OR_2 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_OR;
					cpu_state <= STORE;

				when EXECUTE_XOR_1 =>
					-- data_in is an argument of the instruction 
					-- - address of the second argument 
					address_bus <= data_in;
					cpu_state <= EXECUTE_XOR_2;

				when EXECUTE_XOR_2 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_XOR;
					cpu_state <= STORE;

				when EXECUTE_AND_1 =>
					-- data_in is an argument of the instruction 
					-- - address of the second argument 
					address_bus <= data_in;
					cpu_state <= EXECUTE_AND_2;

				when EXECUTE_AND_2 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_AND;
					cpu_state <= STORE;


				when EXECUTE_JMP =>
					program_counter <= data_in;
					cpu_state <= FETCH;

				when STORE =>
					-- program_counter was already updated by this stage, just 
					-- store the ALU's result into the accumulator and we are 
					-- good to process the next instruction
					accumulator <= alu_result;
					cpu_state <= FETCH;

			end case;
		end if;
	end process;
end ahmes;

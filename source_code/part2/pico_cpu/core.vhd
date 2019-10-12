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
		alu_flags_in	: in ALU_flags;
		
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
		FETCH_0, FETCH_1,
		DECODE,
		
		EXECUTE_STA_1, EXECUTE_STA_2,
		EXECUTE_LDA_1, EXECUTE_LDA_2, EXECUTE_LDA_3, 
		EXECUTE_LDC_1, 
		
		EXECUTE_ADD_1, EXECUTE_ADD_2, EXECUTE_ADD_3, 
		EXECUTE_SUB_1, EXECUTE_SUB_2, EXECUTE_SUB_3, 
		EXECUTE_SUBR_1, EXECUTE_SUBR_2,EXECUTE_SUBR_3,
		
		EXECUTE_OR_1, EXECUTE_OR_2, EXECUTE_OR_3,
		EXECUTE_AND_1, EXECUTE_AND_2, EXECUTE_AND_3, 
		EXECUTE_XOR_1, EXECUTE_XOR_2,EXECUTE_XOR_3,
		
		EXECUTE_JMP,
				
		STORE, 
		
		STOP
		);

	signal cpu_state 				: cpu_state_type;
	signal program_counter	 		: std_logic_vector(7 downto 0);
	signal accumulator	 			: std_logic_vector(7 downto 0);
	signal flags					: ALU_flags := (others => '0');

	signal instruction_code			: std_logic_vector(7 downto 0);
		
begin
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
			
			pio_address <= "00000000"; 
			pio_data_w <= "00000000"; 
			pio_write_enable <= '0';
			pio_read_enable	 <= '0';
			
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
							cpu_state <= EXECUTE_ADD_1;

						when OP_ADDC =>
							alu_carry_in <= flags.carry_out;
							cpu_state <= EXECUTE_ADD_1;

						when OP_SUB =>
							alu_carry_in <= '0';
							cpu_state <= EXECUTE_SUB_1;

						when OP_SUBC =>
							alu_carry_in <= flags.carry_out;
							cpu_state <= EXECUTE_SUB_1;

						when OP_SUBR =>
							alu_carry_in <= '0';
							cpu_state <= EXECUTE_SUBR_1;

						when OP_SUBCR =>
							alu_carry_in <= flags.carry_out;
							cpu_state <= EXECUTE_SUBR_1;

						when OP_NEG =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NEG;
							cpu_state <= STORE;

						when OP_OR =>
							cpu_state <= EXECUTE_OR_1;

						when OP_AND =>
							cpu_state <= EXECUTE_AND_1;

						when OP_XOR =>
							cpu_state <= EXECUTE_XOR_1;

						when OP_NOT =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NOT;
							cpu_state <= STORE;

						when OP_JMP =>
							cpu_state <= EXECUTE_JMP;

						when OP_JN =>
							if flags.negative = '1' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;


						when OP_JP =>
							if flags.negative = '0' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JV =>
							if flags.overflow = '1' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JNV =>
							if flags.overflow = '0' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JZ =>
							if flags.zero = '1' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JNZ =>
							if flags.zero = '0' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JC =>
							if flags.carry_out = '1' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JNC =>
							if flags.carry_out = '0' then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
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
							alu_carry_in <= flags.carry_out;
							alu_opcode <= ALU_SHCR;
							cpu_state <= STORE;

						when OP_SHCL =>
							alu_left <= accumulator;
							alu_carry_in <= flags.carry_out;
							alu_opcode <= ALU_SHCL;
							cpu_state <= STORE;

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


				when EXECUTE_ADD_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_ADD_2;
					
				when EXECUTE_ADD_2 =>
					cpu_state <= EXECUTE_ADD_3;

				when EXECUTE_ADD_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_ADD;
					cpu_state <= STORE;

				when EXECUTE_SUB_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_SUB_2;

				when EXECUTE_SUB_2 =>
					cpu_state <= EXECUTE_SUB_3;

				when EXECUTE_SUB_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_SUB;
					cpu_state <= STORE;

				when EXECUTE_SUBR_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_SUBR_2;

				when EXECUTE_SUBR_2 =>
					cpu_state <= EXECUTE_SUBR_3;

				when EXECUTE_SUBR_3 =>
					alu_left <= data_in;
					alu_right <= accumulator;
					alu_opcode <= ALU_SUB;
					cpu_state <= STORE;


				when EXECUTE_OR_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_OR_2;

				when EXECUTE_OR_2 =>
					cpu_state <= EXECUTE_OR_3;

				when EXECUTE_OR_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_OR;
					cpu_state <= STORE;

				when EXECUTE_XOR_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_XOR_2;

				when EXECUTE_XOR_2 =>
					cpu_state <= EXECUTE_XOR_3;

				when EXECUTE_XOR_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_XOR;
					cpu_state <= STORE;

				when EXECUTE_AND_1 =>
					address_bus <= data_in;
					cpu_state <= EXECUTE_AND_2;

				when EXECUTE_AND_2 =>
					cpu_state <= EXECUTE_AND_3;

				when EXECUTE_AND_3 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					alu_opcode <= ALU_AND;
					cpu_state <= STORE;


				when EXECUTE_JMP =>
					program_counter <= data_in;
					cpu_state <= FETCH_0;

				when STORE =>
					accumulator <= alu_result;
					flags <= alu_flags_in;
					cpu_state <= FETCH_0;

			end case;
		end if;
	end process;
end ahmes;

-- Ahmes VHDL

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

use work.opcodes.all;
use work.types.all;

entity core is
	port
	(
		clk					: in std_logic;
		reset				: in std_logic;
		error				: out std_logic;
		
		address_bus			: out std_logic_vector(7 downto 0);
		data_in				: in std_logic_vector(7 downto 0);
		data_out			: out std_logic_vector(7 downto 0);
		mem_write			: out std_logic;

		alu_opcode 			: out alu_opcode_type;
		alu_carry_in		: out std_logic;		
		alu_left			: out std_logic_vector(7 downto 0);
		alu_right			: out std_logic_vector(7 downto 0);
		alu_result			: in std_logic_vector(7 downto 0);
		alu_flags_in		: in ALU_flags;
		
		pio_address 		: out std_logic_vector(7 downto 0);
		pio_data_w			: out std_logic_vector(7 downto 0); -- data entering IO port 
		pio_data_r			: in std_logic_vector(7 downto 0);
		pio_write_enable	: out std_logic;
		pio_read_enable		: out std_logic;
		pio_io_ready		: in std_logic;
		
		debug_program_counter		: out std_logic_vector(7 downto 0);
		debug_accumulator	 		: out std_logic_vector(7 downto 0);
		debug_instruction_code		: out std_logic_vector(7 downto 0); 
		debug_cpu_state				: out cpu_state_type;

		debug_clk_counter			: out integer;
		debug_inst_counter			: out integer
		
	);
end core;

architecture ahmes of core is

	signal cpu_state 				: cpu_state_type;
	signal program_counter	 		: std_logic_vector(7 downto 0);
	signal accumulator	 			: std_logic_vector(7 downto 0);
	signal flags					: ALU_flags := (others => '0');
	signal instruction_code			: std_logic_vector(7 downto 0);
	
	signal clk_counter				: integer := 0;
	signal inst_counter				: integer := 0;
	
		
begin

	debug_program_counter <= program_counter;
	debug_accumulator	 <= accumulator;
	debug_instruction_code <=	instruction_code;
	debug_cpu_state <= cpu_state;

	debug_clk_counter	<= clk_counter;
	debug_inst_counter	<= inst_counter;


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
			
			clk_counter <= 0;
			inst_counter <= 0;

		elsif rising_edge(clk) 
		then
			clk_counter <= clk_counter + 1;

			mem_write <= '0'; -- set it off by default unless we want it 
			
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
					
					inst_counter <= inst_counter + 1;

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
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_ADD;

						when OP_ADDC =>
							alu_carry_in <= flags.carry_out;
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_ADD;

						when OP_SUB =>
							alu_carry_in <= '0';
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_SUB;

						when OP_SUBC =>
							alu_carry_in <= flags.carry_out;
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_SUB;

						when OP_NEG =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NEG;
							cpu_state <= STORE;

						when OP_OR =>
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_OR;

						when OP_AND =>
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_AND;

						when OP_XOR =>
							cpu_state <= EXECUTE_ALU_REGMEM_1;
							alu_opcode <= ALU_XOR;

						when OP_SHL =>
							cpu_state <= EXECUTE_ALU_REGCONST_1;
							alu_opcode <= ALU_SHL;

						when OP_SHR =>
							cpu_state <= EXECUTE_ALU_REGCONST_1;
							alu_opcode <= ALU_SHR;

						when OP_ROL =>
							cpu_state <= EXECUTE_ALU_REGCONST_1;
							alu_opcode <= ALU_ROL;

						when OP_ROR =>
							cpu_state <= EXECUTE_ALU_REGCONST_1;
							alu_opcode <= ALU_ROR;

						when OP_RCL =>
							cpu_state <= EXECUTE_ALU_REGCONST_1;
							alu_carry_in <= flags.carry_out;
							alu_opcode <= ALU_RCL;

						when OP_RCR =>
							cpu_state <= EXECUTE_ALU_REGCONST_1;
							alu_carry_in <= flags.carry_out;
							alu_opcode <= ALU_RCR;

						when OP_NOT =>
							alu_left <= accumulator;
							alu_opcode <= ALU_NOT;
							cpu_state <= STORE;

						when OP_IN => 
							cpu_state <= EXECUTE_PORT_IN_1;

						when OP_OUT => 
							cpu_state <= EXECUTE_PORT_OUT_1;

						when OP_JMP =>
							cpu_state <= EXECUTE_JMP;

						when OP_JMP_A =>
							cpu_state <= EXECUTE_JMP_A;

						when OP_JN | OP_JP =>
							if flags.negative = data_in(0) then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JV | OP_JNV =>
							if flags.overflow = data_in(0) then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JZ | OP_JNZ =>
							if flags.zero = data_in(0) then
								cpu_state <= EXECUTE_JMP;
							else
								cpu_state <= FETCH_0;
							end if;

						when OP_JC | OP_JNC =>
							if flags.carry_out = data_in(0) then
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
					cpu_state <= EXECUTE_STA_2;	-- go to FETCH_0 ?

 				when EXECUTE_STA_2 =>
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

				when EXECUTE_ALU_REGCONST_1 =>
					alu_left <= accumulator;
					alu_right <= data_in;
					cpu_state <= STORE;


				when EXECUTE_JMP =>
					program_counter <= data_in;
					cpu_state <= FETCH_0;

				when EXECUTE_JMP_A =>
					program_counter <= accumulator + data_in;
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

				when EXECUTE_PORT_IN_1 => 
					pio_address <= data_in;
					pio_read_enable <= '1';
					cpu_state <= EXECUTE_PORT_IN_2;
					
				when EXECUTE_PORT_IN_2 => 
					cpu_state <= EXECUTE_PORT_IN_3;

				when EXECUTE_PORT_IN_3 => 
					if pio_io_ready = '1' then 
						cpu_state <= FETCH_0;
						pio_read_enable <= '0';
						accumulator <= pio_data_r;
					end if;

				when EXECUTE_PORT_OUT_1 => 
					pio_address <= data_in;
					pio_write_enable <= '1';
					pio_data_w <= accumulator;
					cpu_state <= EXECUTE_PORT_OUT_2;
					
				when EXECUTE_PORT_OUT_2 => 
					cpu_state <= EXECUTE_PORT_OUT_3;
					
				when EXECUTE_PORT_OUT_3 => 
					if pio_io_ready = '1' then 
						cpu_state <= FETCH_0;
						pio_write_enable <= '0';
					end if;

			end case;
		end if;
	end process;
end ahmes;

-- FibPU

library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;
use work.types.all;


entity TB_core is
end TB_core;

architecture behavior of TB_core is
    -- Component Declaration for the Unit Under Test (UUT)
	component core is
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
			alu_flags_in		: in ALU_flags;

			debug_program_counter		: out std_logic_vector(7 downto 0);
			debug_accumulator	 			: out std_logic_vector(7 downto 0);
			debug_instruction_code		: out std_logic_vector(7 downto 0);
			debug_cpu_state				: out cpu_state_type
			
		);
	end component;	
	
	component memory
		port(
         clk : IN  std_logic;
         address_bus : IN  std_logic_vector(7 downto 0);
         data_write : IN  std_logic_vector(7 downto 0);
         data_read : OUT  std_logic_vector(7 downto 0);
         mem_write : IN  std_logic;
         rst : IN  std_logic
        );
   end component;
	
	component ALU is
		port
		(
			operation			: in alu_opcode_type;
			left_arg			: in std_logic_vector(7 downto 0);
			right_arg			: in std_logic_vector(7 downto 0);
			carry_in			: in std_logic;
			result				: out std_logic_vector(7 downto 0);
			flags				: out ALU_flags
		);
	end component;
	
	--Inputs into the core
	signal clk			: std_logic;
	signal reset		: std_logic;
	signal error		: std_logic;
	signal address_bus	: std_logic_vector(7 downto 0);
	signal data_in		: std_logic_vector(7 downto 0);
	signal data_out		: std_logic_vector(7 downto 0);
	signal mem_write	: std_logic;
	signal alu_opcode 	: alu_opcode_type;
	signal alu_carry_in		: std_logic;
	signal alu_left		: std_logic_vector(7 downto 0);
	signal alu_right	: std_logic_vector(7 downto 0);
	signal alu_result	: std_logic_vector(7 downto 0);
	signal alu_flags	: ALU_flags;

   -- Clock period definitions
   constant clk_period : time := 10 ns; 
	
	signal debug_program_counter		: std_logic_vector(7 downto 0);
	signal debug_accumulator	 		: std_logic_vector(7 downto 0);
	signal debug_instruction_code		: std_logic_vector(7 downto 0);
	signal debug_cpu_state				: cpu_state_type;

begin
 	-- Instantiate the Unit(s) Under Test (UUT)
	c: core port map(
		clk			=> clk,
		reset		=> reset,
		error		=> error,
		address_bus	=> address_bus,
		data_in		=> data_in,
		data_out	=> data_out,
		mem_write	=> mem_write,
		alu_opcode 	=> alu_opcode,
		alu_carry_in	=> alu_carry_in,
		alu_left	=> alu_left,
		alu_right	=> alu_right,
		alu_result	=> alu_result,
		alu_flags_in	=> alu_flags, 
		
		debug_program_counter	=> debug_program_counter,
		debug_accumulator	 	=> debug_accumulator,
		debug_instruction_code	=> debug_instruction_code,
		debug_cpu_state => debug_cpu_state
	);

	m: memory port map(
		clk => clk,
		address_bus => address_bus,
		data_write => data_out,
		data_read => data_in,
		mem_write => mem_write,
		rst => reset
	);

	a: ALU port map(
		operation => alu_opcode,
		left_arg	 => alu_left,
		right_arg => alu_right,
		carry_in	 => alu_carry_in,
		result	 => alu_result,
		flags		 => alu_flags
	);

clock_process: 
	process -- clock generator process 
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

stim_proc: 
   process   -- Stimulus process - main process that drives things 
   begin
		reset <= '1';
		wait for 200 ns;	
		reset <= '0';		
		
		wait for clk_period*1000; 
		
		wait;
   end process;

end behavior;
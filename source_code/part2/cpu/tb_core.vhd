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
			alu_flags		: in ALU_flags;
			
			pio_address 	: out std_logic_vector(7 downto 0);
			pio_data_w		: out std_logic_vector(7 downto 0); -- data entering IO port 
			pio_data_r		: in std_logic_vector(7 downto 0);
			pio_write_enable	: out std_logic;
			pio_read_enable		: out std_logic;
			pio_io_ready		: in std_logic
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
	signal pio_address 	: std_logic_vector(7 downto 0);
	signal pio_data_w	: std_logic_vector(7 downto 0); -- data entering IO port 
	signal pio_data_r	: std_logic_vector(7 downto 0);
	signal pio_write_enable	: std_logic;
	signal pio_read_enable	: std_logic;
	signal pio_io_ready		: std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns; 
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
		alu_flags	=> alu_flags,
		pio_address      => pio_address,
		pio_data_w	     => pio_data_w,	    
		pio_data_r	     => pio_data_r,	    
		pio_write_enable => pio_write_enable,
		pio_read_enable	 => pio_read_enable,
		pio_io_ready	 => pio_io_ready
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
		-- hold reset state for 100 ns.
		wait for 200 ns;	
		reset <= '0';
		
		-- anything that is an input - drive to some known state 
		alu_result <= "00000000";
		alu_flags <= ( zero => '1', others => '0'); -- set all flags to zero, except "zero"
		pio_data_r <= "00000000";		
		pio_io_ready <= '1';
		
		wait for clk_period/4; -- offset our sampling point into the middle of the positive pulse 
		
		-- CPU is executing the very first instruction, setting address bus to '0'
		-- feed the opcode back into it 		
		assert address_bus = 0 report "Address bus is not 0: " & Integer'image(address_bus);		
		-- give it NOP at address 0
		data_in <= OP_NOP;
		
		-- wait for the next clock cycle 
		wait for clk_period;
		
		-- not CPU is in 'decode' state, it must be fetching the next byte automatically
		assert address_bus = 1 report "Address bus is not 0: " & Integer'image(address_bus);
		-- give it another NOP at address 1
		data_in <= OP_NOP;

		-- wait for the next clock cycle 
		wait for clk_period;

		-- not CPU is in 'decode' state, it must be fetching the next byte automatically
		assert address_bus = 2 report "Address bus is not 0: " & Integer'image(address_bus);
		
		-- give it a JUMP
		data_in <= OP_JMP;
		
		-- wait for the next clock cycle 
		wait for clk_period;
		
		assert address_bus = 4 report "Address bus is not 0: " & Integer'image(address_bus);
		
		-- jump dst
		data_in <= "00000000";

		-- wait for the next clock cycle 
		wait for clk_period;

		assert address_bus = 0 report "Address bus is not 0: " & Integer'image(address_bus);
		
		wait;
   end process;

end behavior;

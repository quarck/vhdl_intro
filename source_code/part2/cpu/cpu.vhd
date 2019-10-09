library ieee ;
use ieee.std_logic_1164.all;
use work.opcodes.all;
use work.types.all;

entity cpu is
	port
	(
		clk				: in std_logic;
		reset			: in std_logic;
		error			: out std_logic;

		gpio_a			: in std_logic_vector (7 downto 0);
		gpio_b			: in std_logic_vector (7 downto 0);
		gpio_c			: out std_logic_vector (7 downto 0);
		gpio_d			: out std_logic_vector (7 downto 0)
	);
end cpu;

architecture structural of cpu is 

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

	component pio is 
		port (
			clk			: in std_logic;
			address 	: in std_logic_vector(7 downto 0);
			data_w		: in std_logic_vector(7 downto 0); -- data entering IO port 
			data_r		: out std_logic_vector(7 downto 0);
			write_enable	: in std_logic;
			read_enable		: in std_logic;
			io_ready		: out std_logic;
			gpio_a			: in std_logic_vector (7 downto 0);
			gpio_b			: in std_logic_vector (7 downto 0);
			gpio_c			: out std_logic_vector (7 downto 0);
			gpio_d			: out std_logic_vector (7 downto 0)		
		);
	end component;
	
	component memory is
		port
		(
			address_bus	: in integer range 0 to 255;
			data_in		: in std_logic_vector(7 downto 0);
			data_out	: out std_logic_vector(7 downto 0);
			mem_write	: in std_logic;
			rst			: in std_logic
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
begin
	c: core port map(
		clk					=> clk,
		reset				=> reset,
		error				=> error,
		address_bus			=> address_bus,
		data_in				=> data_in,
		data_out			=> data_out,
		mem_write			=> mem_write,
		alu_opcode 			=> alu_opcode,
		alu_carry_in		=> alu_carry_in,
		alu_left			=> alu_left,
		alu_right			=> alu_right,
		alu_result			=> alu_result,
		alu_flags			=> alu_flags,
		pio_address     	=> pio_address,
		pio_data_w	    	=> pio_data_w,	    
		pio_data_r	    	=> pio_data_r,	    
		pio_write_enable	=> pio_write_enable,
		pio_read_enable		=> pio_read_enable,
		pio_io_ready		=> pio_io_ready
	);
	
	p: pio port map (
		clk					=> clk,
		address 			=> pio_address,
		data_w				=> pio_data_w,
		data_r				=> pio_data_r,
		write_enable		=> pio_write_enable,
		read_enable			=> pio_read_enable,
		io_ready			=> pio_io_ready,
		gpio_a				=> pio_gpio_a,
		gpio_b				=> pio_gpio_b,
		gpio_c				=> pio_gpio_c,
		gpio_d				=> pio_gpio_d
	);
	
	a: ALU port map (
		operation			=> alu_opcode,
		left_arg			=> alu_left,
		right_arg			=> alu_right,
		carry_in			=> alu_carry_in,
		result				=> alu_result,
		flags				=> alu_flags
	);
	
	m: memory port map (
		address_bus			=> address_bus,
		data_in				=> data_in,
		data_out			=> data_out,
		mem_write			=> mem_write,
		rst					=> reset
	);
	
end structural;

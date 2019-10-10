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

		in_port_0		: in std_logic_vector (7 downto 0); -- dp switches 
		in_port_1		: in std_logic_vector (7 downto 0);	-- push btns
		in_port_2		: in std_logic_vector (7 downto 0); -- pin header 6
		in_port_3		: in std_logic_vector (7 downto 0); -- pin header 7

		out_port_4			: out std_logic_vector (7 downto 0); -- individual leds
		out_port_5			: out std_logic_vector (7 downto 0); -- 7-segment digits 
		out_port_6			: out std_logic_vector (7 downto 0); -- 7-segment enable signals 
		out_port_7			: out std_logic_vector (7 downto 0); -- pin header 8
		out_port_8			: out std_logic_vector (7 downto 0) -- pin header 9
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
			
			in_port_0		: in std_logic_vector (7 downto 0); -- dp switches 
			in_port_1		: in std_logic_vector (7 downto 0);	-- push btns
			in_port_2		: in std_logic_vector (7 downto 0); -- pin header 6
			in_port_3		: in std_logic_vector (7 downto 0); -- pin header 7

			out_port_4			: out std_logic_vector (7 downto 0); -- individual leds
			out_port_5			: out std_logic_vector (7 downto 0); -- 7-segment digits 
			out_port_6			: out std_logic_vector (7 downto 0); -- 7-segment enable signals 
			out_port_7			: out std_logic_vector (7 downto 0); -- pin header 8
			out_port_8			: out std_logic_vector (7 downto 0) -- pin header 9
		);
	end component;
	
	component memory is
		port
		(
			address_bus	: std_logic_vector(7 downto 0);
			data_write		: in std_logic_vector(7 downto 0);
			data_read	: out std_logic_vector(7 downto 0);
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
	signal from_cpu_to_mem	: std_logic_vector(7 downto 0);
	signal from_mem_to_cpu		: std_logic_vector(7 downto 0);
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
		data_in				=> from_mem_to_cpu,
		data_out			=> from_cpu_to_mem,
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
		
		in_port_0			=> in_port_0,
		in_port_1			=> in_port_1,
		in_port_2			=> in_port_2,
		in_port_3			=> in_port_3,

		out_port_4			=> out_port_4,
		out_port_5			=> out_port_5,
		out_port_6			=> out_port_6, 
		out_port_7			=> out_port_7,
		out_port_8			=> out_port_8
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
		data_write			=> from_cpu_to_mem,
		data_read			=> from_mem_to_cpu,
		mem_write			=> mem_write,
		rst					=> reset
	);
	
end structural;

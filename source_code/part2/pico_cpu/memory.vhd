library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
 
use work.opcodes.all;

entity memory is
	port
	(
		clk			: in std_logic; 
		address_bus	: in std_logic_vector(7 downto 0);
		data_write	: in std_logic_vector(7 downto 0);
		data_read	: out std_logic_vector(7 downto 0);
		mem_write	: in std_logic;
		rst			: in std_logic
	);
end memory;

architecture rtl of memory is

type mem_type is array (0 to 255) of std_logic_vector(7 downto 0);

signal mem: mem_type := (
	OP_LDC, b"00000001", -- A=1
	OP_STA, b"10000000", -- mem[128]=A
	OP_STA, b"10000001", -- mem[129]=A

-- addr 6:
	OP_LDA, b"10000000", -- mem[128]=A
	OP_ADD, b"10000001", -- A+=mem[129]
	OP_STA, b"10000010", -- mem[130]=A
	
	OP_LDA, b"10000001", -- A=mem[129]
	OP_STA, b"10000000", -- mem[128]=A
	
	OP_LDA, b"10000010", -- A=mem[130]
	OP_STA, b"10000001", -- mem[129]=A
		
	OP_JMP, b"00000110", -- jmp 6 

	others => b"00000000"
);

begin
	process (clk, rst, mem_write, address_bus, data_write)
	begin

		if rising_edge(clk) then
			if mem_write = '1' then 
				mem(to_integer(unsigned(address_bus))) <= data_write;
				data_read <= data_write;
			else 
				data_read <= mem(to_integer(unsigned(address_bus)));
			end if;			
		end if;
		
	end process;
end rtl;

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
	b"01110000", b"00000001", -- ldc 1
	b"01100000", b"10000000", -- sta 128
	b"01100000", b"10000001", -- sta 129

-- addr 6: (00000110)	
	b"01101000", b"10000000", -- lda 128
	b"01000000", b"10000001", -- add 129
	b"01100000", b"10000010", -- sta 130
	
	b"01101000", b"10000001", -- lda 129
	b"01100000", b"10000000", -- sta 128
	
	b"01101000", b"10000010", -- lda 130
	b"01100000", b"10000001", -- sta 129
		
	b"10100000", b"00000110", -- jmp 6 "00000110"

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

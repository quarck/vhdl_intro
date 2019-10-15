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

constant c_0  : std_logic_vector(7 downto 0):="00000000";
constant c_1  : std_logic_vector(7 downto 0):="00000001";
constant c_2  : std_logic_vector(7 downto 0):="00000010";
constant c_3  : std_logic_vector(7 downto 0):="00000011";
constant c_4  : std_logic_vector(7 downto 0):="00000100";
constant c_5  : std_logic_vector(7 downto 0):="00000101";
constant c_6  : std_logic_vector(7 downto 0):="00000110";
constant c_7  : std_logic_vector(7 downto 0):="00000111";
constant c_8  : std_logic_vector(7 downto 0):="00001000";

constant c_A  : std_logic_vector(7 downto 0):=b"10000000";
constant c_B  : std_logic_vector(7 downto 0):=b"10000001";
constant c_C  : std_logic_vector(7 downto 0):=b"10000010";

signal mem: mem_type:= (
	OP_LDC, c_1,
	OP_STA, c_A,
	OP_STA, c_B,

-- addr 6:
	OP_LDA, c_A,
	OP_ADD, c_B,
	OP_STA, c_C,

	OP_LDA, c_B,
	OP_STA, c_A,

	OP_LDA, c_C,
	OP_STA, c_B,

	OP_OUT, c_4, 
	OP_OUT, c_5, 
	OP_OUT, c_6, 
	OP_OUT, c_7, 
	OP_OUT, c_8, 
		
	OP_JMP, c_6,

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

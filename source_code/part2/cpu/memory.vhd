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
		mem_read	: in std_logic;
		mem_write	: in std_logic;
		rst			: in std_logic
	);
end memory;

architecture rtl of memory is

type mem_type is array (0 to 255) of std_logic_vector(7 downto 0);

-- 16-bits of A
constant A0  : std_logic_vector(7 downto 0) := x"F0";
constant A1  : std_logic_vector(7 downto 0) := x"F1";
-- 16-bits of B
constant B0  : std_logic_vector(7 downto 0) := x"F2";
constant B1  : std_logic_vector(7 downto 0) := x"F3";
-- 16-bits of C
constant C0  : std_logic_vector(7 downto 0) := x"F4";
constant C1  : std_logic_vector(7 downto 0) := x"F5";
-- 24 bits of sleep cnt
constant S0  : std_logic_vector(7 downto 0) := x"F6";
constant S1  : std_logic_vector(7 downto 0) := x"F7";
constant S2  : std_logic_vector(7 downto 0) := x"F8";

signal mem: mem_type:= (
-- addr 0: start:
	OP_LDC, x"01",
	OP_STA, A0,
	OP_STA, B0,
	
	OP_LDC, x"00",
	OP_STA, A1,
	OP_STA, B1,

-- addr 12: loop: 
	OP_LDA, A0,
	OP_ADD, B0,
	OP_STA, C0,
	OP_LDA, A1,
	OP_ADDC, B1,
	OP_STA, C1,
	

	OP_LDA, B0,
	OP_STA, A0,
	OP_LDA, B1,
	OP_STA, A1,

	OP_LDA, C0,
	OP_STA, B0,
	OP_LDA, C1,
	OP_STA, B1,
	
	-- now - display the thing 
	OP_LDC, x"00", 	-- select LCD display
	OP_OUT, x"06", 
	OP_LDA, C0,			-- output the number part
	OP_SEVENSEGTRANSLATE, x"00",
	OP_OUT, x"05",
	
	OP_LDC, x"01", 	-- select LCD display
	OP_OUT, x"06",
	OP_LDA, C0,			-- output the number part
	OP_SEVENSEGTRANSLATE, x"04",
	OP_OUT, x"05",

	OP_LDC, x"02", 	-- select LCD display
	OP_OUT, x"06",
	OP_LDA, C1,			-- output the number part
	OP_SEVENSEGTRANSLATE, x"00",
	OP_OUT, x"05",
	
	OP_LDA, C0,	-- output the number part into 8-leds 		
	OP_OUT, x"04", 

-- 0x4a == : sleep_start: 
	OP_LDC, x"ff", 
	OP_STA, S0,
	OP_STA, S1,
	OP_LDC, x"0f",
	OP_STA, S2,

-- 0x54: sleep_loop: 
	OP_LDA, S0,
	OP_SUB_V, x"01",
	OP_STA, S0,
	OP_LDA, S1,
	OP_SUBC_V, x"00",
	OP_STA, S1,
	OP_LDA, S2,
	OP_SUBC_V, x"00",
	OP_STA, S2,
	OP_JNZ, x"54",
	
	OP_LDA, C1,
	OP_AND_V, x"f0",
	OP_JNZ, x"00", -- go start if we'v exceeded 12-bit range
	OP_JMP, x"0c", -- go loop

	others => x"00"
);

begin
	process (clk, rst, mem_write, address_bus, data_write)
	begin

		if rising_edge(clk) 
		then
			if mem_write = '1' 
			then 
				mem(to_integer(unsigned(address_bus))) <= data_write;
				data_read <= data_write;				
			elsif mem_read = '1' 
			then 			
				data_read <= mem(to_integer(unsigned(address_bus)));
			end if;			
		end if;
		
	end process;
end rtl;

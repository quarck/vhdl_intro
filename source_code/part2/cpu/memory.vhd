library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity memory is
	port
	(
		address_bus	: in integer range 0 to 255;
		data_in		: in integer range 0 to 255;
		data_out		: out integer range 0 to 255;
		mem_write	: in std_logic;
		rst			: in std_logic
	);
end memory;

architecture rtl of memory is

	constant nop : integer := 0;
	constant sta : integer := 16;
	constant lda : integer := 32;
	constant add : integer := 48;
	constant ior : integer := 64;
	constant iand: integer := 80;
	constant inot: integer := 96;
	constant sub : integer := 112;
	constant jmp : integer := 128;
	constant jn  : integer := 144;
	constant jp  : integer := 148;
	constant jv  : integer := 152;
	constant jnv : integer := 156;
	constant jz  : integer := 160;
	constant jnz : integer := 164;
	constant jc  : integer := 176;
	constant jnc : integer := 180;
	constant jb  : integer := 184;
	constant jnb : integer := 188;
	constant shr : integer := 224;
	constant shl : integer := 225;
	constant iror: integer := 226;
	constant irol: integer := 227;
	constant hlt : integer := 240;

type data is array (0 to 255) of integer;

begin
	process (mem_write,rst)
		variable data_array: data;
	begin
		if (rst='1') then
			data_array(0) := lda;
			data_array(1) := 130;	
			data_array(2) := sub;
			data_array(3) := 132;
			data_array(4) := jz;	
			data_array(5) := 8;
			data_array(6) := jmp;
			data_array(7) := 2;
			data_array(8) := lda;
			data_array(9) := 130;
			data_array(10) := add;
			data_array(11) := 131;
			data_array(12) := sta;
			data_array(13) := 128;
			data_array(14) := lda;	
			data_array(15) := 129;
			data_array(16) := shl;
			data_array(17) := shl;
			data_array(18) := shl;
			data_array(19) := shl;
			data_array(20) := ior;
			data_array(21) := 128;
			data_array(22) := sta;
			data_array(23) := 133;
			data_array(24) := hlt;
			
			data_array(128) := 0;
			data_array(129) := 5;
			data_array(130) := 10;
			data_array(131) := 18;
			data_array(132) := 1;
		elsif (rising_edge(mem_write)) then
			data_array(address_bus) := data_in;			
		end if;
		data_out <= data_array(address_bus);
	end process;
end rtl;

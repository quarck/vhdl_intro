library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all;

use work.opcodes.all;

entity memory is
	port
	(
		address_bus	: in integer range 0 to 255;
		data_in		: in std_logic_vector(7 downto 0);
		data_out	: out std_logic_vector(7 downto 0);
		mem_write	: in std_logic;
		rst			: in std_logic
	);
end memory;

architecture rtl of memory is


type data is array (0 to 255) of std_logic_vector(7 downto 0);

begin
	process (mem_write,rst)
		variable data_array: data;
	begin
		if (rst='1') then
			data_array(0) := OP_LDA;
			data_array(1) := conv_std_logic_vector(130, 8);	
			data_array(2) := OP_SUB;
			data_array(3) := conv_std_logic_vector(132, 8);	
			data_array(4) := OP_JZ;	
			data_array(5) := conv_std_logic_vector(8, 8);	
			data_array(6) := OP_JMP;
			data_array(7) := conv_std_logic_vector(2, 8);	
			data_array(8) := OP_LDA;
			data_array(9) := conv_std_logic_vector(130, 8);	
			data_array(10) := OP_ADD;
			data_array(11) := conv_std_logic_vector(131, 8);	
			data_array(12) := OP_STA;
			data_array(13) := conv_std_logic_vector(128, 8);	
			data_array(14) := OP_LDA;	
			data_array(15) := conv_std_logic_vector(129, 8);	
			data_array(16) := OP_SHL;
			data_array(17) := OP_SHL;
			data_array(18) := OP_SHL;
			data_array(19) := OP_SHL;
			data_array(20) := OP_IOR;
			data_array(21) := conv_std_logic_vector(128, 8);	
			data_array(22) := OP_STA;
			data_array(23) := conv_std_logic_vector(133, 8);	
			data_array(24) := OP_HLT;
			
			data_array(128) := conv_std_logic_vector(0, 8);	
			data_array(129) := conv_std_logic_vector(5, 8);	
			data_array(130) := conv_std_logic_vector(10, 8);	
			data_array(131) := conv_std_logic_vector(18, 8);	
			data_array(132) := conv_std_logic_vector(1, 8);	

		elsif (rising_edge(mem_write)) then
			data_array(address_bus) := data_in;			
		end if;
		data_out <= data_array(address_bus);
	end process;
end rtl;

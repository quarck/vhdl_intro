library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all; 
 
use work.opcodes.all;

entity memory is
	port
	(
		address_bus	: std_logic_vector(7 downto 0);
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
		
			data_array( 0) :=	OP_LDC;
			data_array( 1) :=	conv_std_logic_vector(1, 8);
			data_array( 2) :=	OP_STA;
			data_array( 3) :=	conv_std_logic_vector(16#80#, 8);	
			data_array( 4) :=	OP_STA;
			data_array( 5) :=	conv_std_logic_vector(16#82#, 8);	
			data_array( 6) :=	OP_LDC;
			data_array( 7) :=	conv_std_logic_vector(0, 8);	
			data_array( 8) :=	OP_STA ;
			data_array( 9) :=	conv_std_logic_vector(16#81#, 8);	
			data_array(10) :=	OP_STA;
			data_array(11) :=	conv_std_logic_vector(16#83#, 8);	
			data_array(12) :=	OP_STA ;
			data_array(13) :=	conv_std_logic_vector(16#84#, 8);	
			data_array(14) :=	OP_STA ;
			data_array(15) :=	conv_std_logic_vector(16#85#, 8);	
			data_array(16) :=	OP_LDA	;
			data_array(17) :=	conv_std_logic_vector(16#80#, 8);	
			data_array(18) :=	OP_ADD	;
			data_array(19) :=	conv_std_logic_vector(16#82#, 8);	
			data_array(20) :=	OP_STA	;
			data_array(21) :=	conv_std_logic_vector(16#84#, 8);	
			data_array(22) :=	OP_OUT	;
			data_array(23) :=	conv_std_logic_vector(0, 8);	
			data_array(24) :=	OP_LDA	;
			data_array(25) :=	conv_std_logic_vector(16#81#, 8);	
			data_array(26) :=	OP_ADDC ;
			data_array(27) :=	conv_std_logic_vector(16#83#, 8);	
			data_array(28) :=	OP_STA	;
			data_array(29) :=	conv_std_logic_vector(16#85#, 8);	
			data_array(30) :=	OP_OUT ;
			data_array(31) :=	conv_std_logic_vector(1, 8);	
			data_array(32) :=	OP_LDA 	;
			data_array(33) :=	conv_std_logic_vector(16#82#, 8);	
			data_array(34) :=	OP_STA 	;
			data_array(35) :=	conv_std_logic_vector(16#80#, 8);	
			data_array(36) :=	OP_LDA	;
			data_array(37) :=	conv_std_logic_vector(16#83#, 8);	
			data_array(38) :=	OP_STA 	;
			data_array(39) :=	conv_std_logic_vector(16#81#, 8);	
			data_array(40) :=	OP_LDA 	;
			data_array(41) :=	conv_std_logic_vector(16#84#, 8);	
			data_array(42) :=	OP_STA	;
			data_array(43) :=	conv_std_logic_vector(16#82#, 8);	
			data_array(44) :=	OP_LDA	;
			data_array(45) :=	conv_std_logic_vector(16#85#, 8);	
			data_array(46) :=	OP_STA	;
			data_array(47) :=	conv_std_logic_vector(16#83# , 8);	
			data_array(48) :=	OP_LDC ;
			data_array(49) :=	conv_std_logic_vector(255, 8);	
			data_array(50) :=	OP_STA	;
			data_array(51) :=	conv_std_logic_vector(16#86#, 8);	
			data_array(52) :=	OP_STA	;
			data_array(53) :=	conv_std_logic_vector(16#87#, 8);	
			data_array(54) :=	OP_LDC ;
			data_array(55) :=	conv_std_logic_vector(1, 8);	
			data_array(56) :=	OP_SUB	;
			data_array(57) :=	conv_std_logic_vector(16#86#, 8);	
			data_array(58) :=	OP_STA	;
			data_array(59) :=	conv_std_logic_vector(16#86#, 8);	
			data_array(60) :=	OP_LDC ;
			data_array(61) :=	conv_std_logic_vector(0, 8);	
			data_array(62) :=	OP_SUBC ;
			data_array(63) :=	conv_std_logic_vector(16#87#, 8);	
			data_array(64) :=	OP_STA	;
			data_array(65) :=	conv_std_logic_vector(16#87#, 8);	
			data_array(66) :=	OP_JNZ ;
			data_array(67) :=	conv_std_logic_vector(16#36#, 8);	
			data_array(68) :=	OP_JMP ;
			data_array(69) :=	conv_std_logic_vector(16#10#, 8);	

		elsif (rising_edge(mem_write)) then
			data_array(to_integer(ieee.NUMERIC_STD.unsigned(address_bus))) := data_in;			
		end if;
		data_out <= data_array(to_integer(ieee.NUMERIC_STD.unsigned(address_bus)));
	end process;
end rtl;

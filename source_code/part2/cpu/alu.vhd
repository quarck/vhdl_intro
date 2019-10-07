library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity ALU is
	port
	(
		operation	: in std_logic_vector (3 downto 0);
		left_arg	: in std_logic_vector(7 downto 0);
		right_arg	: in std_logic_vector(7 downto 0);
		result		: buffer std_logic_vector(7 downto 0);
		cin			: in std_logic;
		n,z,c,b,v 	: buffer std_logic		
	);
end ALU;

architecture ula1 of ula is
constant adic : std_logic_vector(3 downto 0):="0001";
constant sub  : std_logic_vector(3 downto 0):="0010";
constant ou   : std_logic_vector(3 downto 0):="0011";
constant e    : std_logic_vector(3 downto 0):="0100";
constant nao  : std_logic_vector(3 downto 0):="0101";
constant dle  : std_logic_vector(3 downto 0):="0110";
constant dld  : std_logic_vector(3 downto 0):="0111";
constant dae  : std_logic_vector(3 downto 0):="1000";
constant dad  : std_logic_vector(3 downto 0):="1001";

begin
	process (left_arg, right_arg, operation,result,cin)
	variable temp : std_logic_vector(8 downto 0);
	begin
		case operation is
		when adic =>
			temp := ('0'&left_arg) + ('0'&right_arg);
			result <= temp(7 downto 0);
			c <= temp(8);
			if (left_arg(7)=right_arg(7)) then
				if (left_arg(7) /= result(7)) then v <= '1';
					else v <= '0';
				end if;
			else v <= '0';
			end if;
		when sub =>
			temp := ('0'&left_arg) - ('0'&right_arg);
			result <= temp(7 downto 0);
			b <= temp(8);
			if (left_arg(7) /= right_arg(7)) then
				if (left_arg(7) /= result(7)) then v <= '1';
					else v <= '0';
				end if;
			else v <= '0';
			end if;
		when ou =>
			result <= left_arg or right_arg;
		when e =>
			result <= left_arg and right_arg;
		when nao =>
			result <= not left_arg;
		when dle =>
			c <= left_arg(7);
			result(7) <= left_arg(6);
			result(6) <= left_arg(5);
			result(5) <= left_arg(4);
			result(4) <= left_arg(3);
			result(3) <= left_arg(2);
			result(2) <= left_arg(1);
			result(1) <= left_arg(0);
			result(0) <= cin;
		when dae =>
			c <= left_arg(7);
			result(7) <= left_arg(6);
			result(6) <= left_arg(5);
			result(5) <= left_arg(4);
			result(4) <= left_arg(3);
			result(3) <= left_arg(2);
			result(2) <= left_arg(1);
			result(1) <= left_arg(0);
			result(0) <= '0';
		when dld =>
			c <= left_arg(0);
			result(0) <= left_arg(1);
			result(1) <= left_arg(2);
			result(2) <= left_arg(3);
			result(3) <= left_arg(4);
			result(4) <= left_arg(5);
			result(5) <= left_arg(6);
			result(6) <= left_arg(7);
			result(7) <= cin;
		when dad =>
			c <= left_arg(0);
			result(0) <= left_arg(1);
			result(1) <= left_arg(2);
			result(2) <= left_arg(3);
			result(3) <= left_arg(4);
			result(4) <= left_arg(5);
			result(5) <= left_arg(6);
			result(6) <= left_arg(7);
			result(7) <= '0';		
		when others =>
			result <= "00000000";
			z <= '0';
			n <= '0';
			c <= '0';
			v <= '0';
			b <= '0';
		end case;
		if (result="00000000") then 
			z <= '1'; else z <= '0';
		end if;
		n <= result(7);
	end process;
end ula1;
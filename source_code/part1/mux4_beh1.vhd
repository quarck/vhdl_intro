library IEEE;
use IEEE.std_logic_1164.all;

entity mux4_beh1 is
port(
  a       : in  std_logic;
  b       : in  std_logic;
  c 		 : in  std_logic;
  d		 : in	 std_logic;
  s       : in  std_logic_vector(1 downto 0);
  z       : out std_logic);
end mux4_beh1;

architecture behv1 of mux4_beh1 is
begin
	process(a, b, c, d, s)
   begin
		case s is
				 when "00" =>	Z <= a;
				 when "01" =>	Z <= b;
				 when "10" =>	Z <= c;
				 when others =>	Z <= d;
		end case;

   end process;
end behv1;


library IEEE;
use IEEE.std_logic_1164.all;

entity mux4_beh2 is
port(
  a       : in  std_logic;
  b       : in  std_logic;
  c 		 : in  std_logic;
  d		 : in	 std_logic;
  s       : in  std_logic_vector(1 downto 0);
  z       : out std_logic);
end mux4_beh2;

architecture behv of mux4_beh2 is
begin
    Z <=	a when S="00" else
			b when S="01" else
			c when S="10" else
			d ;
end behv;


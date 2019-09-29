library IEEE;
use IEEE.std_logic_1164.all;

entity mux4 is
port(
  a       : in  std_logic;
  b       : in  std_logic;
  c 		 : in  std_logic;
  d		 : in	 std_logic;
  s       : in  std_logic_vector(1 downto 0);
  z       : out std_logic);
end mux4;

architecture rtl of mux4 is
begin
  with s select
	z <= a when "00",
		  b when "01", 
		  c when "10", 
	     d when others;
end rtl;


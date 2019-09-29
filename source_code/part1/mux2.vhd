library IEEE;
use IEEE.std_logic_1164.all;

entity mux2 is
port(
  a       : in  std_logic;
  b       : in  std_logic;
  s       : in  std_logic;
  z       : out std_logic);
end mux2;

architecture rtl of mux2 is
begin
  with s select
	z <= a when '0',
	     b when others;
end rtl;

---------------------------------------
---------------------------------------
---------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity XOR_GATE is 
	port (
		L, R : in std_logic;
		Z : out std_logic);
end XOR_GATE;

architecture rtl of XOR_GATE is 
begin
	Z <= L xor R;
end rtl;

---------------------------------------
---------------------------------------
---------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity AND_GATE is 
	port (
		L, R : in std_logic;
		Z : out std_logic);
end AND_GATE;

architecture rtl of AND_GATE is 
begin
	Z <= L and R;
end rtl;

---------------------------------------
---------------------------------------
---------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity OR_GATE is 
	port (
		L, R : in std_logic;
		Z : out std_logic);
end OR_GATE;

architecture rtl of OR_GATE is 
begin
	Z <= L or R;
end rtl;


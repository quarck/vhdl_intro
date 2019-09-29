library IEEE;
use IEEE.std_logic_1164.all;

entity clk_div2 is
port(
  clk   			: in  std_logic;
  clk_out		: out std_logic);
end clk_div2;

architecture rtl of clk_div2 is
	signal q: std_logic := '0';
begin
	q <= not q when rising_edge(clk);
	clk_out <= q;
end rtl;


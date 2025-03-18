Library IEEE;
USE IEEE.std_logic_1164.all;

ENTITY REGN IS
GENERIC (N : integer);
PORT(Dado : IN std_logic_vector(N-1 DOWNTO 0);
     clk,reset : in std_logic;
     Q : OUT std_logic_vector(N-1 DOWNTO 0));
END REGN;

architecture arq of REGN is
begin

P0: process(Dado,clk,reset)
    begin
	     if reset = '1' then
		     Q <= (others => '0');
		  elsif rising_edge(clk) then
				Q <= Dado;
		  end if;
	 end process;
	 
end arq;


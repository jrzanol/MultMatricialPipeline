LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SOMADOR6 IS
PORT (c0: IN STD_LOGIC;
		a, b: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		s: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		cOut: OUT STD_LOGIC
);
END SOMADOR6;

ARCHITECTURE arch OF SOMADOR6 IS
  SIGNAL carryTmp: STD_LOGIC_VECTOR (5 DOWNTO 0);
  
COMPONENT SOMADOR IS
PORT (cin, a, b : IN STD_LOGIC;
		s, cout : OUT STD_LOGIC);
END COMPONENT;

BEGIN
	SC0: SOMADOR PORT MAP (c0, a(0), b(0), s(0), carryTmp(0));

	GEN: FOR i IN 1 TO 5 GENERATE
		SC: SOMADOR PORT MAP (
			cin => carryTmp(i-1),
			a => a(i),
			b => b(i),
			s => s(i),
			cout => carryTmp(i)
		);
	END GENERATE;

	cOut <= carryTmp(5);
END arch;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MultMatricial IS
	PORT(CLK, RESET: IN STD_LOGIC;
		A, B: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		M: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
END MultMatricial;

ARCHITECTURE arch OF MultMatricial IS
	TYPE ANDPARTIAL_ARRAY IS ARRAY (0 TO 5) OF STD_LOGIC_VECTOR(5 DOWNTO 0);
	TYPE SUMPARTIAL_ARRAY IS ARRAY (0 TO 4) OF STD_LOGIC_VECTOR(5 DOWNTO 0);

	COMPONENT SOMADOR6 IS
	PORT (c0: IN STD_LOGIC;
		a, b: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		s: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		cOut: OUT STD_LOGIC
	);
	END COMPONENT;

	COMPONENT REGN IS
		GENERIC (N : integer);
		PORT(Dado : IN std_logic_vector(N-1 DOWNTO 0);
			clk,reset : in std_logic;
			Q : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT;

	-- Estágio 1:
	SIGNAL regA, regB: STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL stage1_varAnds: ANDPARTIAL_ARRAY;
	
	-- Estágio 2:
	SIGNAL stage2_varAnds: ANDPARTIAL_ARRAY;
	SIGNAL stage2_partialSum: SUMPARTIAL_ARRAY;
	SIGNAL stage2_partialCarries: STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	-- Estágio 3:
	SIGNAL stage3_varAnds: ANDPARTIAL_ARRAY;
	SIGNAL stage3_partialSum: SUMPARTIAL_ARRAY;
	SIGNAL stage3_partialSumOut: SUMPARTIAL_ARRAY;
	SIGNAL stage3_partialCarries: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL stage3_partialCarriesOut: STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	-- Estágio 4:
	SIGNAL stage4_varAnds: ANDPARTIAL_ARRAY;
	SIGNAL stage4_partialSum: SUMPARTIAL_ARRAY;
	SIGNAL stage4_partialSumOut: SUMPARTIAL_ARRAY;
	SIGNAL stage4_partialCarries: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL stage4_partialCarriesOut: STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	-- Estágio 5:
	SIGNAL stage5_result: STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN
	-- Estágio 1: Registra as entradas e calcula os valores dos AND's:
	REG_A: REGN GENERIC MAP(N => 6) PORT MAP (A, CLK, RESET, regA);
	REG_B: REGN GENERIC MAP(N => 6) PORT MAP (B, CLK, RESET, regB);
	
	ANDGEN: FOR i IN 0 TO 5 GENERATE
		ANDGEN2: FOR j IN 0 TO 5 GENERATE
			stage1_varAnds(i)(j) <= regA(i) AND regB(j);
		END GENERATE ANDGEN2;
	END GENERATE ANDGEN;
	
	-- Estágio 2: Registra os AND's do Estágio 1 e realiza a primeira soma parcial:
	REG_VARAND_12: FOR i IN 0 TO 5 GENERATE
		REG_AND: REGN GENERIC MAP(N => 6) PORT MAP (stage1_varAnds(i), CLK, RESET, stage2_varAnds(i));
	END GENERATE REG_VARAND_12;
	
	stage2_partialSum(1) <= (OTHERS => '0');
	stage2_partialSum(2) <= (OTHERS => '0');
	stage2_partialSum(3) <= (OTHERS => '0');
	stage2_partialSum(4) <= (OTHERS => '0');
	stage2_partialCarries(1) <= '0';
	stage2_partialCarries(2) <= '0';
	stage2_partialCarries(3) <= '0';
	stage2_partialCarries(4) <= '0';
	
	SUM0: SOMADOR6 PORT MAP (
		c0 => '0',
		a => ('0' & stage2_varAnds(0)(5 DOWNTO 1)),
		b => stage2_varAnds(1),
		s => stage2_partialSum(0),
		cOut => stage2_partialCarries(0)
	);
	
	-- Estágio 3: Realiza a segunda e terceira soma parcial:
	REG_VARAND_23: FOR i IN 0 TO 5 GENERATE
		REG_AND2: REGN GENERIC MAP(N => 6) PORT MAP (stage2_varAnds(i), CLK, RESET, stage3_varAnds(i));
	END GENERATE REG_VARAND_23;
	
	REG_PARTIALSUM_23: FOR i IN 0 TO 4 GENERATE
		REG_SUM2: REGN GENERIC MAP(N => 6) PORT MAP (stage2_partialSum(i), CLK, RESET, stage3_partialSum(i));
	END GENERATE REG_PARTIALSUM_23;
	
	REG_CARRY2: REGN GENERIC MAP(N => 5) PORT MAP (stage2_partialCarries, CLK, RESET, stage3_partialCarries);
	
	stage3_partialSumOut(0) <= stage3_partialSum(0);
	stage3_partialSumOut(3) <= stage3_partialSum(3);
	stage3_partialSumOut(4) <= stage3_partialSum(4);
	stage3_partialCarriesOut(0) <= stage3_partialCarries(0);
	stage3_partialCarriesOut(3) <= stage3_partialCarries(3);
	stage3_partialCarriesOut(4) <= stage3_partialCarries(4);
	
	SUM1: SOMADOR6 PORT MAP (
		c0 => '0',
		a => stage3_partialCarriesOut(0) & stage3_partialSumOut(0)(5 DOWNTO 1),
		b => stage3_varAnds(2),
		s => stage3_partialSumOut(1),
		cOut => stage3_partialCarriesOut(1)
	);
	
	SUM2: SOMADOR6 PORT MAP (
		c0 => '0',
		a => stage3_partialCarriesOut(1) & stage3_partialSumOut(1)(5 DOWNTO 1),
		b => stage3_varAnds(3),
		s => stage3_partialSumOut(2),
		cOut => stage3_partialCarriesOut(2)
	);
	
	-- Estágio 4: Realiza as últimas somas parciais:
	REG_VARAND_34: FOR i IN 0 TO 5 GENERATE
		REG_AND3: REGN GENERIC MAP(N => 6) PORT MAP (stage3_varAnds(i), CLK, RESET, stage4_varAnds(i));
	END GENERATE REG_VARAND_34;
	
	REG_PARTIALSUM_34: FOR i IN 0 TO 4 GENERATE
		REG_SUM3: REGN GENERIC MAP(N => 6) PORT MAP (stage3_partialSumOut(i), CLK, RESET, stage4_partialSum(i));
	END GENERATE REG_PARTIALSUM_34;
	
	REG_CARRY3: REGN GENERIC MAP(N => 5) PORT MAP (stage3_partialCarriesOut, CLK, RESET, stage4_partialCarries);
	
	stage4_partialSumOut(0) <= stage4_partialSum(0);
	stage4_partialSumOut(1) <= stage4_partialSum(1);
	stage4_partialSumOut(2) <= stage4_partialSum(2);
	stage4_partialCarriesOut(0) <= stage4_partialCarries(0);
	stage4_partialCarriesOut(1) <= stage4_partialCarries(1);
	stage4_partialCarriesOut(2) <= stage4_partialCarries(2);
	
	SUM3: SOMADOR6 PORT MAP (
		c0 => '0',
		a => stage4_partialCarriesOut(2) & stage4_partialSumOut(2)(5 DOWNTO 1),
		b => stage4_varAnds(4),
		s => stage4_partialSumOut(3),
		cOut => stage4_partialCarriesOut(3)
	);
	
	SUM4: SOMADOR6 PORT MAP (
		c0 => '0',
		a => (stage4_partialCarriesOut(3) & stage4_partialSumOut(3)(5 DOWNTO 1)),
		b => stage4_varAnds(5),
		s => stage4_partialSumOut(4),
		cOut => stage4_partialCarriesOut(4)
	);
	
	-- Estágio 5: Registra os resultados parciais e constrói o resultado final:
	REG_LSB0: REGN GENERIC MAP(N => 1) PORT MAP (stage4_varAnds(0)(0 DOWNTO 0), CLK, RESET, stage5_result(0 DOWNTO 0));
	REG_MID0: REGN GENERIC MAP(N => 1) PORT MAP (stage4_partialSumOut(0)(0 DOWNTO 0), CLK, RESET, stage5_result(1 DOWNTO 1));
	REG_MID1: REGN GENERIC MAP(N => 1) PORT MAP (stage4_partialSumOut(1)(0 DOWNTO 0), CLK, RESET, stage5_result(2 DOWNTO 2));
	REG_MID2: REGN GENERIC MAP(N => 1) PORT MAP (stage4_partialSumOut(2)(0 DOWNTO 0), CLK, RESET, stage5_result(3 DOWNTO 3));
	REG_MID3: REGN GENERIC MAP(N => 1) PORT MAP (stage4_partialSumOut(3)(0 DOWNTO 0), CLK, RESET, stage5_result(4 DOWNTO 4));
	
	REG_LAST: REGN GENERIC MAP(N => 6) PORT MAP (stage4_partialSumOut(4), CLK, RESET, stage5_result(10 DOWNTO 5));
	REG_CARR: REGN GENERIC MAP(N => 1) PORT MAP (stage4_partialCarriesOut(4 DOWNTO 4), CLK, RESET, stage5_result(11 DOWNTO 11));
	
	M <= stage5_result;
END arch;


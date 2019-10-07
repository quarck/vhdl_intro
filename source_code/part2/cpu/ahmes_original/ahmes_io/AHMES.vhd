-- Ahmes VHDL
-- Baseado na CPU hipot�tica criada pelo professor Dr. Raul Fernando Weber da UFRGS
-- Para maiores informa��es consulte:
-- - Livro texto: Fundamentos de Arquitetura de Computadores (Raul Fernando Weber - Editora Sagra-Luzzato)
-- Simuladores, montador assembly e outras informa��es sobre o Ahmes e outras CPUs hipot�ticas:
-- ftp://ftp.inf.ufrgs.br/pub/inf107
-- ftp://ftp.inf.ufrgs.br/pub/inf108

-- Autores: 	F�bio Pereira (fabio.jve@gmail.com)
--          	Roberto do Amaral Sales (amaral@amaral.eng.br)
-- Vers�o 1.0 - 02/10/2007

-- Instru��es:

-- Mnem�nico	Operando	Opera��o							Flags afetados
-- NOP			nenhum		nenhuma								nenhum
-- STA			endere�o	MEM(end)<-AC						nenhum
-- LDA			endere�o	AC<-MEM(end)						N,Z
-- ADD			endere�o	AC<-AC+MEM(end)						N,Z,V,C
-- OR			endere�o	AC<-AC or MEM(end)					N,Z
-- AND			endere�o	AC<-AC and MEM(end)					N,Z
-- NOT			nenhum		AC<-NOT AC							N,Z
-- SUB			endere�o	AC<-AC - MEM(end)					N,Z,V,B
-- JMP			endere�o	PC<-endere�o						nenhum
-- JN			endere�o	if N=1 PC<-endere�o					nenhum
-- JP			endere�o	if N=0 PC<-endere�o					nenhum
-- JV			endere�o	if V=1 PC<-endere�o 				nenhum
-- JNV			endere�o	if V=0 PC<-endere�o 				nenhum
-- JZ			endere�o	if Z=1 PC<-endere�o 				nenhum
-- JNZ			endere�o	if Z=0 PC<-endere�o 				nenhum
-- JC			endere�o	if C=1 PC<-endere�o					nenhum
-- JNC			endere�o	if C=0 PC<-endere�o 				nenhum
-- JB			endere�o	if B=1 PC<-endere�o 				nenhum
-- JNB			endere�o	if B=0 PC<-endere�o 				nenhum
-- SHR			nenhum		C<-AC(0);AC(i-1)<-AC(i);AC(7)<-0	N,Z,C
-- SHL			nenhum		C<-AC(7);AC(i)<-AC(i-1);AC(0)<-0	N,Z,C
-- ROR			nenhum		C<-AC(0);AC(i-1)<-AC(i);AC(7)<-C	N,Z,C
-- ROL			nenhum		C<-AC(7);AC(i)<-AC(i-1);AC(0)<-C	N,Z,C
-- HLT			nenhum		interrompe o processamento			nenhum


LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY ahmes IS
	PORT
	(
		-- Barramento de endere�os (8 bits)
		-- Address bus (8 bits)
		address_bus	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- Barramentos de dados unidirecionais (DATA_IN e DATA_OUT) de 8 bits
		-- Unidirectional Data buses (DATA_IN and DATA_OUT) (8 bits)
		data_in		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_out	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		mem_write	: OUT std_logic;	-- Sinal de escrita na mem�ria (memory write signal)
		clk			: IN std_logic;		-- Clock principal (main clock)
		reset		: IN std_logic;		-- Reset da CPU (CPU reset)
		ERROR		: OUT STD_LOGIC;	-- Error (opcode ilegal) (illegal opcode error)
		-- Barramentos de dados para interface com a ULA
		-- ALU interfacing data buses
		OPERACAO 	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Sele��o da opera��o da ULA (ULA's operation select)
		OPER_A		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		-- operando A (operand A)
		OPER_B		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		-- operando B (operand B)
		RESULT		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);		-- resultado (result)
		Cout		: OUT STD_LOGIC;						-- Sa�da de Carry (Carry out)
		N,Z,C,B,V 	: IN STD_LOGIC							-- flags da ALU (ALU's flags)
	);
END ahmes;

ARCHITECTURE cpu OF ahmes IS
-- Constantes com as instru��es do processador
-- Processor's instruction-constants
constant NOP : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
constant STA : STD_LOGIC_VECTOR(7 DOWNTO 0):="00010000";
constant LDA : STD_LOGIC_VECTOR(7 DOWNTO 0):="00100000";
constant ADD : STD_LOGIC_VECTOR(7 DOWNTO 0):="00110000";
constant IOR : STD_LOGIC_VECTOR(7 DOWNTO 0):="01000000";
constant IAND: STD_LOGIC_VECTOR(7 DOWNTO 0):="01010000";
constant INOT: STD_LOGIC_VECTOR(7 DOWNTO 0):="01100000";
constant SUB : STD_LOGIC_VECTOR(7 DOWNTO 0):="01110000";
constant JMP : STD_LOGIC_VECTOR(7 DOWNTO 0):="10000000";
constant JN  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10010000";
constant JP  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10010100";
constant JV  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10011000";
constant JNV : STD_LOGIC_VECTOR(7 DOWNTO 0):="10011100";
constant JZ  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10100000";
constant JNZ : STD_LOGIC_VECTOR(7 DOWNTO 0):="10100100";
constant JC  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10110000";
constant JNC : STD_LOGIC_VECTOR(7 DOWNTO 0):="10110100";
constant JB  : STD_LOGIC_VECTOR(7 DOWNTO 0):="10111000";
constant JNB : STD_LOGIC_VECTOR(7 DOWNTO 0):="10111100";
constant SHR : STD_LOGIC_VECTOR(7 DOWNTO 0):="11100000";
constant SHL : STD_LOGIC_VECTOR(7 DOWNTO 0):="11100001";
constant IROR: STD_LOGIC_VECTOR(7 DOWNTO 0):="11100010";
constant IROL: STD_LOGIC_VECTOR(7 DOWNTO 0):="11100011";
constant HLT : STD_LOGIC_VECTOR(7 DOWNTO 0):="11110000";

-- Constantes que definem as opera��es da ULA
-- ALU operation's constants
constant ULA_ADD : STD_LOGIC_VECTOR(3 DOWNTO 0):="0001";
constant ULA_SUB : STD_LOGIC_VECTOR(3 DOWNTO 0):="0010";
constant ULA_OU  : STD_LOGIC_VECTOR(3 DOWNTO 0):="0011";
constant ULA_E   : STD_LOGIC_VECTOR(3 DOWNTO 0):="0100";
constant ULA_NAO : STD_LOGIC_VECTOR(3 DOWNTO 0):="0101";
constant ULA_DLE : STD_LOGIC_VECTOR(3 DOWNTO 0):="0110";
constant ULA_DLD : STD_LOGIC_VECTOR(3 DOWNTO 0):="0111";
constant ULA_DAE : STD_LOGIC_VECTOR(3 DOWNTO 0):="1000";
constant ULA_DAD : STD_LOGIC_VECTOR(3 DOWNTO 0):="1001";

BEGIN
	-- sensibilidade nas bordas do sinal de clock e reset
	-- sensibility on clk and reset edges
	process (clk,reset)
	variable PC : STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Contador de programa (program counter)
	variable AC : STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Acumulador (accumulator)
	VARIABLE TEMP: STD_LOGIC_VECTOR(7 DOWNTO 0);	-- registrador tempor�rio (temporary register)
	VARIABLE INSTR: STD_LOGIC_VECTOR(7 DOWNTO 0);	-- instru��o atual (current instruction)
	-- M�quina de estados da CPU (CPU state machine)
	type Tcpu_state is (
		BUSCA, BUSCA1, DECOD,  -- estados b�sicos de busca e decodifica��o (basic fetch and decode states)
		DECOD_STA1, DECOD_STA2, DECOD_STA3, DECOD_STA4,		-- decodifica��o da instru��o STA (STA decode)
		DECOD_LDA1, DECOD_LDA2, DECOD_LDA3,					-- decodifica��o da instru��o LDA (LDA decode)
		DECOD_ADD1, DECOD_ADD2, DECOD_ADD3,					-- decodifica��o da instru��o ADD (ADD decode)
		DECOD_SUB1, DECOD_SUB2, DECOD_SUB3, 				-- decodifica��o da instru��o SUB (SUB decode)
		DECOD_IOR1, DECOD_IOR2, DECOD_IOR3, 				-- decodifica��o da instru��o OR (OR decode)
		DECOD_IAND1, DECOD_IAND2, DECOD_IAND3, 				-- decodifica��o da instru��o AND (AND decode)
		DECOD_JMP,											-- decodifica��o da instru��o JMP (JMP decode)
		DECOD_SHR1,  										-- decodifica��o da instru��o SHR (SHR decode)
		DECOD_SHL1,  										-- decodifica��o da instru��o SHL (SHL decode)
		DECOD_IROR1, 										-- decodifica��o da instru��o IROR (IROR decode)
		DECOD_IROL1, 										-- decodifica��o da instru��o IROL (IROL decode)
		DECOD_STORE						
		);
	VARIABLE CPU_STATE : TCPU_STATE;  -- vari�vel de estado da CPU (CPU state variable)
	variable divider : integer range 0 to 65535;
	begin
		if (reset='1') then
			-- Opera��es em caso de reset (reset operations)
			CPU_STATE := BUSCA;	-- configura a m�quina de estados para BUSCA (set CPU state machine to fetch)
			PC := "00000000";	-- Inicializa o PC em zero (set PC to zero)
			MEM_WRITE <= '0';	-- desativa a linha de escrita na mem�ria (disable memory write signal)
			ADDRESS_BUS <= "00000000";	-- coloca zero no barramento de endere�os (set the address bus to zero)
			DATA_OUT <= "00000000";		-- coloca zero no barramento de dados (set the DATA_OUT bus to zero)
			OPERACAO <= "0000";			-- nenhuma opera��o na ULA (no operation on ALU)
			divider := 0;
		ELSIF ((clk'event and clk='1')) THEN	-- se for uma borda de subida do clock (if it's a clock rising edge)
			--divider := divider + 1;
			--if (divider=5000) then
			--divider := 0;
			CASE CPU_STATE IS	-- verifica o estado atual da m�quina de estados (select the current state of the CPU's state machine)
				WHEN BUSCA =>	-- primeiro ciclo da busca de instru��o (first fetch cycle)
					ADDRESS_BUS <= PC;		-- carrega o barramento de endere�os com o PC (load address bus with the PC content)
					ERROR <= '0';			-- for�a a sa�da de erros para zero (disable the error output)
					CPU_STATE := BUSCA1;	-- avan�a para o estado BUSCA1 (next state = BUSCA1)
				WHEN BUSCA1 =>	-- segundo ciclo da busca de instru��o (second fetch cycle)
					INSTR := DATA_IN;		-- l� a instru��o e armazena em INSTR (read the instruction and store into INSTR)
					CPU_STATE := DECOD;		-- avan�a para o pr�ximo est�gio (next state = DECOD)
				WHEN DECOD =>	-- in�cio da decodifica��o de instru��o (now we will start decoding the instruction)
					CASE INSTR IS			-- decod the INSTR content
						-- NOP - n�o faz nada, apenas avan�a o PC
						-- NOP - no operation, only increment PC
						WHEN NOP =>						
							PC := PC + 1;				-- soma 1 ao PC	(add 1 to PC)
							CPU_STATE := BUSCA;			-- retorna a m�quina de estados ao in�cio (restart instruction fetch)
						-- STA - armazena o AC no endere�o especificado pelo operando
						-- STA - store the AC into the specified memory
						WHEN STA =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_STA1;	-- segue para a decodifica��o da STA (proceed on STA decoding)
						-- LDA - carrega o acumulador com o conte�do do endere�o especificado pelo operando
						-- LDA - load AC with the contents of the specified memory address
						WHEN LDA =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_LDA1;	-- segue para a decodifica��o da LDA (proceed on LDA decoding)
						-- ADD - soma o acumulador com o conte�do do endere�o especificado pelo operando
						-- ADD - add the contents of the specified memory address to the accumulator (AC)
						WHEN ADD =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_ADD1;	-- segue para a decodifica��o da ADD (proceed on ADD decoding)
						-- SUB - subtrai o conte�do do endere�o especificado do conte�do do acumulador
						-- SUB - subtract the contents of the specified address from the current content of the accumulator
						WHEN SUB =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_SUB1;	-- avan�a para a decodifica��o da SUB (proceed on SUB decoding)
						-- OR - opera��o l�gica OU entre o acumulador e o conte�do do endere�o especificado pelo operando
						-- OR - logic OR operation between the accumulator and the content of the specified address
						WHEN IOR =>						
							ADDRESS_BUS <= PC + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_IOR1;	-- avan�a para a decodifica��o da OR (proceed on OR decoding)
						-- AND - opera��o l�gica E entre o acumulador e o conte�do do endere�o especificado pelo operando 
						-- AND - logic AND operation between the accumulator and the content of the specified address
						WHEN IAND =>				
							ADDRESS_BUS <= PC + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							CPU_STATE := DECOD_IAND1;	-- avan�a para a decodifica��o da AND (proceed on AND decoding)
						-- NOT - opera��o l�gica N�O do acumulador
						-- NOT - logic NOT operation of the accumulator
						WHEN INOT =>					
							OPER_A <= AC;				-- carrega o acumulador no OPER_A da ULA (load ALU's input OPER_A with the accumulator)
							OPERACAO <= ULA_NAO;		-- seleciona a opera��o N�O na ULA (selects the ALU's NOT operation)
							PC := PC + 1;				-- incrementa o PC (increments PC)
							CPU_STATE := DECOD_STORE;	-- avan�a para a decodifica��o da NOT (proceed on NOT decoding)
						-- JMP - desvia para o endere�o indicado ap�s a instru��o	
						-- JMP - jumps to the specified address
						WHEN JMP =>						
							ADDRESS_BUS <= PC + 1;		-- aponta para o operando da instru��o (fetch the operand)
							CPU_STATE := DECOD_JMP;		-- avan�a para a decodifica��o de JMP (proceed on JMP decoding)
						-- JN - desvia para o endere�o se N=1
						-- JN - jump to the address if N = 1
						WHEN JN =>						
							IF (N='1') THEN
								-- se N=1 (if N=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as with JMP)									
							ELSE
								-- se N=0 (if N=0)
								PC := PC + 2;			-- avan�a o PC (add two to the PC so it points the next instruction) 
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						-- JP - desvia para o endere�o se N=0
						-- JP - jump to the address if N=0
						WHEN JP =>						
							IF (N='0') THEN
								-- se N=0 (if N=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as with JMP)
							ELSE
								-- se N=1 (if N=1)
								PC := PC + 2;			-- avan�a o PC (add two to the PC so it points the next instruction) 
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						-- JV - desvia para o endere�o se V=1
						-- JV - jump to the address if V=1
						WHEN JV =>						
							IF (V='1') THEN
								-- se V=1 (if V=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se V=0 (if V=0)
								PC := PC + 2;			-- avan�a o PC (add two to the PC so it points the next instruction) 
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						-- JNV - desvia para o endere�o se V=0
						-- JNV - jump to the address if V=0
						WHEN JNV =>						
							IF (V='0') THEN
								-- se V=0 (if V=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se V=1 (if V=1)
								PC := PC + 2;			-- avan�a o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JZ =>						-- desvia para o endere�o se Z=1 (jump if zero)
							IF (Z='1') THEN
								-- se Z=1 (if Z=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se Z=0 (if Z=0)
								PC := PC + 2;			-- avan�a o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JNZ =>						-- desvia para o endere�o se Z=0 (jump if not zero)
							IF (Z='0') THEN
								-- se Z=0 (if Z=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se Z=1 (if Z=1)
								PC := PC + 2;			-- avan�a o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JC =>						-- desvia para o endere�o se C=1 (jump if carry)
							IF (C='1') THEN
								-- se C=1 (if C=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se C=0
								PC := PC + 2;			-- avan�a o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JNC =>						-- desvia para o endere�o se C=0 (jump if not carry)
							IF (C='0') THEN
								-- se C=0 (if C=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se C=1 (if C=1)
								PC := PC + 2;			-- avan�a o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JB =>						-- desvia para o endere�o se B=1 (jump if borrow)
							IF (B='1') THEN
								-- se B=1 (if B=1)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se B=0 (if B=0)
								PC := PC + 2;			-- avan�a o PC (Add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN JNB =>						-- desvia para o endere�o se B=0 (jump if not borrow)
							IF (B='0') THEN
								-- se B=0 (if B=0)
								ADDRESS_BUS <= PC + 1;	-- aponta para o operando da instru��o (fetch the operand)
								CPU_STATE := DECOD_JMP;	-- prossegue como um JMP (proceed as a JMP)
							ELSE
								-- se B=1 (if B=1)
								PC := PC + 2;			-- avan�a o PC (add 2 to the PC)
								CPU_STATE := BUSCA;		-- retorna ao estado de busca (restart instruction fetch)
							END IF;
						WHEN SHR =>						-- SHR - deslocamento para a direita (shift right)
							CPU_STATE := DECOD_SHR1;	-- avan�a para a decodifica��o da SHR (proceed with SHR decoding)
						WHEN SHL =>						-- SHL - deslocamento para a esquerda (shift left)
							CPU_STATE := DECOD_SHL1;	-- avan�a para a decodifica��o da SHL (proceed with SHL decoding)
						WHEN IROR =>					-- IROR - rota��o para a direita (immediate rotate to right)
							Cout <= C;
							CPU_STATE := DECOD_IROR1;	-- avan�a para a decodifica��o da IROR (proceed with IROR decoding)
						WHEN IROL =>					-- IROL - rota��o para a esquerda (immediate rotate to left)
							Cout <= C;
							CPU_STATE := DECOD_IROL1;	-- avan�a para a decodifica��o da IROL (proceed with IROL decoding)
						WHEN HLT =>						-- HLT - p�ra o processamento e aguarda um reset (halts processing)
						WHEN OTHERS =>					-- opcode desconhecido (unkown opcode)
							PC := PC + 1;				-- avan�a o PC (add 1 to the PC)
							ERROR <= '1';				-- coloca ERRO em 1 (sets error output)
							CPU_STATE := BUSCA;			-- retorna ao estado de busca (restart instruction fetch)
					END CASE;
				WHEN DECOD_STA1 =>				-- decodifica��o da instru��o STA (STA decoding)
					TEMP := DATA_IN;			-- l� o operando (reads the operand)
					CPU_STATE := DECOD_STA2;	
				WHEN DECOD_STA2 =>				
					ADDRESS_BUS <= TEMP;
					DATA_OUT <= AC;				-- coloca o acumulador na sa�da de dados (put the accumulator on the data_out bus)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := DECOD_STA3;
				WHEN DECOD_STA3 =>
					MEM_WRITE <= '1';			-- ativa a escrita na mem�ria (write to the memory)
					PC := PC + 1;				-- incrementa o PC (agora ele aponta para a pr�xima instru��o) (add 1 to the PC)
					CPU_STATE := DECOD_STA4;
				WHEN DECOD_STA4 =>
					MEM_WRITE <= '0';			-- desativa a escrita na mem�ria (disable memory write signal)
					CPU_STATE := BUSCA;			-- termina a decodifica��o da instru��o STA (restart instruction fetch)
				WHEN DECOD_LDA1 =>				-- decodifica��o da instru��o LDA (LDA decoding)
					TEMP := DATA_IN;			-- carrega o operando (endere�o) (loads operand address)
					CPU_STATE := DECOD_LDA2;
				WHEN DECOD_LDA2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endere�o do operando no barramento de endere�os (load the operand onto the address bus)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := DECOD_LDA3;
				WHEN DECOD_LDA3 =>
					AC := DATA_IN;				-- carrega o acumulador com o dado apontado pelo barramento de endere�os (load the accumulator with the data read)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := BUSCA;			-- termina a decodifica��o da instru��o LDA (restart instruction fetch)
				WHEN DECOD_ADD1 =>				-- decodifica��o da instru��o ADD (ADD decoding)
					TEMP := DATA_IN;			-- carrega o operando (endere�o) (load the operand address)
					CPU_STATE := DECOD_ADD2;
				WHEN DECOD_ADD2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					CPU_STATE := DECOD_ADD3;
				WHEN DECOD_ADD3 =>
					OPER_A <= DATA_IN;			-- coloca o dado na entrada OPER_A da ULA (load ULA's OPER_A input with the data read from memory)
					OPER_B <= AC;				-- carrega a entrada OPER_B da ULA com o acumulador (load ULA's OPER_B input with the data from the accumulator)
					OPERACAO <= ULA_ADD;		-- especifica a opera��o ADD na ULA (select ULA's ADD operation)
					PC := PC + 1;				-- incrementa o PC (add 1 to the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_SUB1 =>				-- decodifica��o da instru��o SUB (SUB decoding)
					TEMP := DATA_IN;			-- carrega o operando (endere�o) (load the operand address)
					CPU_STATE := DECOD_SUB2;
				WHEN DECOD_SUB2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					CPU_STATE := DECOD_SUB3;
				WHEN DECOD_SUB3 =>
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from accumulator)
					OPER_B <= DATA_IN;			-- carrega a entrada OPER_B da ULA (load ULA's OPER_B input from data input bus)
					OPERACAO <= ULA_SUB;		-- seleciona a opera��o SUB na ULA (select ULA's SUB operation)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IOR1 =>				-- decodifica��o da instru��o OR (OR decoding)
					TEMP := DATA_IN;			-- carrega o operando (endere�o) (load the operand address)
					CPU_STATE := DECOD_IOR2;
				WHEN DECOD_IOR2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					CPU_STATE := DECOD_IOR3;
				WHEN DECOD_IOR3 =>
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPER_B <= DATA_IN;			-- carrega a entrada OPER_B da ULA com o dado (load ULA's OPER_B input from the data bus)
					OPERACAO <= ULA_OU;			-- seleciona a opera��o OU na ULA (select ULA's OR operation)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IAND1 =>				-- decodifica��o da instru��o AND (AND decoding)
					TEMP := DATA_IN;			-- carrega o operando (endere�o) (load the operand address)
					CPU_STATE := DECOD_IAND2;
				WHEN DECOD_IAND2 =>
					ADDRESS_BUS <= TEMP;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					CPU_STATE := DECOD_IAND3;
				WHEN DECOD_IAND3 =>
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPER_B <= DATA_IN;			-- carrega a entrada OPER_B da ULA com o dado (load ULA's OPER_B input from the data bus)
					OPERACAO <= ULA_E;			-- seleciona a opera��o E na ULA (select ULA's AND operation)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_JMP =>				-- decodifica��o da instru��o JMP (JMP decoding)
					PC := DATA_IN;				-- carrega o dado lido (operando) no PC (load PC with the operand data)
					CPU_STATE := BUSCA;			-- termina a decodifica��o da instru��o JMP (restart instruction decoding)
				WHEN DECOD_SHR1 =>				-- decodifica��o da instru��o SHR (SHR decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPERACAO <= ULA_DAD;		-- seleciona a opera��o de deslocamento aritm�tico � direita (select ULA's SHR operation)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_SHL1 =>				-- decodifica��o da instru��o SHL (SHL decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A input from the accumulator)
					OPERACAO <= ULA_DAD;		-- seleciona a opera��o de deslocamento aritm�tico � esquerda (select ULA's SHL)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IROR1 =>				-- decodifica��o da instru��o ROR (ROR decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A from the accumulator)
					OPERACAO <= ULA_DLD;		-- seleciona a opera��o de deslocamento l�gico � direita (select ULA's ROR)
					CPU_STATE := DECOD_STORE;
				WHEN DECOD_IROL1 =>				-- decodifica��o da instru��o ROL (ROL decoding)
					OPER_A <= AC;				-- carrega a entrada OPER_A da ULA com o acumulador (load ULA's OPER_A from the accumulator)
					OPERACAO <= ULA_DLE;		-- seleciona a opera��o de deslocamento l�gico � esquerda (select ULA's ROL)
					CPU_STATE := DECOD_STORE;					
				WHEN DECOD_STORE =>
					AC := RESULT;				-- carrega o resultado da ULA no acumulador (load the accumulator from the result)
					PC := PC + 1;				-- incrementa o PC (increments the PC)
					CPU_STATE := BUSCA;			-- termina a decodifica��o da instru��o (restart instruction decoding)
			END CASE;
			--end if;
		END IF;
	end process;
END CPU;
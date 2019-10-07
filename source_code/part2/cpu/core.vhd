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


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity ahmes is
	port
	(
		-- barramento de endere�os (8 bits)
		-- address bus (8 bits)
		address_bus	: out std_logic_vector(7 downto 0);
		-- barramentos de dados unidirecionais (data_in e data_out) de 8 bits
		-- unidirectional data buses (data_in and data_out) (8 bits)
		data_in		: in std_logic_vector(7 downto 0);
		data_out	: out std_logic_vector(7 downto 0);
		mem_write	: out std_logic;	-- sinal de escrita na mem�ria (memory write signal)
		clk			: in std_logic;		-- clock principal (main clock)
		reset		: in std_logic;		-- reset da cpu (cpu reset)
		error		: out std_logic;	-- error (opcode ilegal) (illegal opcode error)
		-- barramentos de dados para interface com a ula
		-- alu interfacing data buses
		operacao 	: out std_logic_vector (3 downto 0);	-- sele��o da opera��o da ula (ula's operation select)
		oper_a		: out std_logic_vector(7 downto 0);		-- operando a (operand a)
		oper_b		: out std_logic_vector(7 downto 0);		-- operando b (operand b)
		result		: in std_logic_vector(7 downto 0);		-- resultado (result)
		cout		: out std_logic;						-- sa�da de carry (carry out)
		n,z,c,b,v 	: in std_logic							-- flags da alu (alu's flags)
	);
end ahmes;

architecture cpu of ahmes is
-- constantes com as instru��es do processador
-- processor's instruction-constants
constant nop : std_logic_vector(7 downto 0):="00000000";
constant sta : std_logic_vector(7 downto 0):="00010000";
constant lda : std_logic_vector(7 downto 0):="00100000";
constant add : std_logic_vector(7 downto 0):="00110000";
constant ior : std_logic_vector(7 downto 0):="01000000";
constant iand: std_logic_vector(7 downto 0):="01010000";
constant inot: std_logic_vector(7 downto 0):="01100000";
constant sub : std_logic_vector(7 downto 0):="01110000";
constant jmp : std_logic_vector(7 downto 0):="10000000";
constant jn  : std_logic_vector(7 downto 0):="10010000";
constant jp  : std_logic_vector(7 downto 0):="10010100";
constant jv  : std_logic_vector(7 downto 0):="10011000";
constant jnv : std_logic_vector(7 downto 0):="10011100";
constant jz  : std_logic_vector(7 downto 0):="10100000";
constant jnz : std_logic_vector(7 downto 0):="10100100";
constant jc  : std_logic_vector(7 downto 0):="10110000";
constant jnc : std_logic_vector(7 downto 0):="10110100";
constant jb  : std_logic_vector(7 downto 0):="10111000";
constant jnb : std_logic_vector(7 downto 0):="10111100";
constant shr : std_logic_vector(7 downto 0):="11100000";
constant shl : std_logic_vector(7 downto 0):="11100001";
constant iror: std_logic_vector(7 downto 0):="11100010";
constant irol: std_logic_vector(7 downto 0):="11100011";
constant hlt : std_logic_vector(7 downto 0):="11110000";

-- constantes que definem as opera��es da ula
-- alu operation's constants
constant ula_add : std_logic_vector(3 downto 0):="0001";
constant ula_sub : std_logic_vector(3 downto 0):="0010";
constant ula_ou  : std_logic_vector(3 downto 0):="0011";
constant ula_e   : std_logic_vector(3 downto 0):="0100";
constant ula_nao : std_logic_vector(3 downto 0):="0101";
constant ula_dle : std_logic_vector(3 downto 0):="0110";
constant ula_dld : std_logic_vector(3 downto 0):="0111";
constant ula_dae : std_logic_vector(3 downto 0):="1000";
constant ula_dad : std_logic_vector(3 downto 0):="1001";

begin
	-- sensibilidade nas bordas do sinal de clock e reset
	-- sensibility on clk and reset edges
	process (clk,reset)
	variable pc : std_logic_vector(7 downto 0);	-- contador de programa (program counter)
	variable ac : std_logic_vector(7 downto 0);	-- acumulador (accumulator)
	variable temp: std_logic_vector(7 downto 0);	-- registrador tempor�rio (temporary register)
	variable instr: std_logic_vector(7 downto 0);	-- instru��o atual (current instruction)
	-- m�quina de estados da cpu (cpu state machine)
	type tcpu_state is (
		busca, busca1, decod,  -- estados b�sicos de busca e decodifica��o (basic fetch and decode states)
		decod_sta1, decod_sta2, decod_sta3, decod_sta4,		-- decodifica��o da instru��o sta (sta decode)
		decod_lda1, decod_lda2, decod_lda3,					-- decodifica��o da instru��o lda (lda decode)
		decod_add1, decod_add2, decod_add3,					-- decodifica��o da instru��o add (add decode)
		decod_sub1, decod_sub2, decod_sub3, 				-- decodifica��o da instru��o sub (sub decode)
		decod_ior1, decod_ior2, decod_ior3, 				-- decodifica��o da instru��o or (or decode)
		decod_iand1, decod_iand2, decod_iand3, 				-- decodifica��o da instru��o and (and decode)
		decod_jmp,											-- decodifica��o da instru��o jmp (jmp decode)
		decod_shr1,  										-- decodifica��o da instru��o shr (shr decode)
		decod_shl1,  										-- decodifica��o da instru��o shl (shl decode)
		decod_iror1, 										-- decodifica��o da instru��o iror (iror decode)
		decod_irol1, 										-- decodifica��o da instru��o irol (irol decode)
		decod_store						
		);
	variable cpu_state : tcpu_state;  -- vari�vel de estado da cpu (cpu state variable)
	begin
		if (reset='1') then
			-- opera��es em caso de reset (reset operations)
			cpu_state := busca;	-- configura a m�quina de estados para busca (set cpu state machine to fetch)
			pc := "00000000";	-- inicializa o pc em zero (set pc to zero)
			mem_write <= '0';	-- desativa a linha de escrita na mem�ria (disable memory write signal)
			address_bus <= "00000000";	-- coloca zero no barramento de endere�os (set the address bus to zero)
			data_out <= "00000000";		-- coloca zero no barramento de dados (set the data_out bus to zero)
			operacao <= "0000";			-- nenhuma opera��o na ula (no operation on alu)
		elsif ((clk'event and clk='1')) then	-- se for uma borda de subida do clock (if it's a clock rising edge)
			case cpu_state is	-- verifica o estado atual da m�quina de estados (select the current state of the cpu's state machine)
				when busca =>	-- primeiro ciclo da busca de instru��o (first fetch cycle)
					address_bus <= pc;		-- carrega o barramento de endere�os com o pc (load address bus with the pc content)
					error <= '0';			-- for�a a sa�da de erros para zero (disable the error output)
					cpu_state := busca1;	-- avan�a para o estado busca1 (next state = busca1)
				when busca1 =>	-- segundo ciclo da busca de instru��o (second fetch cycle)
					instr := data_in;		-- l� a instru��o e armazena em instr (read the instruction and store into instr)
					cpu_state := decod;		-- avan�a para o pr�ximo est�gio (next state = decod)
				when decod =>	-- in�cio da decodifica��o de instru��o (now we will start decoding the instruction)
					case instr is			-- decod the instr content
						-- nop - n�o faz nada, apenas avan�a o pc
						-- nop - no operation, only increment pc
						when nop =>						
							pc := pc + 1;				-- soma 1 ao pc	(add 1 to pc)
							cpu_state := busca;			-- retorna a m�quina de estados ao in�cio (restart instruction fetch)
						-- sta - armazena o ac no endere�o especificado pelo operando
						-- sta - store the ac into the specified memory
						when sta =>						
							address_bus <= pc + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							cpu_state := decod_sta1;	-- segue para a decodifica��o da sta (proceed on sta decoding)
						-- lda - carrega o acumulador com o conte�do do endere�o especificado pelo operando
						-- lda - load ac with the contents of the specified memory address
						when lda =>						
							address_bus <= pc + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							cpu_state := decod_lda1;	-- segue para a decodifica��o da lda (proceed on lda decoding)
						-- add - soma o acumulador com o conte�do do endere�o especificado pelo operando
						-- add - add the contents of the specified memory address to the accumulator (ac)
						when add =>						
							address_bus <= pc + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							cpu_state := decod_add1;	-- segue para a decodifica��o da add (proceed on add decoding)
						-- sub - subtrai o conte�do do endere�o especificado do conte�do do acumulador
						-- sub - subtract the contents of the specified address from the current content of the accumulator
						when sub =>						
							address_bus <= pc + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							cpu_state := decod_sub1;	-- avan�a para a decodifica��o da sub (proceed on sub decoding)
						-- or - opera��o l�gica ou entre o acumulador e o conte�do do endere�o especificado pelo operando
						-- or - logic or operation between the accumulator and the content of the specified address
						when ior =>						
							address_bus <= pc + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							cpu_state := decod_ior1;	-- avan�a para a decodifica��o da or (proceed on or decoding)
						-- and - opera��o l�gica e entre o acumulador e o conte�do do endere�o especificado pelo operando 
						-- and - logic and operation between the accumulator and the content of the specified address
						when iand =>				
							address_bus <= pc + 1;		-- incrementa o endere�o (para apontar para o operando) (fetch the operand)
							cpu_state := decod_iand1;	-- avan�a para a decodifica��o da and (proceed on and decoding)
						-- not - opera��o l�gica n�o do acumulador
						-- not - logic not operation of the accumulator
						when inot =>					
							oper_a <= ac;				-- carrega o acumulador no oper_a da ula (load alu's input oper_a with the accumulator)
							operacao <= ula_nao;		-- seleciona a opera��o n�o na ula (selects the alu's not operation)
							pc := pc + 1;				-- incrementa o pc (increments pc)
							cpu_state := decod_store;	-- avan�a para a decodifica��o da not (proceed on not decoding)
						-- jmp - desvia para o endere�o indicado ap�s a instru��o	
						-- jmp - jumps to the specified address
						when jmp =>						
							address_bus <= pc + 1;		-- aponta para o operando da instru��o (fetch the operand)
							cpu_state := decod_jmp;		-- avan�a para a decodifica��o de jmp (proceed on jmp decoding)
						-- jn - desvia para o endere�o se n=1
						-- jn - jump to the address if n = 1
						when jn =>						
							if (n='1') then
								-- se n=1 (if n=1)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as with jmp)									
							else
								-- se n=0 (if n=0)
								pc := pc + 2;			-- avan�a o pc (add two to the pc so it points the next instruction) 
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						-- jp - desvia para o endere�o se n=0
						-- jp - jump to the address if n=0
						when jp =>						
							if (n='0') then
								-- se n=0 (if n=0)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as with jmp)
							else
								-- se n=1 (if n=1)
								pc := pc + 2;			-- avan�a o pc (add two to the pc so it points the next instruction) 
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						-- jv - desvia para o endere�o se v=1
						-- jv - jump to the address if v=1
						when jv =>						
							if (v='1') then
								-- se v=1 (if v=1)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se v=0 (if v=0)
								pc := pc + 2;			-- avan�a o pc (add two to the pc so it points the next instruction) 
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						-- jnv - desvia para o endere�o se v=0
						-- jnv - jump to the address if v=0
						when jnv =>						
							if (v='0') then
								-- se v=0 (if v=0)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se v=1 (if v=1)
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when jz =>						-- desvia para o endere�o se z=1 (jump if zero)
							if (z='1') then
								-- se z=1 (if z=1)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se z=0 (if z=0)
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when jnz =>						-- desvia para o endere�o se z=0 (jump if not zero)
							if (z='0') then
								-- se z=0 (if z=0)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se z=1 (if z=1)
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when jc =>						-- desvia para o endere�o se c=1 (jump if carry)
							if (c='1') then
								-- se c=1 (if c=1)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se c=0
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when jnc =>						-- desvia para o endere�o se c=0 (jump if not carry)
							if (c='0') then
								-- se c=0 (if c=0)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se c=1 (if c=1)
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when jb =>						-- desvia para o endere�o se b=1 (jump if borrow)
							if (b='1') then
								-- se b=1 (if b=1)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se b=0 (if b=0)
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when jnb =>						-- desvia para o endere�o se b=0 (jump if not borrow)
							if (b='0') then
								-- se b=0 (if b=0)
								address_bus <= pc + 1;	-- aponta para o operando da instru��o (fetch the operand)
								cpu_state := decod_jmp;	-- prossegue como um jmp (proceed as a jmp)
							else
								-- se b=1 (if b=1)
								pc := pc + 2;			-- avan�a o pc (add 2 to the pc)
								cpu_state := busca;		-- retorna ao estado de busca (restart instruction fetch)
							end if;
						when shr =>						-- shr - deslocamento para a direita (shift right)
							cpu_state := decod_shr1;	-- avan�a para a decodifica��o da shr (proceed with shr decoding)
						when shl =>						-- shl - deslocamento para a esquerda (shift left)
							cpu_state := decod_shl1;	-- avan�a para a decodifica��o da shl (proceed with shl decoding)
						when iror =>					-- iror - rota��o para a direita (immediate rotate to right)
							cout <= c;
							cpu_state := decod_iror1;	-- avan�a para a decodifica��o da iror (proceed with iror decoding)
						when irol =>					-- irol - rota��o para a esquerda (immediate rotate to left)
							cout <= c;
							cpu_state := decod_irol1;	-- avan�a para a decodifica��o da irol (proceed with irol decoding)
						when hlt =>						-- hlt - p�ra o processamento e aguarda um reset (halts processing)
						when others =>					-- opcode desconhecido (unkown opcode)
							pc := pc + 1;				-- avan�a o pc (add 1 to the pc)
							error <= '1';				-- coloca erro em 1 (sets error output)
							cpu_state := busca;			-- retorna ao estado de busca (restart instruction fetch)
					end case;
				when decod_sta1 =>				-- decodifica��o da instru��o sta (sta decoding)
					temp := data_in;			-- l� o operando (reads the operand)
					cpu_state := decod_sta2;	
				when decod_sta2 =>				
					address_bus <= temp;
					data_out <= ac;				-- coloca o acumulador na sa�da de dados (put the accumulator on the data_out bus)
					pc := pc + 1;				-- incrementa o pc (add 1 to the pc)
					cpu_state := decod_sta3;
				when decod_sta3 =>
					mem_write <= '1';			-- ativa a escrita na mem�ria (write to the memory)
					pc := pc + 1;				-- incrementa o pc (agora ele aponta para a pr�xima instru��o) (add 1 to the pc)
					cpu_state := decod_sta4;
				when decod_sta4 =>
					mem_write <= '0';			-- desativa a escrita na mem�ria (disable memory write signal)
					cpu_state := busca;			-- termina a decodifica��o da instru��o sta (restart instruction fetch)
				when decod_lda1 =>				-- decodifica��o da instru��o lda (lda decoding)
					temp := data_in;			-- carrega o operando (endere�o) (loads operand address)
					cpu_state := decod_lda2;
				when decod_lda2 =>
					address_bus <= temp;		-- coloca o endere�o do operando no barramento de endere�os (load the operand onto the address bus)
					pc := pc + 1;				-- incrementa o pc (add 1 to the pc)
					cpu_state := decod_lda3;
				when decod_lda3 =>
					ac := data_in;				-- carrega o acumulador com o dado apontado pelo barramento de endere�os (load the accumulator with the data read)
					pc := pc + 1;				-- incrementa o pc (add 1 to the pc)
					cpu_state := busca;			-- termina a decodifica��o da instru��o lda (restart instruction fetch)
				when decod_add1 =>				-- decodifica��o da instru��o add (add decoding)
					temp := data_in;			-- carrega o operando (endere�o) (load the operand address)
					cpu_state := decod_add2;
				when decod_add2 =>
					address_bus <= temp;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					cpu_state := decod_add3;
				when decod_add3 =>
					oper_a <= data_in;			-- coloca o dado na entrada oper_a da ula (load ula's oper_a input with the data read from memory)
					oper_b <= ac;				-- carrega a entrada oper_b da ula com o acumulador (load ula's oper_b input with the data from the accumulator)
					operacao <= ula_add;		-- especifica a opera��o add na ula (select ula's add operation)
					pc := pc + 1;				-- incrementa o pc (add 1 to the pc)
					cpu_state := decod_store;
				when decod_sub1 =>				-- decodifica��o da instru��o sub (sub decoding)
					temp := data_in;			-- carrega o operando (endere�o) (load the operand address)
					cpu_state := decod_sub2;
				when decod_sub2 =>
					address_bus <= temp;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					cpu_state := decod_sub3;
				when decod_sub3 =>
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a input from accumulator)
					oper_b <= data_in;			-- carrega a entrada oper_b da ula (load ula's oper_b input from data input bus)
					operacao <= ula_sub;		-- seleciona a opera��o sub na ula (select ula's sub operation)
					pc := pc + 1;				-- incrementa o pc (increments the pc)
					cpu_state := decod_store;
				when decod_ior1 =>				-- decodifica��o da instru��o or (or decoding)
					temp := data_in;			-- carrega o operando (endere�o) (load the operand address)
					cpu_state := decod_ior2;
				when decod_ior2 =>
					address_bus <= temp;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					cpu_state := decod_ior3;
				when decod_ior3 =>
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a input from the accumulator)
					oper_b <= data_in;			-- carrega a entrada oper_b da ula com o dado (load ula's oper_b input from the data bus)
					operacao <= ula_ou;			-- seleciona a opera��o ou na ula (select ula's or operation)
					pc := pc + 1;				-- incrementa o pc (increments the pc)
					cpu_state := decod_store;
				when decod_iand1 =>				-- decodifica��o da instru��o and (and decoding)
					temp := data_in;			-- carrega o operando (endere�o) (load the operand address)
					cpu_state := decod_iand2;
				when decod_iand2 =>
					address_bus <= temp;		-- coloca o endere�o do operando no barramento de endere�os (load the address bus with the operand address)
					cpu_state := decod_iand3;
				when decod_iand3 =>
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a input from the accumulator)
					oper_b <= data_in;			-- carrega a entrada oper_b da ula com o dado (load ula's oper_b input from the data bus)
					operacao <= ula_e;			-- seleciona a opera��o e na ula (select ula's and operation)
					pc := pc + 1;				-- incrementa o pc (increments the pc)
					cpu_state := decod_store;
				when decod_jmp =>				-- decodifica��o da instru��o jmp (jmp decoding)
					pc := data_in;				-- carrega o dado lido (operando) no pc (load pc with the operand data)
					cpu_state := busca;			-- termina a decodifica��o da instru��o jmp (restart instruction decoding)
				when decod_shr1 =>				-- decodifica��o da instru��o shr (shr decoding)
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a input from the accumulator)
					operacao <= ula_dad;		-- seleciona a opera��o de deslocamento aritm�tico � direita (select ula's shr operation)
					cpu_state := decod_store;
				when decod_shl1 =>				-- decodifica��o da instru��o shl (shl decoding)
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a input from the accumulator)
					operacao <= ula_dad;		-- seleciona a opera��o de deslocamento aritm�tico � esquerda (select ula's shl)
					cpu_state := decod_store;
				when decod_iror1 =>				-- decodifica��o da instru��o ror (ror decoding)
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a from the accumulator)
					operacao <= ula_dld;		-- seleciona a opera��o de deslocamento l�gico � direita (select ula's ror)
					cpu_state := decod_store;
				when decod_irol1 =>				-- decodifica��o da instru��o rol (rol decoding)
					oper_a <= ac;				-- carrega a entrada oper_a da ula com o acumulador (load ula's oper_a from the accumulator)
					operacao <= ula_dle;		-- seleciona a opera��o de deslocamento l�gico � esquerda (select ula's rol)
					cpu_state := decod_store;					
				when decod_store =>
					ac := result;				-- carrega o resultado da ula no acumulador (load the accumulator from the result)
					pc := pc + 1;				-- incrementa o pc (increments the pc)
					cpu_state := busca;			-- termina a decodifica��o da instru��o (restart instruction decoding)
			end case;
		end if;
	end process;
end cpu;
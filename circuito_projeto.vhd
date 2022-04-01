LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY circuito_exp5 IS
	PORT (
		clock : in std_logic;
		reset : in std_logic;
		iniciar : in std_logic;
		botoes  : in  std_logic_vector(3 downto 0);          
		leds    : out std_logic_vector(3 downto 0);         
		pronto  : out std_logic;         
		ganhou  : out std_logic;         
		perdeu  : out std_logic;
		db_clock : out std_logic;
		db_tem_jogada : out std_logic;
		db_chavesIgualMemoria : out std_logic;
		db_enderecoIgualSequencia: out std_logic;
		db_fimS : out std_logic;
		db_contagem : out std_logic_vector (6 downto 0);
		db_memoria : out std_logic_vector (6 downto 0);
		db_estado : out std_logic_vector (6 downto 0);
		db_jogadafeita : out std_logic_vector (6 downto 0);
		db_sequencia : out std_logic_vector (6 downto 0)
	);
END ENTITY;

ARCHITECTURE arch_exp5 OF circuito_exp5 IS

	COMPONENT alfabeto7seg is
		port (
			letra : in  std_logic_vector(4 downto 0);
			sseg   : out std_logic_vector(6 downto 0)
		);
  	end COMPONENT;

	COMPONENT fluxo_dados IS
	port (
		clock : in std_logic;
		reset : in std_logic;
		reset_timer : in std_logic;
		enable_timer : in std_logic;
		reset_contagem : in std_logic;
		jogada:  in std_logic (24 downto 0);
		fim_tentativas : out std_logic;
		jogada_igual_senha : out std_logic;
		incrementa_contagem : in std_logic;
		incrementa_partida : in std_logic;
		clr_jogada : in std_logic;
		en_reg_jogada : in std_logic;
		tempo_jogada : out unsigned;
		timeout : out std_logic;
		db_tem_jogada : out std_logic;
		db_contagem : out std_logic_vector (2 downto 0);
		db_senha : out std_logic_vector (4 downto 0);
		db_jogada : out std_logic_vector (4 downto 0);
		db_partida : out std_logic_vector (2 downto 0)
  );
		);
	END COMPONENT;

	COMPONENT alfabeto7seg
		PORT (
			hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	component estado7seg is
		port (
				estado : in  std_logic_vector(4 downto 0);
				sseg   : out std_logic_vector(6 downto 0)
		);
	end component

	COMPONENT unidade_controle IS
		PORT (
			clock : in std_logic;
			reset : in std_logic;
			iniciar : in std_logic;
			fim_tentativas : in std_logic;
			tem_jogada : in std_logic;
			jogada_igual_senha : in std_logic;
			reset_timer : out std_logic;
			enable_timer : out std_logic;
			reset_contagem : out std_logic;
			ganhou : out std_logic;
			perdeu : out std_logic;
			pronto : out std_logic;
			atualiza_resultado : out std_logic;
			incrementa_contagem : out std_logic;
			incrementa_partida : out std_logic;
			clr_jogada : out std_logic;
			en_reg_jogada : out std_logic;
			db_estado : out std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	SIGNAL limpaM, igualS, igualJ, fimS, s_jogadafeita, s_temjogada, not_clock, fimE, zeraC, contaS, contaE, zeraR, zeraS, zeraE, registraR, contaTMR, zeraTMR, limpaR, fimTMR, escreveM, s_igualMemoria, s_igualSequencia, s_menorSequencia : STD_LOGIC;
	SIGNAL s_jogada, s_contagem, s_memoria, s_sequencia, s_estado : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN
	display_alfabeto: alfabeto7seg
    PORT MAP (
        letra => letra
        sseg  => sseg
    );

	

	not_clock <= NOT clock;
	db_chavesIgualMemoria <= s_igualMemoria;
	db_enderecoIgualSequencia <= s_igualSequencia;
	db_tem_jogada <= s_temjogada;
	db_clock <= clock;
	db_fimS <= fimS;
	leds <= s_memoria;

	fd: fluxo_dados
		PORT MAP(
			clock => not_clock,
			contaS => contaS,
			zeraS => zeraS,
			contaE => contaE,
			zeraE => zeraE,
			registraR => registraR,
			botoes => botoes,
			limpaR => limpaR,
			limpaM => limpaM,
			contaTMR => contaTMR,
			zeraTMR => zeraTMR,
			escreveM => escreveM,
			chavesIgualMemoria => s_igualMemoria,
			enderecoMenorOuIgualSequencia => s_menorSequencia,
			enderecoIgualSequencia => s_igualSequencia,
			fimS	=> fimS,
			fimE  	=> fimE,
			fimTMR 	=> fimTMR,
			jogada_feita => s_jogadafeita,
			db_tem_jogada => s_temjogada,
			db_contagem => s_contagem,
			db_memoria => s_memoria,
			db_jogada => s_jogada,
			db_sequencia => s_sequencia
		);
	uc: unidade_controle
		PORT MAP(
			clock => clock,
			reset => reset,
			iniciar => iniciar,
			fimE => fimE,
			fimS => fimS,
			fimTMR => fimTMR,
			igualJ => s_igualMemoria,
			igualS => s_igualSequencia,
			jogada => s_jogadafeita,
			contaE => contaE,
			contaS => contaS,
			contaTMR => contaTMR,
			ganhou => ganhou,
			limpaM => limpaM,
			limpaR => limpaR,
			perdeu => perdeu,
			pronto => pronto,
			registraM => escreveM,
			registraR => registraR,
			zeraE => zeraE,
			zeraS => zeraS,
			zeraTMR => zeraTMR,
			db_estado => s_estado
		);
END arch_exp5;

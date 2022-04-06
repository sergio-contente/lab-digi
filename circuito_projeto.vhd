LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY circuito_projeto IS
	PORT (
		clock        : IN std_logic;
		reset        : IN std_logic;
		iniciar      : IN std_logic;
		tem_jogada   : IN std_logic;
		jogada       : IN std_logic_vector(24 DOWNTO 0);
		leds_rgb     : OUT std_logic_vector(9 DOWNTO 0);
		db_estado    : OUT std_logic_vector(6 DOWNTO 0);
		db_contagem  : OUT std_logic_vector(6 DOWNTO 0);
		db_partida   : OUT std_logic_vector(6 DOWNTO 0);
		tempo_jogada : OUT std_logic_vector(26 DOWNTO 0);
		pronto       : OUT std_logic;
		ganhou       : OUT std_logic;
		perdeu       : OUT std_logic
	);
END ENTITY;

ARCHITECTURE arch OF circuito_projeto IS
	COMPONENT fluxo_dados IS
		PORT (
			clock               : IN std_logic;
			reset               : IN std_logic;
			reset_timer         : IN std_logic;
			enable_timer        : IN std_logic;
			reset_contagem      : IN std_logic;
			jogada              : IN std_logic_vector(24 DOWNTO 0);
			fim_tentativas      : OUT std_logic;
			jogada_igual_senha  : OUT std_logic;
			incrementa_contagem : IN std_logic;
			incrementa_partida  : IN std_logic;
			clr_jogada          : IN std_logic;
			en_reg_jogada       : IN std_logic;
			tempo_jogada        : OUT std_logic_vector(26 DOWNTO 0);
			db_contagem         : OUT std_logic_vector (2 DOWNTO 0);
			db_partida          : OUT std_logic_vector (3 DOWNTO 0);
			leds                : OUT std_logic_vector (9 DOWNTO 0)
		);
	END COMPONENT;

	-- COMPONENT hexa7seg
	-- PORT (
	-- hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	-- );
	-- END COMPONENT;

	COMPONENT unidade_controle IS
		PORT (
			clock               : IN std_logic;
			reset               : IN std_logic;
			iniciar             : IN std_logic;
			fim_tentativas      : IN std_logic;
			tem_jogada          : IN std_logic;
			jogada_igual_senha  : IN std_logic;
			reset_timer         : OUT std_logic;
			enable_timer        : OUT std_logic;
			reset_contagem      : OUT std_logic;
			ganhou              : OUT std_logic;
			perdeu              : OUT std_logic;
			pronto              : OUT std_logic;
			incrementa_contagem : OUT std_logic;
			incrementa_partida  : OUT std_logic;
			clr_jogada          : OUT std_logic;
			en_reg_jogada       : OUT std_logic;
			db_estado           : OUT std_logic_vector(3 DOWNTO 0)
		);
	END COMPONENT;

	component hexa7seg is
    port (
        hexa   : in  std_logic_vector(3 downto 0);
        sseg   : out std_logic_vector(6 downto 0)
    );
	end component;

	SIGNAL 
	  not_clock, fim_tentativas, jogada_igual_senha, reset_timer, enable_timer, reset_contagem, incrementa_contagem, incrementa_partida, clr_jogada, en_reg_jogada : STD_LOGIC;
	SIGNAL s_tempo_jogada: STD_LOGIC_VECTOR(26 downto 0);
	signal s_db_contagem : std_logic_vector(3 downto 0);
	signal s_db_partida, s_db_estado : std_logic_vector(3 downto 0);

BEGIN
	s_db_contagem(3) <= '0';

	display_contagem : hexa7seg
	port map(
        hexa => s_db_contagem,
        sseg => db_contagem
	);
	display_partida : hexa7seg
	port map(
        hexa => s_db_partida,
        sseg => db_partida
	);
	display_estado : hexa7seg
	port map(
        hexa => s_db_estado,
        sseg => db_estado
	);

	not_clock <= (NOT clock);

	fd : fluxo_dados
	PORT MAP(
		clock => not_clock,
		reset => reset,
		reset_timer => reset_timer,
		enable_timer => enable_timer,
		reset_contagem => reset_contagem,
		jogada => jogada,
		fim_tentativas => fim_tentativas,
		jogada_igual_senha => jogada_igual_senha,
		incrementa_contagem => incrementa_contagem,
		incrementa_partida => incrementa_partida,
		clr_jogada => clr_jogada,
		en_reg_jogada => en_reg_jogada,
		tempo_jogada => s_tempo_jogada,
		db_contagem => s_db_contagem(2 downto 0),
		db_partida => s_db_partida,
		leds => leds_rgb
	);

	uc : unidade_controle
	PORT MAP(
		clock => clock,
		reset => reset,
		iniciar => iniciar,
		fim_tentativas => fim_tentativas,
		tem_jogada => tem_jogada,
		jogada_igual_senha => jogada_igual_senha,
		reset_timer => reset_timer,
		enable_timer => enable_timer,
		reset_contagem => reset_contagem,
		ganhou => ganhou,
		perdeu => perdeu,
		pronto => pronto, 
		incrementa_contagem => incrementa_contagem,
		incrementa_partida => incrementa_partida,
		clr_jogada => clr_jogada,
		en_reg_jogada => en_reg_jogada,
		db_estado => s_db_estado
	);
END arch;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY circuito_projeto IS
	PORT (
		entrada_RX : IN STD_LOGIC;
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		iniciar : IN STD_LOGIC;
		tem_jogada : IN STD_LOGIC;
		leds_rgb : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		db_estado : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		db_contagem : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		db_partida : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		db_clock : OUT STD_LOGIC;
		db_tem_jogada : OUT STD_LOGIC;
		db_iniciar : OUT STD_LOGIC;
		db_fim_contador_letras : OUT STD_LOGIC;
		db_fim_rx : OUT STD_LOGIC;
		pronto : OUT STD_LOGIC;
		ganhou : OUT STD_LOGIC;
		perdeu : OUT STD_LOGIC;
		teste_fudido : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
		tem_teste : IN STD_LOGIC;
		segue: in std_logic --
	);
END ENTITY;

ARCHITECTURE arch OF circuito_projeto IS
	COMPONENT fluxo_dados IS
		PORT (
			entrada_RX : IN STD_LOGIC;
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			reset_timer : IN STD_LOGIC;
			enable_timer : IN STD_LOGIC;
			reset_contagem : IN STD_LOGIC;
			fim_tentativas : OUT STD_LOGIC;
			jogada_igual_senha : OUT STD_LOGIC;
			incrementa_contagem : IN STD_LOGIC;
			incrementa_partida : IN STD_LOGIC;
			db_contagem : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			db_partida : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			leds : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			incrementa_contagem_registrador_letra : IN STD_LOGIC;
			reset_letra : IN STD_LOGIC;
			fim_contador_letras : OUT STD_LOGIC;
			fim_rx : OUT STD_LOGIC;
			zera_contador_letras : IN STD_LOGIC;
			fim_timer : OUT STD_LOGIC;
			teste_fudido : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
			en_letra: in std_logic
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
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			iniciar : IN STD_LOGIC;
			fim_tentativas : IN STD_LOGIC;
			tem_jogada : IN STD_LOGIC;
			fim_contador_letras : IN STD_LOGIC;
			jogada_igual_senha : IN STD_LOGIC;
			fim_rx : IN STD_LOGIC;
			reset_timer : OUT STD_LOGIC;
			enable_timer : OUT STD_LOGIC;
			reset_contagem : OUT STD_LOGIC;
			ganhou : OUT STD_LOGIC;
			perdeu : OUT STD_LOGIC;
			pronto : OUT STD_LOGIC;
			incrementa_contagem_tentativas : OUT STD_LOGIC;
			incrementa_partida : OUT STD_LOGIC;
			db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			incrementa_contagem_registrador_letra : OUT STD_LOGIC;
			reset_letra : OUT STD_LOGIC;
			zera_contador_letras : OUT STD_LOGIC;
			fim_timer : IN STD_LOGIC;
			tem_teste : IN STD_LOGIC;
			segue: in std_logic;
			en_letra: out std_logic
		);
	END COMPONENT;

	COMPONENT hexa7seg IS
		PORT (
			hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL not_clock, s_reset_timer, s_enable_timer : STD_LOGIC;
	SIGNAL s_db_contagem : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_db_partida, s_db_estado : STD_LOGIC_VECTOR(3 DOWNTO 0);

	SIGNAL s_incrementa_partida, s_reset_contagem, s_jogada_igual_senha, s_fim_contador_letras, s_fim_rx, s_incrementa_contagem,
	s_incrementa_contagem_registrador_letra, s_reset_letra, s_incrementa_contagem_tentativas, s_fim_tentativas : STD_LOGIC;
	SIGNAL en_reg_jogada : STD_LOGIC;
	SIGNAL s_zera_contador_letras, s_fim_timer : STD_LOGIC;
	SIGNAL s_en_letra: std_logic
	-- signal teste_fudido : std_logic_vector(24 downto 0);
	-- signal tem_teste : std_logic_vector;
BEGIN
	s_db_contagem(3) <= '0';
	db_iniciar <= iniciar;
	db_clock <= clock;
	db_tem_jogada <= tem_jogada;
	db_fim_rx <= s_fim_rx;

	db_fim_contador_letras <= s_fim_contador_letras;

	display_contagem : hexa7seg
	PORT MAP(
		hexa => s_db_contagem,
		sseg => db_contagem
	);
	display_partida : hexa7seg
	PORT MAP(
		hexa => s_db_partida,
		sseg => db_partida
	);
	display_estado : hexa7seg
	PORT MAP(
		hexa => s_db_estado,
		sseg => db_estado
	);

	not_clock <= (NOT clock);


	fd : fluxo_dados
	PORT MAP(
		entrada_RX => entrada_RX,
		clock => clock,
		reset => reset,
		reset_timer => s_reset_timer,
		enable_timer => s_enable_timer,
		reset_contagem => s_reset_contagem,
		fim_tentativas => s_fim_tentativas,
		jogada_igual_senha => s_jogada_igual_senha,
		incrementa_contagem => s_incrementa_contagem,
		incrementa_partida => s_incrementa_partida,
		db_contagem => s_db_contagem(2 DOWNTO 0),
		db_partida => s_db_partida,
		leds => leds_rgb,
		incrementa_contagem_registrador_letra => s_incrementa_contagem_registrador_letra,
		reset_letra => s_reset_letra,
		fim_contador_letras => s_fim_contador_letras,
		fim_rx => s_fim_rx,
		zera_contador_letras => s_zera_contador_letras,
		fim_timer => s_fim_timer,
		teste_fudido => teste_fudido
		en_letra => s_en_letra
	);

	uc : unidade_controle
	PORT MAP(
		clock => not_clock,
		reset => reset,
		iniciar => iniciar,
		fim_tentativas => s_fim_tentativas,
		tem_jogada => tem_jogada,
		fim_contador_letras => s_fim_contador_letras,
		jogada_igual_senha => s_jogada_igual_senha,
		fim_rx => s_fim_rx,
		reset_timer => s_reset_timer,
		enable_timer => s_enable_timer,
		reset_contagem => s_reset_contagem,
		ganhou => ganhou,
		perdeu => perdeu,
		pronto => pronto,
		incrementa_contagem_tentativas => s_incrementa_contagem,
		incrementa_partida => s_incrementa_partida,
		db_estado => s_db_estado,
		incrementa_contagem_registrador_letra => s_incrementa_contagem_registrador_letra,
		reset_letra => s_reset_letra,
		zera_contador_letras => s_zera_contador_letras,
		fim_timer => s_fim_timer,
		tem_teste => tem_teste,
		segue => segue,
		en_letra => s_en_letra
	);
END arch;

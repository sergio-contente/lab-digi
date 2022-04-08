LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY unidade_controle IS
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
        reset_letra : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE fsm OF unidade_controle IS
    TYPE t_estado IS (
        espera,
        preparacao_jogo,
        espera_jogada,
        incrementa_contagem_letra,
        registra_letra,
        limpa_palavra,
        recebe_letra,
        compara,
        fim_perdeu,
        fim_ganhou
    );
    SIGNAL Eatual, Eprox : t_estado;
BEGIN

    -- memoria de estado
    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            Eatual <= espera;
        ELSIF clock'event AND clock = '1' THEN
            Eatual <= Eprox;
        END IF;
    END PROCESS;

    -- logica de proximo estado
    Eprox <=
        espera WHEN Eatual = espera AND iniciar = '0' ELSE
        preparacao_jogo WHEN (Eatual = espera AND iniciar = '1') ELSE
        espera_jogada WHEN (Eatual = preparacao_jogo) OR (Eatual = espera_jogada AND tem_jogada = '0') OR (Eatual = limpa_palavra) ELSE
        recebe_letra WHEN (Eatual = espera_jogada AND tem_jogada = '1') OR Eatual = incrementa_contagem_letra OR (Eatual = recebe_letra AND fim_rx = '0') ELSE
        registra_letra WHEN Eatual = recebe_letra AND fim_rx = '1' AND fim_contador_letras = '0' ELSE
        incrementa_contagem_letra WHEN Eatual = registra_letra ELSE
        limpa_palavra WHEN Eatual = compara AND fim_tentativas = '0' AND jogada_igual_senha = '0' ELSE
        compara WHEN (Eatual = recebe_letra AND fim_contador_letras = '1') ELSE
        fim_perdeu WHEN (Eatual = compara AND jogada_igual_senha = '0' AND fim_tentativas = '1') ELSE
        fim_ganhou WHEN (Eatual = compara AND jogada_igual_senha = '1')ELSE
        espera WHEN (Eatual = fim_perdeu) OR (Eatual = fim_ganhou) ELSE
        espera;

    -- logica de saída (maquina de Moore)
    ganhou <= '1' WHEN Eatual = fim_ganhou ELSE
        '0' WHEN Eatual = preparacao_jogo;
    perdeu <= '1' WHEN Eatual = fim_perdeu ELSE
        '0' WHEN Eatual = preparacao_jogo;
    pronto <= '1' WHEN Eatual = fim_perdeu ELSE
        '1' WHEN Eatual = fim_ganhou ELSE
        '0' WHEN Eatual = preparacao_jogo;
    enable_timer <= '1' WHEN Eatual = espera_jogada ELSE
        '0' WHEN Eatual = fim_perdeu ELSE
        '0' WHEN Eatual = fim_ganhou;

    WITH Eatual SELECT
        reset_letra <= '1' WHEN preparacao_jogo,
        '1' WHEN limpa_palavra,
        '0' WHEN OTHERS;
    WITH Eatual SELECT
        incrementa_contagem_registrador_letra <= '1' WHEN incrementa_contagem_letra,
        '0' WHEN OTHERS;
    WITH Eatual SELECT
        incrementa_partida <= '1' WHEN preparacao_jogo,
        '0' WHEN OTHERS;
    WITH Eatual SELECT
        incrementa_contagem_tentativas <= '1' WHEN compara,
        '0' WHEN OTHERS;
    WITH Eatual SELECT
        reset_contagem <= '1' WHEN preparacao_jogo,
        '0' WHEN OTHERS;
    WITH Eatual SELECT
        db_estado <= "0000" WHEN espera, -- 0
        "0001" WHEN preparacao_jogo, -- 1
        "0010" WHEN espera_jogada, -- 2
        "0011" WHEN registra_letra, -- 4  
        "0100" WHEN incrementa_contagem_letra, -- 5
        "0101" WHEN limpa_palavra, -- 6
        "0110" WHEN compara, -- 7
        "0111" WHEN fim_perdeu, -- 8
        "1000" WHEN fim_ganhou, -- 9
        "1111" WHEN OTHERS; -- F
END ARCHITECTURE;

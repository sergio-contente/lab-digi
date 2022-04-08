--------------------------------------------------------------------------
-- Arquivo   : testbench.vhd
-- Projeto   : Experiencia 05 - Jogo Base do Desafio da Memoria
--                              
--------------------------------------------------------------------------
-- Descricao : modelo de testbench para simulação com ModelSim
--
--             implementa o Cenário de Teste 2 do Plano de Teste
--             - acerta as 4 primeiras rodadas  
--               e erra a segunda jogada da 6a rodada
--             - usa array de casos de teste
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     04/02/2022  1.0     Jona_  criacao (adaptado da Exp.4)
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

-- entidade do testbench
ENTITY testbench_2 IS
END ENTITY;

ARCHITECTURE tb OF testbench_2 IS

    -- Componente a ser testado (Device Under Test -- DUT)
    COMPONENT circuito_projeto
        PORT (
            entrada_RX : IN STD_LOGIC;
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            iniciar : IN STD_LOGIC;
            tem_jogada : IN STD_LOGIC;
            leds_rgb : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            db_estado : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            db_contagem : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            db_partida : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            pronto : OUT STD_LOGIC;
            ganhou : OUT STD_LOGIC;
            perdeu : OUT STD_LOGIC
        );
    END COMPONENT;

    ---- Declaracao de sinais de entrada para conectar o componente
    SIGNAL clk_in : STD_LOGIC := '0';
    SIGNAL rst_in : STD_LOGIC := '0';
    SIGNAL iniciar_in : STD_LOGIC := '0';
    SIGNAL tem_jogada_in : STD_LOGIC := '0';
    SIGNAL entrada_RX_in : STD_LOGIC_VECTOR(4 DOWNTO 0) := '0';

    ---- Declaracao dos sinais de saida
    SIGNAL leds_rgb_out : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
    SIGNAL pronto_out : STD_LOGIC := '0';
    SIGNAL ganhou_out : STD_LOGIC := '0';
    SIGNAL perdeu_out : STD_LOGIC := '0';
    ---- Declaracao das saidas de depuracao
    -- inserir saidas de depuracao do seu projeto
    -- exemplos:
    -- signal estado_out       : std_logic_vector(6 downto 0) := "0000000";
    -- signal clock_out        : std_logic := '0';
    -- signal clock_out, tem_jogada_out, chavesIgualMemoria_out, enderecoIgualSequencia_out, fimS_out      : std_logic := '0';
    -- signal contagem_out, memoria_out, estado_out, jogada_feita_out, sequencia_out                       : std_logic_vector(6 downto 0):= "0000000";
    SIGNAL estado_out : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL contagem_out : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL partida_out : STD_LOGIC_VECTOR(6 DOWNTO 0);

    -- Array de casos de teste
    TYPE caso_teste_type IS RECORD
        id : NATURAL;
        jogada_certa : STD_LOGIC_VECTOR(24 DOWNTO 0);
        duracao_jogada : INTEGER;
    END RECORD;

    TYPE casos_teste_array IS ARRAY (NATURAL RANGE <>) OF caso_teste_type;
    CONSTANT casos_teste : casos_teste_array :=
    (--  id             jogada_certa             duracao_jogada
    (0, "0000100010000110010000101", 5),
    (1, "0000100010000110010000101", 5) -- conteudo da ram_16x4
    );

    -- Identificacao de casos de teste
    SIGNAL rodada_jogo : INTEGER := 0;

    -- Configurações do clock
    SIGNAL keep_simulating : STD_LOGIC := '0'; -- delimita o tempo de geração do clock
    CONSTANT clockPeriod : TIME := 1 ms; -- frequencia 1 KHz

    -----------------------------TESTANDO COMUNICAÇÂO SERIAL----------------------------------------
    ------------------------------------------------------------------------------------------------
    CONSTANT baudrate : TIME := 26.925 us; -- 38.400 baud
    PROCEDURE send_midi_byte (
        SIGNAL byte_in : IN STD_LOGIC_VECTOR;
        SIGNAL midi_out : OUT STD_LOGIC
    ) IS
        ALIAS in_byte : STD_LOGIC_VECTOR (7 DOWNTO 0) IS byte_in; -- ADDED
    BEGIN
        midi_out <= '0';
        WAIT FOR baudrate;
        FOR i IN in_byte'RANGE LOOP -- WAS 7 to 0
            midi_out <= in_byte(i); -- WAS byte_in(i);
            WAIT FOR baudrate;
        END LOOP;
        midi_out <= '1';
        WAIT FOR baudrate;
    END PROCEDURE send_midi_byte;

    SIGNAL letra : STD_LOGIC_VECTOR (7 DOWNTO 0) := x"a";
    SIGNAL midi_out : STD_LOGIC := '1'; -- fimrx
    TYPE baud IS (IDLE, START, BD0, BD1, BD2, BD3, BD4, BD5, BD6, BD7, STOP);
    SIGNAL baud_cnt : baud;
    ------------------------------------------------------------------------------------------------
    -----------------------------TESTANDO COMUNICAÇÂO SERIAL----------------------------------------
BEGIN
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
    -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
    clk_in <= (NOT clk_in) AND keep_simulating AFTER clockPeriod/2;

    ---- DUT para Caso de Teste 2
    dut : circuito_projeto
    PORT MAP
    (
        entrada_RX => in_entradas_RX,
        clock => clk_in,
        reset => rst_in,
        iniciar => iniciar_in,
        tem_jogada => tem_jogada_in,
        leds_rgb => leds_rgb_out,
        db_estado => estado_out,
        db_contagem => contagem_out,
        db_partida => partida_out,
        pronto => pronto_out,
        ganhou => ganhou_out,
        perdeu => perdeu_out
    );

    PROCEDURE_CALL :
    PROCESS
    BEGIN
        WAIT FOR baudrate; -- SHOW IDLE on midi_out;
        send_midi_byte(letra, fi); -- added second parameter
        WAIT;
    END PROCESS;
    BAUD_CTR :
    PROCESS
    BEGIN
        IF baud_cnt = IDLE THEN
            WAIT UNTIL midi_out = '0';
        END IF;
        LOOP
            baud_cnt <= baud'RIGHTOF(baud_cnt);
            WAIT FOR 0 ns;
            REPORT "baud(" & baud'image(baud_cnt) &
                ") midi_out = " & STD_ULOGIC'image(midi_out);
            WAIT FOR baudrate;
            IF baud_cnt = STOP THEN
                baud_cnt <= IDLE;
                EXIT;
            END IF;
        END LOOP;
        WAIT;
    END PROCESS;

    ---- Gera sinais de estimulo para a simulacao

    -- Cenario de Teste #2: Acerta as primeiras senha na 4 jogada 
    -- stimulus_2: process is
    -- begin

    --     -- inicio da simulacao
    --     assert false report "inicio da simulacao" severity note;
    --     keep_simulating <= '1';

    --     -- gera pulso de reset (1 periodo de clock)
    --     rst_in <= '1';
    --     wait for clockPeriod;
    --     rst_in <= '0';

    --     wait until falling_edge(clk_in);
    --     -- pulso do sinal de Iniciar
    --     iniciar_in <= '1';
    --     wait until falling_edge(clk_in);
    --     iniciar_in <= '0';

    --     wait for 10*clockPeriod;

    --     -- Cenario de Teste 2
    --     ---- jogadas da 5a rodada (erro na 2a jogada)
    --     rodada_jogo <= 0;
    --     -- espera antes da rodada
    --     wait for 1 sec;
    ---- jogada #1 (ERRADA)

    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "001";
    -- wait for 1*clockPeriod; 
    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "010";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "011";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "100";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "101";
    -- -- espera entre jogadas
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '1';
    -- indice_letra_in <= "000";
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '0';
    -- wait for 9*clockPeriod;

    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "001";
    -- wait for 1*clockPeriod; 
    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "010";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "011";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "100";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "101";
    -- -- espera entre jogadas
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '1';
    -- indice_letra_in <= "000";
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '0';
    -- wait for 9*clockPeriod;

    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "001";
    -- wait for 1*clockPeriod; 
    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "010";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00011";
    -- indice_letra_in <= "011";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00011";
    -- indice_letra_in <= "100";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00011";
    -- indice_letra_in <= "101";
    -- -- espera entre jogadas
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '1';
    -- indice_letra_in <= "000";
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '0';
    -- wait for 9*clockPeriod;

    -- letra_jogada_in <= "00001";
    -- indice_letra_in <= "001";
    -- wait for 1*clockPeriod; 
    -- letra_jogada_in <= "00010";
    -- indice_letra_in <= "010";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00011";
    -- indice_letra_in <= "011";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00100";
    -- indice_letra_in <= "100";
    -- wait for 1*clockPeriod;
    -- letra_jogada_in <= "00101";
    -- indice_letra_in <= "101";
    -- -- espera entre jogadas
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '1';
    -- indice_letra_in <= "000";
    -- wait for 1*clockPeriod;
    -- tem_jogada_in <= '0';
    -- wait for 9*clockPeriod;

    -- espera depois da jogada final
    --     wait for 20*clockPeriod;  

    --     ---- final do testbench
    --     assert false report "fim da simulacao" severity note;
    --     keep_simulating <= '0';

    --     wait; -- fim da simulação: processo aguarda indefinidamente
    -- end process;

END ARCHITECTURE;

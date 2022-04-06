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

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity testbench_2 is
end entity;

architecture tb of testbench_2 is

    -- Componente a ser testado (Device Under Test -- DUT)
    component circuito_projeto
	PORT (
		indice_letra: in std_logic_vector(2 downto 0);
		clock        : IN std_logic;
		reset        : IN std_logic;
		iniciar      : IN std_logic;
		tem_jogada   : IN std_logic;
		letra_jogada       : IN std_logic_vector(4 DOWNTO 0);
		leds_rgb     : OUT std_logic_vector(9 DOWNTO 0);
		db_estado    : OUT std_logic_vector(6 DOWNTO 0);
		db_contagem  : OUT std_logic_vector(6 DOWNTO 0);
		db_partida   : OUT std_logic_vector(6 DOWNTO 0);
		pronto       : OUT std_logic;
		ganhou       : OUT std_logic;
		perdeu       : OUT std_logic
	);
    end component;
  
    ---- Declaracao de sinais de entrada para conectar o componente
    signal clk_in           : std_logic := '0';
    signal rst_in           : std_logic := '0';
    signal iniciar_in       : std_logic := '0';
    signal tem_jogada_in    : std_logic := '0';
    signal indice_letra_in  : std_logic_vector(2 downto 0) := "000";
    signal letra_jogada_in  : std_logic_vector(4 downto 0) := "00000";
    
    ---- Declaracao dos sinais de saida
    signal leds_rgb_out     : std_logic_vector(9 downto 0) := "0000000000";
    signal pronto_out       : std_logic := '0';
    signal ganhou_out       : std_logic := '0';
    signal perdeu_out       : std_logic := '0';

    
    ---- Declaracao das saidas de depuracao
    -- inserir saidas de depuracao do seu projeto
    -- exemplos:
    -- signal estado_out       : std_logic_vector(6 downto 0) := "0000000";
    -- signal clock_out        : std_logic := '0';
    -- signal clock_out, tem_jogada_out, chavesIgualMemoria_out, enderecoIgualSequencia_out, fimS_out      : std_logic := '0';
    -- signal contagem_out, memoria_out, estado_out, jogada_feita_out, sequencia_out                       : std_logic_vector(6 downto 0):= "0000000";
    signal estado_out : std_logic_vector(6 downto 0);
    signal contagem_out : std_logic_vector(6 downto 0);
    signal partida_out : std_logic_vector(6 downto 0);
    

  
    -- Array de casos de teste
    type caso_teste_type is record
        id             : natural; 
        jogada_certa   : std_logic_vector(24 downto 0);
        duracao_jogada : integer;     
    end record;
    
    type casos_teste_array is array (natural range <>) of caso_teste_type;
    constant casos_teste : casos_teste_array :=
        (--  id             jogada_certa             duracao_jogada
            ( 0,     "0000100010000110010000101",         5),
            ( 1,     "0000100010000110010000101",         5)  -- conteudo da ram_16x4
        );

    -- Identificacao de casos de teste
    signal rodada_jogo     : integer := 0;

    -- Configurações do clock
    signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod   : time := 1 ms;     -- frequencia 1 KHz
  
begin
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
    -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
    clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
    
    ---- DUT para Caso de Teste 2
    dut: circuito_projeto
	port map
     (
        indice_letra => indice_letra_in,
		clock        => clk_in,
		reset        => rst_in,
		iniciar      => iniciar_in,
		tem_jogada   => tem_jogada_in,
		letra_jogada => letra_jogada_in,
		leds_rgb     => leds_rgb_out,
		db_estado    => estado_out,
		db_contagem  => contagem_out, 
		db_partida   => partida_out,
		pronto       => pronto_out,
		ganhou       => ganhou_out,
		perdeu       => perdeu_out
	);
    
    ---- Gera sinais de estimulo para a simulacao
    
    -- Cenario de Teste #2: Acerta as primeiras senha na 4 jogada 
    stimulus_2: process is
    begin
    
        -- inicio da simulacao
        assert false report "inicio da simulacao" severity note;
        keep_simulating <= '1';
	    
        -- gera pulso de reset (1 periodo de clock)
        rst_in <= '1';
        wait for clockPeriod;
        rst_in <= '0';
	    
        wait until falling_edge(clk_in);
        -- pulso do sinal de Iniciar
        iniciar_in <= '1';
        wait until falling_edge(clk_in);
        iniciar_in <= '0';
	    
        wait for 10*clockPeriod;
	    
        -- Cenario de Teste 2
        ---- jogadas da 5a rodada (erro na 2a jogada)
        rodada_jogo <= 0;
        -- espera antes da rodada
        wait for 1 sec;
        ---- jogada #1 (ERRADA)
        
        letra_jogada_in <= "00010";
        indice_letra_in <= "001";
        wait for 1*clockPeriod; 
        letra_jogada_in <= "00010";
        indice_letra_in <= "010";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00010";
        indice_letra_in <= "011";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00010";
        indice_letra_in <= "100";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00001";
        indice_letra_in <= "101";
        -- espera entre jogadas
        wait for 1*clockPeriod;
        tem_jogada_in <= '1';
        indice_letra_in <= "000";
        wait for 1*clockPeriod;
        tem_jogada_in <= '0';
        wait for 9*clockPeriod;

        letra_jogada_in <= "00001";
        indice_letra_in <= "001";
        wait for 1*clockPeriod; 
        letra_jogada_in <= "00010";
        indice_letra_in <= "010";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00001";
        indice_letra_in <= "011";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00001";
        indice_letra_in <= "100";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00001";
        indice_letra_in <= "101";
        -- espera entre jogadas
        wait for 1*clockPeriod;
        tem_jogada_in <= '1';
        indice_letra_in <= "000";
        wait for 1*clockPeriod;
        tem_jogada_in <= '0';
        wait for 9*clockPeriod;

        letra_jogada_in <= "00001";
        indice_letra_in <= "001";
        wait for 1*clockPeriod; 
        letra_jogada_in <= "00010";
        indice_letra_in <= "010";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00011";
        indice_letra_in <= "011";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00011";
        indice_letra_in <= "100";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00011";
        indice_letra_in <= "101";
        -- espera entre jogadas
        wait for 1*clockPeriod;
        tem_jogada_in <= '1';
        indice_letra_in <= "000";
        wait for 1*clockPeriod;
        tem_jogada_in <= '0';
        wait for 9*clockPeriod;
        
        letra_jogada_in <= "00001";
        indice_letra_in <= "001";
        wait for 1*clockPeriod; 
        letra_jogada_in <= "00010";
        indice_letra_in <= "010";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00011";
        indice_letra_in <= "011";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00100";
        indice_letra_in <= "100";
        wait for 1*clockPeriod;
        letra_jogada_in <= "00101";
        indice_letra_in <= "101";
        -- espera entre jogadas
        wait for 1*clockPeriod;
        tem_jogada_in <= '1';
        indice_letra_in <= "000";
        wait for 1*clockPeriod;
        tem_jogada_in <= '0';
        wait for 9*clockPeriod;
	
        -- espera depois da jogada final
        wait for 20*clockPeriod;  
	    
        ---- final do testbench
        assert false report "fim da simulacao" severity note;
        keep_simulating <= '0';
        
        wait; -- fim da simulação: processo aguarda indefinidamente
    end process;

end architecture;

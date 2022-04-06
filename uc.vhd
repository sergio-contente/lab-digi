library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is
    port (
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
    incrementa_contagem : out std_logic;
    incrementa_partida : out std_logic;
    clr_jogada : out std_logic;
    en_reg_jogada : out std_logic;
    db_estado : out std_logic_vector(3 downto 0)
    );
   end entity;

architecture fsm of unidade_controle is
    type t_estado is (
            espera,
            preparacao_jogo,
            espera_jogada,
            compara,
            fim_perdeu,
            fim_ganhou
        );
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= espera;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        espera                  when  Eatual=espera and iniciar='0' else
        preparacao_jogo         when  Eatual=espera and iniciar='1' else
        espera_jogada           when  Eatual=preparacao_jogo or (Eatual=compara and tem_jogada='0' and jogada_igual_senha = '0' and fim_tentativas = '0') or (Eatual=espera_jogada and tem_jogada='0') or (Eatual=compara and (fim_tentativas = '0') and (jogada_igual_senha = '0')) else
        compara                 when  Eatual=espera_jogada and tem_jogada = '1' else
        fim_perdeu              when  (Eatual=compara and jogada_igual_senha = '0' and fim_tentativas = '1') or (Eatual=fim_perdeu and iniciar = '0') else
        fim_ganhou              when  (Eatual=compara and jogada_igual_senha = '1') or (Eatual=fim_ganhou and iniciar = '0')else
        espera                  when  (Eatual=fim_perdeu and iniciar = '1') or (Eatual=fim_ganhou and iniciar = '1') else
        espera;

    -- logica de saída (maquina de Moore)
    ganhou <=     '1' when Eatual = fim_ganhou else
                    '0' when Eatual = preparacao_jogo;
    perdeu <=     '1' when Eatual = fim_perdeu else
                    '0' when Eatual = preparacao_jogo;
    pronto <=     '1' when Eatual = fim_perdeu else
                    '1' when Eatual = fim_ganhou else
                    '0' when Eatual = preparacao_jogo;
    enable_timer <='1' when Eatual = espera_jogada else
                    '0' when Eatual = fim_perdeu else
                    '0' when Eatual = fim_ganhou;
    with Eatual select
        reset_timer <='1' when preparacao_jogo,
                      '0' when others;
    with Eatual select
        incrementa_partida <='1' when preparacao_jogo,
                            '0' when others;
    with Eatual select
        incrementa_contagem <='1' when compara,
                                '0' when others;
    with Eatual select
	    reset_contagem <='1' when preparacao_jogo,
                         '0' when others;
    with Eatual select
	    en_reg_jogada <= '1' when compara,
                         '0' when others;
    with Eatual select
        clr_jogada <= '1' when preparacao_jogo,
                      '0' when others;
    with Eatual select
        db_estado <=  "0000" when espera,     -- 0
                      "0001" when preparacao_jogo,  -- 1
                      "0010" when espera_jogada,     -- 2
                      "0100" when compara,    -- 4
                      "0101" when fim_perdeu,  -- 5
                      "0110" when fim_ganhou,     -- 6
                      "1111" when others;      -- F
end architecture;

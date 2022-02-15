library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is
    port (
    clock : in std_logic;
    reset : in std_logic;
    iniciar : in std_logic;
    fimE : in std_logic;
	fimS : in std_logic;
	fimTMR : in std_logic;
	igualJ : in std_logic;
	igualS : in std_logic;
    jogada : in std_logic;
	contaE : out std_logic;
	contaS : out std_logic;
	contaTMR : out std_logic;
    ganhou : out std_logic;
    limpaM : out std_logic;
    limpaR : out std_logic;
    perdeu : out std_logic;
    pronto : out std_logic;
    registraM : out std_logic;
    registraR : out std_logic;
	zeraE : out std_logic;
	zeraS : out std_logic;
	zeraTMR : out std_logic;
    db_estado : out std_logic_vector(3 downto 0)
    );
   end entity;

architecture fsm of unidade_controle is
    type t_estado is (
            inicial,
            preparacao_jogo,
            preparacao_leds,
            led_aceso,
            reset_leds,
            led_apagado,
            aumenta_endereco_led,
            zera_endereco,
            espera_jogada,
            registra_jogada,
            compara_jogada,
            fim_perdeu,
            fim_ganhou,
            aumenta_endereco_jogada,
            proxima_sequencia
        );
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        inicial                 when  Eatual=inicial and iniciar='0' else
        preparacao_jogo         when  Eatual=inicial and iniciar='1' else
        preparacao_leds         when  Eatual=preparacao_jogo or Eatual=aumenta_endereco_led or Eatual=proxima_sequencia else
        led_aceso               when  Eatual=preparacao_leds or (Eatual=led_aceso and fimTMR = '0') else
        reset_leds              when  Eatual=led_aceso and fimTMR = '1' else
        led_apagado             when  Eatual=reset_leds or (Eatual=led_apagado and fimTMR = '0') else
        aumenta_endereco_led    when  Eatual=led_apagado and fimS='0' and fimTMR='1' else
        zera_endereco           when  Eatual=led_apagado and fimS='1' and fimTMR='1' else
        espera_jogada           when  Eatual=zera_endereco or (Eatual=espera_jogada and jogada = '0') else
        registra_jogada         when  Eatual=espera_jogada and jogada= '1' else
        compara_jogada          when  Eatual=registra_jogada else
        fim_perdeu              when  (Eatual=compara_jogada and igualJ = '0') or (Eatual = fim_perdeu and iniciar = '0') else
        fim_ganhou              when  (Eatual=compara_jogada and igualJ = '1' and fimS='1' and fimE='1') or (Eatual = fim_ganhou and iniciar = '0') else
        aumenta_endereco_jogada when Eatual=compara_jogada and fimS = '0' else
        proxima_sequencia       when  Eatual=compara_jogada and fimS = '1' and fimE = '0' else
        preparacao_leds         when  Eatual=proxima_sequencia else
        espera_jogada           when Eatual=aumenta_endereco_jogada else
        inicial                 when  Eatual=fim_perdeu and iniciar = '1' else
        inicial                 when  Eatual=fim_ganhou and iniciar = '1' else
        inicial;

    -- logica de saída (maquina de Moore)
    with Eatual select
        contaE <=     '1' when aumenta_endereco_led,
                      '1' when aumenta_endereco_jogada,
                      '0' when others;
    with Eatual select
	    contaS <=     '1' when proxima_sequencia,
                      '0' when others;
    with Eatual select
	    contaTMR <=   '1' when led_aceso,
                      '1' when led_apagado,
                      '0' when others;
    with Eatual select
        ganhou <=     '1' when fim_ganhou,
                      '0' when others;
    with Eatual select
        limpaM <=     '1' when preparacao_jogo,
                      '1' when reset_leds,
                      '0' when others;
    with Eatual select
        limpaR <=     '1' when preparacao_jogo,
                      '0' when others;
    with Eatual select
        perdeu <=     '1' when fim_perdeu,
                      '0' when others;
    with Eatual select
        pronto <=     '1' when fim_perdeu,
                      '1' when fim_ganhou,
                      '0' when others;
    with Eatual select
        registraM <=  '1' when preparacao_leds,
                      '0' when others;
    with Eatual select
        registraR <=  '1' when registra_jogada,
                      '0' when others;
    with Eatual select
	    zeraE <=      '1' when zera_endereco,
                      '0' when others;
    with Eatual select
	    zeraS <=      '1' when preparacao_jogo,
                      '0' when others;
    with Eatual select
	    zeraTMR <=    '1' when preparacao_leds,
                      '1' when reset_leds,
                      '0' when others;
    with Eatual select
        db_estado <=  "0000" when inicial,     -- 0
                      "0001" when preparacao_jogo,  -- 1
                      "0010" when preparacao_leds,    -- 2
                      "0011" when led_aceso,  -- 3
                      "0100" when reset_leds,     -- 4
                      "0101" when led_apagado, -- 5
                      "0110" when aumenta_endereco_led,   -- 6
                      "0111" when zera_endereco,      -- 7
                      "1000" when espera_jogada,     -- 8
                      "1001" when registra_jogada,  -- 9
                      "1010" when compara_jogada,    -- A
                      "1011" when fim_perdeu,  -- B
                      "1100" when fim_ganhou,     -- C
                      "1101" when aumenta_endereco_jogada, -- D
                      "1110" when proxima_sequencia,   -- E
                      "1111" when others;      -- F
end architecture;

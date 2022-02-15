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
    db_estado : out std_logic_vector(4 downto 0)
    );
   end entity;

architecture fsm of unidade_controle is
	type t_estado is (inicial, preparacao, espera_jogada, registra, comparacao, proximo, fim_acertou, fim_errou);
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
        inicial       when  Eatual=inicial and iniciar='0' else
        preparacao    when  Eatual=inicial and iniciar='1' else
        espera_jogada when  Eatual = preparacao or (Eatual = espera_jogada and jogada = '0') else
        registra      when  Eatual=espera_jogada and jogada = '1' else
        comparacao    when  Eatual=registra else
        proximo       when  Eatual=comparacao and fim='0' and igual = '1' else
        fim_errou     when  (Eatual=comparacao and igual = '0') or (Eatual = fim_errou and iniciar = '0') else
        fim_acertou   when  (Eatual=comparacao and igual = '1' and fim='1') or (Eatual = fim_acertou and iniciar = '0') else
        espera_jogada when  Eatual=proximo else
        preparacao    when  Eatual=fim_errou and iniciar = '1' else
        preparacao    when  Eatual=fim_acertou and iniciar = '1' else
        inicial;

    -- logica de saída (maquina de Moore)
    with Eatual select
        zeraC <=      '1' when preparacao,
                      '1' when inicial,
                      '0' when others;
    
    with Eatual select
        zeraR <=      '1' when inicial,
                      '0' when others;
    
    with Eatual select
        registraR <=   '1' when registra,
                      '0' when others;

    with Eatual select
        contaC <=     '1' when proximo,
                      '0' when others;
    
    with Eatual select
        pronto <=     '1' when fim_errou,
                      '1' when fim_acertou,
                      '0' when others;

    with Eatual select
        acertou <=    '1' when fim_acertou,
                      '0' when others;
    with Eatual select
        errou <= '1' when fim_errou,
                 '0' when others;
    
    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,     -- 0
                     "0001" when preparacao,  -- 1
                     "0010" when registra,    -- 2
                     "0011" when comparacao,  -- 3
                     "0100" when proximo,     -- 4
                     "0110" when fim_acertou, -- 6
                     "0111" when fim_errou,   -- 7
                     "1111" when others;      -- F
end architecture;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY fluxo_dados IS
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
    leds : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- S0-S1
    incrementa_contagem_registrador_letra : IN STD_LOGIC;
    reset_letra : IN STD_LOGIC;
    fim_contador_letras : OUT STD_LOGIC;
    fim_rx : OUT STD_LOGIC;
    zera_contador_letras : IN STD_LOGIC;
    fim_timer : OUT STD_LOGIC;
    teste_fudido : in STD_LOGIC_VECTOR(39 DOWNTO 0);
    en_letra: in std_logic
  );
END ENTITY;

ARCHITECTURE estrutural OF fluxo_dados IS

  TYPE vector5 IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL vec_jogadas : vector5(24 DOWNTO 0);
  SIGNAL vec_senhas : vector5(24 DOWNTO 0);
  SIGNAL vec_saidas : STD_LOGIC_VECTOR(24 DOWNTO 0);
  --SIGNAL s_en_letra : STD_LOGIC;
  SIGNAL enable : std_logic;
  -- SIGNAL s_en_letra2 : STD_LOGIC;
  -- SIGNAL s_en_letra3 : STD_LOGIC;
  -- SIGNAL s_en_letra4 : STD_LOGIC;
  -- SIGNAL s_en_letra5 : STD_LOGIC;
  SIGNAL contagem_letras : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL letra_jogada : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL letra_jogada_1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL letra_jogada_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL letra_jogada_3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL letra_jogada_4 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL letra_jogada_5 : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL s_endereco : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_sequencia : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_senha : STD_LOGIC_VECTOR (39 DOWNTO 0);
  SIGNAL vetor_zero : STD_LOGIC_VECTOR (39 DOWNTO 0);
  SIGNAL s_contagem : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL s_jogada : STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL s_dado : STD_LOGIC_VECTOR (3 DOWNTO 0);

  SIGNAL saida_contador_endereco : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL enable_registrador_letra : STD_LOGIC;

  signal s_fim_timer : std_logic;
  COMPONENT rx IS
    GENERIC (baudrate : INTEGER := 9600);
    PORT (
      clock : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      sin : IN STD_LOGIC;
      dado : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      fim : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT registrador_8 IS
    PORT (
      clock : IN STD_LOGIC;
      clear : IN STD_LOGIC;
      en1 : IN STD_LOGIC;
      en2 : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT ram_16x40 IS
    PORT (
      clk : IN STD_LOGIC;
      endereco : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dado_entrada : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
      we : IN STD_LOGIC;
      ce : IN STD_LOGIC;
      dado_saida : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT alfabeto7seg IS
    PORT (
      letra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT contador_163
    PORT (
      clock : IN STD_LOGIC;
      clr : IN STD_LOGIC;
      ld : IN STD_LOGIC;
      ent : IN STD_LOGIC;
      enp : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      rco : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT contador_5 IS
    PORT (
      clock : IN STD_LOGIC;
      clr : IN STD_LOGIC;
      ld : IN STD_LOGIC;
      ent : IN STD_LOGIC;
      enp : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      rco : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT contador_6 IS
    PORT (
      clock : IN STD_LOGIC;
      clr : IN STD_LOGIC;
      ld : IN STD_LOGIC;
      ent : IN STD_LOGIC;
      enp : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      rco : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT contador_m IS
    GENERIC (
      CONSTANT M : INTEGER := 100 -- modulo do contador
    );
    PORT (
      clock : IN STD_LOGIC;
      zera_as : IN STD_LOGIC;
      zera_s : IN STD_LOGIC;
      conta : IN STD_LOGIC;
      Q : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      fim : OUT STD_LOGIC;
      meio : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT comparador_igualdade IS
    PORT (
      jogada_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      senha_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      o_AEQB : OUT STD_LOGIC
    );
  END COMPONENT;

  component mostrador_leds is
    port (
        clock   : in  std_logic;
        zera : in  std_logic;
        vec_saidas  : in  std_logic_vector(24 downto 0);
        enable   : in  std_logic;
        endereco  : in std_logic_vector(2 downto 0);
        leds    : out std_logic_vector(4 downto 0)
    );
end component;

BEGIN

  regs : FOR i IN 0 TO 24 GENERATE
    comparadores : comparador_igualdade PORT MAP(
      jogada_in => vec_jogadas(i),
      senha_in => vec_senhas(i),
      o_AEQB => vec_saidas(i)
    );
  END GENERATE;

  vetor_zero <= (OTHERS => '0');
  db_contagem <= s_contagem;
  db_partida <= s_endereco;

  -- s_en_letra1 <= '1' WHEN enable_registrador_letra = '1' AND contagem_letras = "000" ELSE
  --   '0';
  -- s_en_letra2 <= '1' WHEN enable_registrador_letra = '1' AND contagem_letras = "001" ELSE
  --   '0';
  -- s_en_letra3 <= '1' WHEN enable_registrador_letra = '1' AND contagem_letras = "010" ELSE
  --   '0';
  -- s_en_letra4 <= '1' WHEN enable_registrador_letra = '1' AND contagem_letras = "011" ELSE
  --   '0';
  -- s_en_letra5 <= '1' WHEN enable_registrador_letra = '1' AND contagem_letras = "100" ELSE
  --   '0';

  jogada_igual_senha <= '1' WHEN (vec_saidas(0) = '1' AND vec_saidas(6) = '1' AND vec_saidas(12) = '1' AND vec_saidas(18) = '1' AND vec_saidas(24) = '1') ELSE
    '0';

  fim_timer <= s_fim_timer;
  timer : contador_m
  PORT MAP(
    clock => clock,
    zera_as => reset_timer,
    zera_s => '0',
    conta => enable_timer,
    Q => OPEN,
    fim => s_fim_timer,
    meio => OPEN
  );

  mostrador: mostrador_leds
  port map (
        clock   => clock,
        zera => reset,
        vec_saidas => vec_saidas,
        enable   => s_fim_timer,
        endereco  => contagem_letras,
        leds    => leds
    );

  -- leds_colors : PROCESS (s_fim_timer) IS
  -- BEGIN
  --   IF s_fim_timer = '1' THEN
  --     IF contagem_letras = "000" THEN
  --       IF vec_saidas(4 DOWNTO 0) = "00000" THEN
  --         leds(2 DOWNTO 0) <= "000";
  --         leds(4 DOWNTO 3) <= "10"; -- vermelho
  --       ELSIF vec_saidas(0) = '1' THEN
  --         leds(2 DOWNTO 0) <= "000";
  --         leds(4 DOWNTO 3) <= "11"; -- verde
  --       ELSE
  --         leds(2 DOWNTO 0) <= "000";
  --         leds(4 DOWNTO 3) <= "01"; -- amarelo
  --       END IF;
  --     ELSIF contagem_letras = "001" THEN
  --       IF vec_saidas(9 DOWNTO 5) = "00000" THEN
  --         leds(2 DOWNTO 0) <= "001";
  --         leds(4 DOWNTO 3) <= "10"; -- vermelho
  --       ELSIF vec_saidas(6) = '1' THEN
  --         leds(2 DOWNTO 0) <= "001";
  --         leds(4 DOWNTO 3) <= "11"; -- verde
  --       ELSE
  --         leds(2 DOWNTO 0) <= "001";
  --         leds(4 DOWNTO 3) <= "01"; -- amarelo
  --       END IF;
  --     ELSIF contagem_letras = "010" THEN
  --       IF vec_saidas(14 DOWNTO 10) = "00000" THEN
  --         leds(2 DOWNTO 0) <= "010";
  --         leds(4 DOWNTO 3) <= "10"; -- vermelho
  --       ELSIF vec_saidas(12) = '1' THEN
  --         leds(2 DOWNTO 0) <= "010";
  --         leds(4 DOWNTO 3) <= "11"; -- verde
  --       ELSE
  --         leds(2 DOWNTO 0) <= "010";
  --         leds(4 DOWNTO 3) <= "01"; -- amarelo
  --       END IF;
  --     ELSIF contagem_letras = "011" THEN
  --       IF vec_saidas(19 DOWNTO 15) = "00000" THEN
  --         leds(2 DOWNTO 0) <= "011";
  --         leds(4 DOWNTO 3) <= "10"; -- vermelho
  --       ELSIF vec_saidas(18) = '1' THEN
  --         leds(2 DOWNTO 0) <= "011";
  --         leds(4 DOWNTO 3) <= "11"; -- verde
  --       ELSE
  --         leds(2 DOWNTO 0) <= "011";
  --         leds(4 DOWNTO 3) <= "01"; -- amarelo
  --       END IF;
  --     ELSIF contagem_letras = "100" THEN
  --       IF vec_saidas(24 DOWNTO 20) = "00000" THEN
  --         leds(2 DOWNTO 0) <= "100";
  --         leds(4 DOWNTO 3) <= "10"; -- vermelho
  --       ELSIF vec_saidas(24) = '1' THEN
  --         leds(2 DOWNTO 0) <= "100";
  --         leds(4 DOWNTO 3) <= "11"; -- verde
  --       ELSE
  --         leds(2 DOWNTO 0) <= "100";
  --         leds(4 DOWNTO 3) <= "01"; -- amarelo
  --       END IF;
  --     END IF;
  --   END IF;
  -- END PROCESS; -- identifier

  contador_partida : contador_163
  PORT MAP(
    clock => clock,
    clr => reset,
    ld => '1',
    ent => '1',
    enp => incrementa_partida,
    D => "0000",
    Q => s_endereco,
    RCO => OPEN
  );

  contador_letras : contador_5
  PORT MAP(
    clock => clock,
    clr => zera_contador_letras,
    ld => '0',
    ent => '1',
    enp => incrementa_contagem_registrador_letra,
    D => "000",
    Q => contagem_letras,
    RCO => fim_contador_letras
  );
  
 enable <= contagem_letras;
  
 
 
 letra1 : registrador_8
  PORT MAP(
    clock => clock,
    clear => reset_letra,
    en1 => en_letra,
    en2 => en_letra,
    D => letra_jogada,
    Q => s_jogada
  );
  -- letra3 : registrador_8
  -- PORT MAP(
  --   clock => clock,
  --   clear => reset_letra,
  --   en1 => s_en_letra3,
  --   en2 => s_en_letra3,
  --   D => letra_jogada,
  --   Q => s_jogada(23 DOWNTO 16)
  -- );
  -- letra4 : registrador_8
  -- PORT MAP(
  --   clock => clock,
  --   clear => reset_letra,
  --   en1 => s_en_letra4,
  --   en2 => s_en_letra4,
  --   D => letra_jogada,
  --   Q => s_jogada(31 DOWNTO 24)
  -- );
  -- letra5 : registrador_8
  -- PORT MAP(
  --   clock => clock,
  --   clear => reset_letra,
  --   en1 => s_en_letra5,
  --   en2 => s_en_letra5,
  --   D => letra_jogada,
  --   Q => s_jogada(39 DOWNTO 32)
  -- );

  fim_rx <= enable_registrador_letra;

  receiver : rx PORT MAP(
    clock => clock,
    reset => '0',
    sin => entrada_RX, --dado em serial (pinar em PIN_M20)
    dado => letra_jogada, --Dado em 8bits
    fim => enable_registrador_letra -- usar pra contar o contador do lugar da mem??ria
  );

  conta_jogada : contador_6
  PORT MAP(
    clock => clock,
    clr => reset_contagem,
    ld => '0',
    ent => '1',
    enp => incrementa_contagem,
    D => "000",
    Q => s_contagem,
    rco => fim_tentativas
  );

  leds <= "11" when s_jogada = s_senha(7 downto 0) and enable="000" OR -- VERDE
                    s_jogada = s_senha(15 downto 8) and enable="001" OR
                    s_jogada = s_senha(23 downto 16) and enable="010" OR
                    s_jogada = s_senha(31 downto 24) and enable="010" OR
                    s_jogada = s_senha(39 downto 32) and enable="100" ELSE
          "01" when s_jogada = s_senha(7 downto 0) and NOT enable="000" OR -- AMARELO
                    s_jogada = s_senha(15 downto 8) and NOT enable="001" OR
                    s_jogada = s_senha(23 downto 16) and NOT enable="010" OR
                    s_jogada = s_senha(31 downto 24) and NOT enable="010" OR
                    s_jogada = s_senha(39 downto 32) and NOT enable="100" ELSE
          "00" when s_jogada = "00000000" ELSE
          "10"; -- VERMELHO
          
-- reg_ultima_jogada : registrador_25
  -- PORT MAP(
  --   clock => clock,
  --   clear => clr_jogada,
  --   en1 => en_reg_jogada,
  --   en2 => en_reg_jogada,
  --   D => jogada,
  --   Q => s_jogada
  -- );

  letra_jogada_1 <= teste_fudido(7 DOWNTO 0);
  letra_jogada_2 <= teste_fudido(15 DOWNTO 8);
  letra_jogada_3 <= teste_fudido(23 DOWNTO 16);
  letra_jogada_4 <= teste_fudido(31 DOWNTO 24);
  letra_jogada_5 <= teste_fudido(39 DOWNTO 32);

  -- vec_jogadas(0) <= letra_jogada_1;
  -- vec_jogadas(1) <= letra_jogada_1;
  -- vec_jogadas(2) <= letra_jogada_1;
  -- vec_jogadas(3) <= letra_jogada_1;
  -- vec_jogadas(4) <= letra_jogada_1;
  -- vec_jogadas(5) <= letra_jogada_2;
  -- vec_jogadas(6) <= letra_jogada_2;
  -- vec_jogadas(7) <= letra_jogada_2;
  -- vec_jogadas(8) <= letra_jogada_2;
  -- vec_jogadas(9) <= letra_jogada_2;
  -- vec_jogadas(10) <= letra_jogada_3;
  -- vec_jogadas(11) <= letra_jogada_3;
  -- vec_jogadas(12) <= letra_jogada_3;
  -- vec_jogadas(13) <= letra_jogada_3;
  -- vec_jogadas(14) <= letra_jogada_3;
  -- vec_jogadas(15) <= letra_jogada_4;
  -- vec_jogadas(16) <= letra_jogada_4;
  -- vec_jogadas(17) <= letra_jogada_4;
  -- vec_jogadas(18) <= letra_jogada_4;
  -- vec_jogadas(19) <= letra_jogada_4;
  -- vec_jogadas(20) <= letra_jogada_5;
  -- vec_jogadas(21) <= letra_jogada_5;
  -- vec_jogadas(22) <= letra_jogada_5;
  -- vec_jogadas(23) <= letra_jogada_5;
  -- vec_jogadas(24) <= letra_jogada_5;

  -- vec_senhas(0) <= s_senha(7 DOWNTO 0);
  -- vec_senhas(1) <= s_senha(15 DOWNTO 8);
  -- vec_senhas(2) <= s_senha(23 DOWNTO 16);
  -- vec_senhas(3) <= s_senha(31 DOWNTO 24);
  -- vec_senhas(4) <= s_senha(39 DOWNTO 32);
  -- vec_senhas(5) <= s_senha(7 DOWNTO 0);
  -- vec_senhas(6) <= s_senha(15 DOWNTO 8);
  -- vec_senhas(7) <= s_senha(23 DOWNTO 16);
  -- vec_senhas(8) <= s_senha(31 DOWNTO 24);
  -- vec_senhas(9) <= s_senha(39 DOWNTO 32);
  -- vec_senhas(10) <= s_senha(7 DOWNTO 0);
  -- vec_senhas(11) <= s_senha(15 DOWNTO 8);
  -- vec_senhas(12) <= s_senha(23 DOWNTO 16);
  -- vec_senhas(13) <= s_senha(31 DOWNTO 24);
  -- vec_senhas(14) <= s_senha(39 DOWNTO 32);
  -- vec_senhas(15) <= s_senha(7 DOWNTO 0);
  -- vec_senhas(16) <= s_senha(15 DOWNTO 8);
  -- vec_senhas(17) <= s_senha(23 DOWNTO 16);
  -- vec_senhas(18) <= s_senha(31 DOWNTO 24);
  -- vec_senhas(19) <= s_senha(39 DOWNTO 32);
  -- vec_senhas(20) <= s_senha(7 DOWNTO 0);
  -- vec_senhas(21) <= s_senha(15 DOWNTO 8);
  -- vec_senhas(22) <= s_senha(23 DOWNTO 16);
  -- vec_senhas(23) <= s_senha(31 DOWNTO 24);
  -- vec_senhas(24) <= s_senha(39 DOWNTO 32);

  --memoria : ram_16x40 -- usar para Quartus
  memoria : ENTITY work.ram_16x40(ram_modelsim) -- usar para ModelSim
  PORT MAP(
    clk => clock,
    endereco => s_endereco,
    dado_entrada => vetor_zero,
    we => '1', -- we ativo baixo
    ce => '0',
    dado_saida => s_senha
  );
END estrutural;

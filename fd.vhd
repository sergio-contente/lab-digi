LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

entity fluxo_dados is
  port (
  indice_letra: in std_logic_vector(2 downto 0);
  clock : in std_logic;
  reset : in std_logic;
  reset_timer : in std_logic;
	enable_timer : in std_logic;
	reset_contagem : in std_logic;
  letra_jogada : in std_logic_vector(4 downto 0);
  fim_tentativas : out std_logic;
	jogada_igual_senha : out std_logic;
  incrementa_contagem : in std_logic;
  incrementa_partida : in std_logic;
  clr_jogada : in std_logic;
  en_reg_jogada : in std_logic;
  db_contagem : out std_logic_vector(2 downto 0);
  db_partida : out std_logic_vector(3 downto 0);
  leds: out std_logic_vector (9 downto 0)
  );
 end entity;

ARCHITECTURE estrutural OF fluxo_dados IS

  type vector5 is array (natural range <>) of std_logic_vector(4 downto 0);

  signal vec_jogadas : vector5(24 downto 0);
  signal vec_senhas : vector5(24 downto 0);
  signal vec_saidas : std_logic_vector(24 downto 0);
  signal letra_jogada_1 : std_logic_vector(4 downto 0);
  signal letra_jogada_2 : std_logic_vector(4 downto 0);
  signal letra_jogada_3 : STD_LOGIC_VECTOR (4 downto 0);
  signal letra_jogada_4 : STD_LOGIC_VECTOR (4 downto 0);
  signal letra_jogada_5 : STD_LOGIC_VECTOR (4 DOWNTO 0);
  signal s_en_letra1 : std_logic;
  signal s_en_letra2 : std_logic;
  signal s_en_letra3 : std_logic;
  signal s_en_letra4 : std_logic;
  signal s_en_letra5 : std_logic;

  SIGNAL s_endereco : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_sequencia : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_senha: STD_LOGIC_VECTOR (24 downto 0);
  SIGNAL vetor_zero: STD_LOGIC_VECTOR (24 DOWNTO 0);
  SIGNAL s_contagem : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL s_jogada : STD_LOGIC_VECTOR (24 DOWNTO 0);
  SIGNAL s_dado : STD_LOGIC_VECTOR (3 DOWNTO 0);

  component registrador_5 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (4 downto 0);
        Q     : out std_logic_vector (4 downto 0)
   );
  end component;

  component ram_16x25 is
    port (       
      clk          : in  std_logic;
      endereco     : in  std_logic_vector(3 downto 0);
      dado_entrada : in  std_logic_vector(24 downto 0);
      we           : in  std_logic;
      ce           : in  std_logic;
      dado_saida   : out std_logic_vector(24 downto 0)
    );
  end component;

  component alfabeto7seg is
    port (
        letra : in  std_logic_vector(4 downto 0);
        sseg   : out std_logic_vector(6 downto 0)
    );
  end component;

  component registrador_25 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (24 downto 0);
        Q     : out std_logic_vector (24 downto 0)
   );
  end component;

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

  component contador_6 is
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (2 downto 0);
        Q     : out std_logic_vector (2 downto 0);
        rco   : out std_logic 
   );
  end component;

  component contador_m is
    generic (
        constant M: integer := 100 -- modulo do contador
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(26 downto 0);
        fim     : out std_logic;
        meio    : out std_logic
    );
end component;

component comparador_igualdade is
  port (
    jogada_in : in std_logic_vector(4 downto 0);
    senha_in : in std_logic_vector(4 downto 0);
    o_AEQB : out std_logic
  );
end component;

BEGIN

  regs: for i in 0 to 24 generate
    comparadores: comparador_igualdade port map(
      jogada_in => vec_jogadas(i),
      senha_in => vec_senhas(i),
      o_AEQB => vec_saidas(i)
    );
  end generate;
					
  vetor_zero <= (others => '0');
  db_contagem <= s_contagem;
  db_partida <= s_endereco;

  jogada_igual_senha <= '1' when (vec_saidas(0) = '1' and vec_saidas(6) = '1' and vec_saidas(12) = '1' and vec_saidas(18) = '1' and vec_saidas(24) = '1') else
                        '0';

  leds_colors : process( vec_saidas ) is 
  variable pos : integer := 0;
  begin
    assign_colors : for i in 0 to 4 loop
      if vec_saidas(5*i + 4 downto 5*i) = "00000" then
        leds(2*i + 1 downto 2*i) <= "10"; -- vermelho
      elsif vec_saidas(6*i) = '1' then
        leds(2*i + 1 downto 2*i) <= "00"; -- verde
      else
        leds(2*i + 1 downto 2*i) <= "01"; -- amarelo
      end if;
    end loop ; -- identifier
  end process ; -- identifier

  
  contador_partida : contador_163
  PORT MAP(
    clock => clock, 
    clr   => reset, 
    ld    => '1', 
    ent   => '1', 
    enp   => incrementa_partida, 
    D     => "0000",
    Q     => s_endereco, 
    RCO   => open
    );

    s_en_letra1 <= (indice_letra(0) and (not indice_letra(1)) and (not indice_letra(2)));
    s_en_letra2 <= ((not indice_letra(0)) and (indice_letra(1)) and (not indice_letra(2)));
    s_en_letra3 <= ((indice_letra(0)) and (indice_letra(1)) and (not indice_letra(2)));
    s_en_letra4 <= ((not indice_letra(0)) and (not indice_letra(1)) and (indice_letra(2)));
    s_en_letra5 <= ((indice_letra(0)) and (not indice_letra(1)) and (indice_letra(2)));

    registradores_intermediarios1: registrador_5
    PORT MAP (
      clock  => clock,
      clear => reset,
      en1   => s_en_letra1,
      en2   => s_en_letra1,
      D     => letra_jogada,
      Q     => s_jogada(4 downto 0)
    );
    registradores_intermediarios2: registrador_5
    PORT MAP (
      clock  => clock,
      clear => reset,
      en1   => s_en_letra2,
      en2   => s_en_letra2,
      D     => letra_jogada,
      Q     => s_jogada(9 downto 5)
    );
    registradores_intermediarios3: registrador_5
    PORT MAP (
      clock  => clock,
      clear => reset,
      en1   => s_en_letra3,
      en2   => s_en_letra3,
      D     => letra_jogada,
      Q     => s_jogada(14 downto 10)
    );
    registradores_intermediarios4: registrador_5
    PORT MAP (
      clock  => clock,
      clear => reset,
      en1   => s_en_letra4,
      en2   => s_en_letra4,
      D     => letra_jogada,
      Q     => s_jogada(19 downto 15)
    );
    registradores_intermediarios5: registrador_5
    PORT MAP (
      clock  => clock,
      clear => reset,
      en1   => s_en_letra5,
      en2   => s_en_letra5,
      D     => letra_jogada,
      Q     => s_jogada(24 downto 20)
    );
    
  -- reg_ultima_jogada : registrador_25
  -- PORT MAP(
  --   clock => clock,
  --   clear => clr_jogada,
  --   en1 => en_reg_jogada,
  --   en2 => en_reg_jogada,
  --   D => jogada,
  --   Q => s_jogada
  -- );

  letra_jogada_5 <= s_jogada(4 downto 0);
  letra_jogada_4 <= s_jogada(9 downto 5);
  letra_jogada_3 <= s_jogada(14 downto 10);
  letra_jogada_2 <= s_jogada(19 downto 15);
  letra_jogada_1 <= s_jogada(24 downto 20);

  vec_jogadas(0) <= letra_jogada_1;
  vec_jogadas(1) <= letra_jogada_1;
  vec_jogadas(2) <= letra_jogada_1;
  vec_jogadas(3) <= letra_jogada_1;
  vec_jogadas(4) <= letra_jogada_1;
  vec_jogadas(5) <= letra_jogada_2;
  vec_jogadas(6) <= letra_jogada_2;
  vec_jogadas(7) <= letra_jogada_2;
  vec_jogadas(8) <= letra_jogada_2;
  vec_jogadas(9) <= letra_jogada_2;
  vec_jogadas(10) <= letra_jogada_3;
  vec_jogadas(11) <= letra_jogada_3;
  vec_jogadas(12) <= letra_jogada_3;
  vec_jogadas(13) <= letra_jogada_3;
  vec_jogadas(14) <= letra_jogada_3;
  vec_jogadas(15) <= letra_jogada_4;
  vec_jogadas(16) <= letra_jogada_4;
  vec_jogadas(17) <= letra_jogada_4;
  vec_jogadas(18) <= letra_jogada_4;
  vec_jogadas(19) <= letra_jogada_4;
  vec_jogadas(20) <= letra_jogada_5;
  vec_jogadas(21) <= letra_jogada_5;
  vec_jogadas(22) <= letra_jogada_5;
  vec_jogadas(23) <= letra_jogada_5;
  vec_jogadas(24) <= letra_jogada_5;

  vec_senhas(0)  <=  s_senha(4 downto 0);    
  vec_senhas(1)  <=  s_senha(9 downto 5);   
  vec_senhas(2)  <=  s_senha(14 downto 10);  
  vec_senhas(3)  <=  s_senha(19 downto 15);  
  vec_senhas(4)  <=  s_senha(24 downto 20);  
  vec_senhas(5)  <=  s_senha(4 downto 0);    
  vec_senhas(6)  <=  s_senha(9 downto 5);    
  vec_senhas(7)  <=  s_senha(14 downto 10);  
  vec_senhas(8)  <=  s_senha(19 downto 15);  
  vec_senhas(9)  <=  s_senha(24 downto 20);  
  vec_senhas(10) <=  s_senha(4 downto 0);    
  vec_senhas(11) <=  s_senha(9 downto 5);    
  vec_senhas(12) <=  s_senha(14 downto 10);  
  vec_senhas(13) <=  s_senha(19 downto 15);  
  vec_senhas(14) <=  s_senha(24 downto 20);  
  vec_senhas(15) <=  s_senha(4 downto 0);    
  vec_senhas(16) <=  s_senha(9 downto 5);    
  vec_senhas(17) <=  s_senha(14 downto 10);  
  vec_senhas(18) <=  s_senha(19 downto 15);  
  vec_senhas(19) <=  s_senha(24 downto 20);  
  vec_senhas(20) <=  s_senha(4 downto 0);    
  vec_senhas(21) <=  s_senha(9 downto 5);    
  vec_senhas(22) <=  s_senha(14 downto 10);  
  vec_senhas(23) <=  s_senha(19 downto 15);  
  vec_senhas(24) <=  s_senha(24 downto 20);  

  --memoria : ram_16x25  -- usar para Quartus
  memoria : entity work.ram_16x25(ram_modelsim) -- usar para ModelSim
  PORT MAP(
    clk => clock,
    endereco => s_endereco,
    dado_entrada => vetor_zero,
    we => '1', -- we ativo baixo
    ce => '0',
    dado_saida => s_senha
  );

  conta_jogada: contador_6
  PORT MAP(
    clock => clock,
    clr   => reset_contagem,
    ld    => '0',
    ent   => '1',
    enp   => incrementa_contagem,
    D     => "000",
    Q     => s_contagem,
    rco   => fim_tentativas
  );

END estrutural;

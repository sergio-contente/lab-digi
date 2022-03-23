LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.MATH_REAL.ALL;

entity fluxo_dados is
  port (
  clock : in std_logic;
  reset : in std_logic;
  reset_timer : in std_logic;
	enable_timer : in std_logic;
	reset_contagem : in std_logic;
  ganhou : in std_logic;
  perdeu : in std_logic;
  pronto : in std_logic;
  fim_tentativas : out std_logic;
	tem_jogada : out std_logic;
	jogada_igual_senha : out std_logic;
	contagem_igual_tentativa : out std_logic;
  atualiza_resultado : in std_logic;
  incrementa_contagem : in std_logic;
  incrementa_partida : in std_logic;
  db_tem_jogada : out std_logic;
  db_contagem : out std_logic_vector (3 downto 0);
  db_senha : out std_logic_vector (3 downto 0);
  db_jogada : out std_logic_vector (3 downto 0);
  db_partida : out std_logic_vector (3 downto 0)
  );
 end entity;

ARCHITECTURE estrutural OF fluxo_dados IS

  SIGNAL s_endereco : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_sequencia : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL not_zeraE : STD_LOGIC;
  SIGNAL s_jogada : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL not_zeraS : STD_LOGIC;
  SIGNAL s_dado : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL not_registraR, not_registraM : STD_LOGIC;
  SIGNAL s_chaveacionada: std_logic;
  SIGNAL not_chaveacionada: std_logic;

  COMPONENT hexa7seg
    PORT (
      hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT registrador_173 IS
    PORT (
      clock : IN STD_LOGIC;
      clear : IN STD_LOGIC;
      en1 : IN STD_LOGIC;
      en2 : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
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

  COMPONENT comparador_85
    PORT (
      i_A3 : IN STD_LOGIC;
      i_B3 : IN STD_LOGIC;
      i_A2 : IN STD_LOGIC;
      i_B2 : IN STD_LOGIC;
      i_A1 : IN STD_LOGIC;
      i_B1 : IN STD_LOGIC;
      i_A0 : IN STD_LOGIC;
      i_B0 : IN STD_LOGIC;
      i_AGTB : IN STD_LOGIC;
      i_ALTB : IN STD_LOGIC;
      i_AEQB : IN STD_LOGIC;
      o_AGTB : OUT STD_LOGIC;
      o_ALTB : OUT STD_LOGIC;
      o_AEQB : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT ram_16x4 IS
    PORT (
      clk : IN STD_LOGIC;
      endereco : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dado_entrada : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      we : IN STD_LOGIC;
      ce : IN STD_LOGIC;
      dado_saida : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT;

  component edge_detector is
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        sinal  : in  std_logic;
        pulso  : out std_logic
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
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic
    );
end component;

BEGIN

  not_zeraE <= NOT zeraE;
  not_zeraS <= NOT zeraS;
  not_registraR <= NOT registraR;
  not_registraM <= NOT escreveM;
  s_chaveacionada <= '1' when botoes(0) = '1' or botoes(1) = '1' or 
                    botoes(2) = '1' or botoes(3) = '1' else '0';
  not_chaveacionada <= not s_chaveacionada;
	
  db_sequencia <= s_sequencia;					
  db_jogada <= s_jogada;
  db_contagem <= s_endereco;
  db_tem_jogada <= s_chaveacionada;

  ContEnd : contador_163
  PORT MAP(
    clock => clock, 
    clr   => not_zeraE, 
    ld    =>  '1', 
    ent   => '1', 
    enp   => contaE, 
    D     => "0000", 
    Q     => s_endereco, 
    RCO   => fimE
  );

  ContSeq : contador_163
  PORT MAP(
    clock => clock, 
	  clr   => not_zeraS, 
	  ld    =>  '1', 
	  ent   => '1', 
	  enp   => contaS, 
	  D     => "0000", 
	  Q     => s_sequencia, 
	  RCO   => fimS
  );

  CompJog : comparador_85
  PORT MAP(
    i_A3 => s_sequencia(3),
    i_B3 => s_endereco(3),
    i_A2 => s_sequencia(2),
    i_B2 => s_endereco(2),
    i_A1 => s_sequencia(1),
    i_B1 => s_endereco(1),
    i_A0 => s_sequencia(0),
    i_B0 => s_endereco(0),
    i_AGTB => '1',
    i_ALTB => '0',
    i_AEQB => '1',
    o_AGTB => enderecoMenorOuIgualSequencia,
    o_ALTB => OPEN,
    o_AEQB => enderecoIgualSequencia
  );

  CompSeq : comparador_85
  PORT MAP(
    i_A3 => s_dado(3),
    i_B3 => s_jogada(3),
    i_A2 => s_dado(2),
    i_B2 => s_jogada(2),
    i_A1 => s_dado(1),
    i_B1 => s_jogada(1),
    i_A0 => s_dado(0),
    i_B0 => s_jogada(0),
    i_AGTB => '0',
    i_ALTB => '0',
    i_AEQB => '1',
    o_AGTB => OPEN,
    o_ALTB => OPEN,
    o_AEQB => chavesIgualMemoria
  );

  RegBotoes : registrador_173
  PORT MAP(
    clock => clock,
    clear => limpaR,
    en1 => not_registraR,
    en2 => not_registraR,
    D => botoes,
    Q => s_jogada
  );

  RegMem : registrador_173
  PORT MAP(
    clock => clock,
    clear => limpaM,
    en1 => not_registraM,
    en2 => not_registraM,
    D => s_dado,
    Q => db_memoria
  );
  memoria: ram_16x4  -- usar para Quartus
  --memoria: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
  PORT MAP(
    clk => clock,
    endereco => s_endereco,
    dado_entrada => s_jogada,
    we => '1', -- we ativo baixo
    ce => '0',
    dado_saida => s_dado
  );
  JGD: edge_detector
  PORT MAP(
    clock => clock,
    reset => not_chaveacionada,
    sinal => s_chaveacionada,
    pulso => jogada_feita
  );
  
  timer: contador_m
  PORT MAP(
		clock   => clock,
        zera_as => zeraTMR,
        zera_s  => '0',
        conta   => contaTMR,
        Q       => open,
        fim     => fimTMR,
        meio    => open
  );
END estrutural;

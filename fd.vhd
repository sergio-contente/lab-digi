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
  jogada:  in std_logic (24 downto 0);
  --ganhou : in std_logic;
  --perdeu : in std_logic;
  --pronto : in std_logic;
  fim_tentativas : out std_logic;
	jogada_igual_senha : out std_logic;
  --atualiza_resultado : in std_logic;
  incrementa_contagem : in std_logic;
  incrementa_partida : in std_logic;
  clr_jogada : in std_logic;
  en_reg_jogada : in std_logic;
  tempo_jogada : out unsigned;
  timeout : out std_logic;
  db_tem_jogada : out std_logic;
  db_contagem : out std_logic_vector (2 downto 0);
  db_senha : out std_logic_vector (4 downto 0);
  db_jogada : out std_logic_vector (4 downto 0);
  db_partida : out std_logic_vector (2 downto 0)
  );
 end entity;

ARCHITECTURE estrutural OF fluxo_dados IS

  type vector5 is array (natural range <>) of std_logic_vector(4 downto 0);

  signal vec_jogadas : vector5(24 downto 0);
  signal vec_senhas : vector5(24 downto 0);
  signal vec_saidas : std_logic_vector(24 downto 0);

  SIGNAL s_endereco : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_sequencia : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL not_zeraE : STD_LOGIC;
  SIGNAL s_contagem : STD_LOGIC_VECTOR (2 DOWNTO 0);
  SIGNAL s_jogada : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL not_zeraS : STD_LOGIC;
  SIGNAL s_dado : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL not_registraR, not_registraM : STD_LOGIC;
  SIGNAL s_chaveacionada: std_logic;
  SIGNAL not_chaveacionada: std_logic;

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

component comparador_igualdade is
  port (
    jogada_in : in std_logic_vector(4 downto 0);
    senha_in : in std_logic_vector(4 downto 0);
    o_AEQB : out std_logic
  );
end component;

BEGIN

  -- regs: for n in 25 downto 5 generate
  --   --n = 25
  --   comparadores: comparador_igualdade port map(
  --     i_A4   => s_dado(n-1)
  --     i_B4   => s_memoria(n-1)
  --     i_A3   => s_dado(n-2)
  --     i_B3   => s_memoria(n-2)
  --     i_A2   => s_dado(n-3)
  --     i_B2   => s_memoria(n-3)
  --     i_A1   => s_dado(n-4)
  --     i_B1   => s_memoria(n-4)
  --     i_A0   => s_dado(n-5)
  --     i_B0   => s_memoria(n-5)
  --     -- i_AEQB : in  std_logic;
  --     o_AEQB => igual(n/5)
  --   );
  -- end generate;
  
  regs: for i in 0 to 24 generate
    --n = 25
    comparadores: comparador_igualdade port map(
      jogada_in => vec_jogadas(i)
      senha_in => vec_senhas(i)
      -- i_AEQB : in  std_logic;
      o_AEQB => vec_saidas(i)
    );
  end generate;  

  -- not_zeraE <= NOT zeraE;
  -- not_zeraS <= NOT zeraS;
  -- not_registraR <= NOT registraR;
  -- not_registraM <= NOT escreveM;
  -- s_chaveacionada <= '1' when botoes(0) = '1' or botoes(1) = '1' or 
  --                   botoes(2) = '1' or botoes(3) = '1' else '0';
  -- not_chaveacionada <= not s_chaveacionada;
	
  db_sequencia <= s_sequencia;					
  db_jogada <= s_jogada;
  db_contagem <= s_contagem;
  db_tem_jogada <= s_chaveacionada;

  jogada_igual_senha <= '1' when "1111111111111111111111111",
                     <= '0' when others;

  conta_partidas : contador_163
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

  reg_ultima_jogada : registrador_25
  PORT MAP(
    clock => clock,
    clear => clr_jogada,
    en1 => en_reg_jogada,
    en2 => en_reg_jogada,
    D => jogada,
    Q => s_jogada
  );

  s_jogada(0 to 4) => vec_jogadas(0);
  s_jogada(0 to 4) => vec_jogadas(1);
  s_jogada(0 to 4) => vec_jogadas(2);
  s_jogada(0 to 4) => vec_jogadas(3);
  s_jogada(0 to 4) => vec_jogadas(4);
  s_jogada(5 to 9) => vec_jogadas(5);
  s_jogada(5 to 9) => vec_jogadas(6);
  s_jogada(5 to 9) => vec_jogadas(7);
  s_jogada(5 to 9) => vec_jogadas(8);
  s_jogada(5 to 9) => vec_jogadas(9);
  s_jogada(10 to 14) => vec_jogadas(10);
  s_jogada(10 to 14) => vec_jogadas(11);
  s_jogada(10 to 14) => vec_jogadas(12);
  s_jogada(10 to 14) => vec_jogadas(13);
  s_jogada(10 to 14) => vec_jogadas(14);
  s_jogada(15 to 19) => vec_jogadas(15);
  s_jogada(15 to 19) => vec_jogadas(16);
  s_jogada(15 to 19) => vec_jogadas(17);
  s_jogada(15 to 19) => vec_jogadas(18);
  s_jogada(15 to 19) => vec_jogadas(19);
  s_jogada(20 to 24) => vec_jogadas(20);
  s_jogada(20 to 24) => vec_jogadas(21);
  s_jogada(20 to 24) => vec_jogadas(22);
  s_jogada(20 to 24) => vec_jogadas(23);
  s_jogada(20 to 24) => vec_jogadas(24);

  s_senha(0 to 4) => vec_senhas(0);
  s_senha(5 to 9) => vec_senhas(1);
  s_senha(10 to 14) => vec_senhas(2);
  s_senha(15 to 19) => vec_senhas(3);
  s_senha(20 to 24) => vec_senhas(4);
  s_senha(0 to 4) => vec_senhas(5);
  s_senha(5 to 9) => vec_senhas(6);
  s_senha(10 to 14) => vec_senhas(7);
  s_senha(15 to 19) => vec_senhas(8);
  s_senha(20 to 24) => vec_senhas(9);
  s_senha(0 to 4) => vec_senhas(10);
  s_senha(5 to 9) => vec_senhas(11);
  s_senha(10 to 14) => vec_senhas(12);
  s_senha(15 to 19) => vec_senhas(13);
  s_senha(20 to 24) => vec_senhas(14);
  s_senha(0 to 4) => vec_senhas(15);
  s_senha(5 to 9) => vec_senhas(16);
  s_senha(10 to 14) => vec_senhas(17);
  s_senha(15 to 19) => vec_senhas(18);
  s_senha(20 to 24) => vec_senhas(19);
  s_senha(0 to 4) => vec_senhas(20);
  s_senha(5 to 9) => vec_senhas(21);
  s_senha(10 to 14) => vec_senhas(22);
  s_senha(15 to 19) => vec_senhas(23);
  s_senha(20 to 24) => vec_senhas(24);
  
  memoria: ram_16x25  -- usar para Quartus
  --memoria: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
  PORT MAP(
    clk => clock,
    endereco => s_endereco,
    dado_entrada => open,
    we => '1', -- we ativo baixo
    ce => '0',
    dado_saida => s_senha
  );
  
  timer: contador_m
  PORT MAP(
		clock   => clock,
    zera_as => reset_timer,
    zera_s  => '0',
    conta   => enable_timer,
    Q       => tempo_jogada,
    fim     => timeout,
    meio    => open
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

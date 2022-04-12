library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_16x40 is
   port (       
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(3 downto 0);
       dado_entrada : in  std_logic_vector(39 downto 0);
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(39 downto 0)
    );
end entity ram_16x40;

architecture ram_mif of ram_16x40 is
  type   arranjo_memoria is array(0 to 15) of std_logic_vector(39 downto 0);
  signal memoria : arranjo_memoria;
  
  -- Configuracao do Arquivo MIF
  attribute ram_init_file: string;
  attribute ram_init_file of memoria: signal is "ram_inicial.mif";
  
begin

  process(clk)
  begin
    if (clk = '1' and clk'event) then
          if ce = '0' then -- dado armazenado na subida de "we" com "ce=0"
           
              -- Detecta ativacao de we (ativo baixo)
              if (we = '0') 
                  then memoria(to_integer(unsigned(endereco))) <= dado_entrada;
              end if;
            
          end if;
      end if;
  end process;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));
  
end architecture ram_mif;


-- Dados iniciais (para simulacao com Modelsim) 
architecture ram_modelsim of ram_16x40 is
  type   arranjo_memoria is array(0 to 15) of std_logic_vector(39 downto 0);
  signal memoria : arranjo_memoria := (
                                        "0111101001111010011110100111101001111010", --abcde
                                        "0111101001111010011110100111101001111010", --abcde
                                        "0111101001111010011110100111101001111010", --abcde
                                        "0111101001111010011110100111101001111010", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001", --abcde
                                        "0110000101100001011000010110000101100001" ); --abcde

begin

  process(clk)
  begin
    if (clk = '1' and clk'event) then
          if ce = '0' then -- dado armazenado na subida de "we" com "ce=0"
           
              -- Detecta ativacao de we (ativo baixo)
              if (we = '0') 
                  then memoria(to_integer(unsigned(endereco))) <= dado_entrada;
              end if;
            
          end if;
      end if;
  end process;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));

end architecture ram_modelsim;

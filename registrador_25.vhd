-----------------------------------------------------------------------------------------------------------------------
-- Arquivo   : registrador_igualdade.vhd
-- Projeto   : Jogo da Senha
-----------------------------------------------------------------------------------------------------------------------

-- Descricao : registrador de 25 bits 
--             retorna o valor de input se estiver habilitado
-----------------------------------------------------------------------------------------------------------------------
-- Revisoes  :
--     Data       | Versao  |                          Autores                                         |    Descricao
--     23/03/2022 |  0.1    | Jonas Gomes de Morais, Luis Enrique del Llano, Sergio Magalhaes Contente |     criacao
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity registrador_25 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (24 downto 0);
        Q     : out std_logic_vector (24 downto 0)
   );
end entity registrador_25;

architecture comportamental of registrador_25 is
begin
  
    process (clock, clear)
    begin
        if clear='1' then
            Q <= others => '0';  
        elsif clock'event and clock='1' then
            if en1='0' and en2='0'then 
                Q <= D;
            end if;
        end if;
    end process;

end architecture comportamental;

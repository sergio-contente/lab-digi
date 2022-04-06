-----------------------------------------------------------------------------------------------------------------------
-- Arquivo   : comparador_igualdade.vhd
-- Projeto   : Jogo da Senha
-----------------------------------------------------------------------------------------------------------------------

-- Descricao : comparador binario de 5 bits 
--             retorna se os valores sao iguais ou nao
-----------------------------------------------------------------------------------------------------------------------
-- Revisoes  :
--     Data       | Versao  |                          Autores                                         |    Descricao
--     23/03/2022 |  0.1    | Jonas Gomes de Morais, Luis Enrique del Llano, Sergio Magalhaes Contente |     criacao
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity comparador_igualdade is
  port (
    jogada_in : in std_logic_vector(4 downto 0);
    senha_in : in std_logic_vector(4 downto 0);
    o_AEQB : out std_logic
  );
end entity comparador_igualdade;

architecture dataflow of comparador_igualdade is
  signal aeqb : std_logic;
begin
  aeqb <= not((jogada_in(4) xor senha_in(4)) or ((jogada_in(3) xor senha_in(3)) or ((jogada_in(2) xor senha_in(2)) or ((jogada_in(1) xor senha_in(1)) or ((jogada_in(0) xor senha_in(0)));
  o_AEQB <= aeqb;-- and i_AEQB;
  
end architecture dataflow;

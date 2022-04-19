-----------------------------------------------------------------------------------------------------------------------

-- Arquivo   : hexa7seg.vhd
-- Projeto   : Jogo da Senha 
-----------------------------------------------------------------------------------------------------------------------
-- Descricao : Decodificador hexadecimal para 
--             display de 7 segmentos 
-- 
-- entrada: hexa - codigo binario de 4 bits hexadecimal
-- saida:   sseg - codigo de 7 bits para display de 7 segmentos
-----------------------------------------------------------------------------------------------------------------------
-- dica de uso: mapeamento para displays da placa DE0-CV
--              bit 6 mais significativo é o bit a esquerda
--              p.ex. sseg(6) -> HEX0[6] ou HEX06
-----------------------------------------------------------------------------------------------------------------------
-- Revisoes  :
--     Data       | Versao  |                          Autores                                         |    Descricao
--     23/03/2022 |  0.1    | Jonas Gomes de Morais, Luis Enrique del Llano, Sergio Magalhaes Contente |     criacao
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity alfabeto7seg is
    port (
        letra : in  std_logic_vector(4 downto 0);
        sseg   : out std_logic_vector(6 downto 0)
    );
end entity alfabeto7seg;

architecture comportamental of alfabeto7seg is
begin

  sseg <= "1011111" when letra="00001" else  -- a 
          "1111100" when letra="00010" else  -- b 
          "1011000" when letra="00011" else  -- c
          "1011110" when letra="00100" else  -- d
          "1111001" when letra="00101" else  -- e
          "1110001" when letra="00110" else  -- f
          "0111101" when letra="00110" else  -- g
          "1110100" when letra="00111" else  -- h
          "0110000" when letra="01000" else  -- i
          "0011110" when letra="01001" else  -- j
          "1110000" when letra="01010" else  -- k
          "0111000" when letra="01011" else  -- l
          "1110111" when letra="01100" else  -- m
          "1010100" when letra="01101" else  -- n
          "1011100" when letra="01110" else  -- o
          "1100111" when letra="01111" else  -- p
          "1110011" when letra="10000" else  -- q
          "0000101" when letra="10001" else  -- r
          "0010011" when letra="10010" else  -- s
          "0010011" when letra="10011" else  -- t
          "0011100" when letra="10100" else  -- u
          "0111110" when letra="10101" else  -- v
          "1111110" when letra="10111" else  -- w
          "0111111" when letra="10110" else  -- x
          "1101110" when letra="11000" else  -- y
          "1011011" when letra="11001" else  -- z
          "1110011" when letra="11010" else  -- 1A
          "1100011" when letra="11011" else  -- 1B
          "0100011" when letra="11100" else  -- 1C
          "1011101" when letra="11101" else  -- 1D
          "1101011" when letra="11110" else  -- 1E
          "1001001" when letra="11111" else  -- 1F
          "1111111";

end architecture comportamental;

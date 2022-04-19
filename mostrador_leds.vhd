library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mostrador_leds is
    port (
        clock   : in  std_logic;
        zera : in  std_logic;
        vec_saidas  : in  std_logic_vector(24 downto 0);
        enable   : in  std_logic;
        endereco  : in std_logic_vector(2 downto 0);
        leds    : out std_logic_vector(4 downto 0)
    );
end entity mostrador_leds;
architecture comportamental of mostrador_leds is
	BEGIN

	


	leds(2 downto 0) <= endereco;

	leds(4 downto 3) <= "10" when vec_saidas(4 downto 0) = "00000" and endereco = "000" and enable = '1' else
	"11" when vec_saidas(0) = '1' and endereco = "000" and enable = '1' else
	"01" when (vec_saidas(4 downto 0) /= "00000" and vec_saidas(0) /= '1') and endereco = "000" and enable = '1' else
	"00";
	leds(4 downto 3) <= "10" when vec_saidas(9 downto 5) = "00000" and endereco = "001" and enable = '1' else
	"11" when vec_saidas(6) = '1' and endereco = "001" and enable = '1' else
	"01" when (vec_saidas(9 downto 5) /= "00000" and vec_saidas(6) /= '1') and endereco = "001" and enable = '1';

	leds(4 downto 3) <= "10" when vec_saidas(14 downto 10) = "00000" and endereco = "010" and enable = '1' else
	"11" when vec_saidas(12) = '1'  and endereco = "010" and enable = '1' else
	"01" when (vec_saidas(14 downto 10) /= "00000" and vec_saidas(12) /= '1') and endereco = "010" and enable = '1';

	leds(4 downto 3) <= "10" when vec_saidas(19 downto 15) = "00000" and endereco = "011" and enable = '1' else
	"11" when vec_saidas(18) = '1'  and endereco = "011" and enable = '1' else
	"01" when (vec_saidas(19 downto 15) /= "00000" and vec_saidas(18) /= '1') and endereco = "011" and enable = '1';

	leds(4 downto 3) <= "10" when vec_saidas(24 downto 20) = "00000" and endereco = "100" and enable = '1' else
	"11" when vec_saidas(24) = '1' and endereco = "100" and enable = '1' else
	"01" when(vec_saidas(24 downto 20) /= "00000" and vec_saidas(24) /= '1') and endereco = "100" and enable = '1';
	
	-- 	IF endereco = "000" THEN
	-- 		IF vec_saidas(4 DOWNTO 0) = "00000" THEN
	-- 			leds(2 DOWNTO 0) <= "000";
	-- 			leds(4 DOWNTO 3) <= "10"; -- vermelho
	-- 		ELSIF vec_saidas(0) = '1' THEN
	-- 			leds(2 DOWNTO 0) <= "000";
	-- 			leds(4 DOWNTO 3) <= "11"; -- verde
	-- 		ELSE
	-- 			leds(2 DOWNTO 0) <= "000";
	-- 			leds(4 DOWNTO 3) <= "01"; -- amarelo
	-- 		END IF;
	-- 	ELSIF endereco = "001" THEN
	-- 		IF vec_saidas(9 DOWNTO 5) = "00000" THEN
	-- 			leds(2 DOWNTO 0) <= "001";
	-- 			leds(4 DOWNTO 3) <= "10"; -- vermelho
	-- 		ELSIF vec_saidas(6) = '1' THEN
	-- 			leds(2 DOWNTO 0) <= "001";
	-- 			leds(4 DOWNTO 3) <= "11"; -- verde
	-- 		ELSE
	-- 			leds(2 DOWNTO 0) <= "001";
	-- 			leds(4 DOWNTO 3) <= "01"; -- amarelo
	-- 		END IF;
	-- 	ELSIF endereco = "010" THEN
	-- 		IF vec_saidas(14 DOWNTO 10) = "00000" THEN
	-- 			leds(2 DOWNTO 0) <= "010";
	-- 			leds(4 DOWNTO 3) <= "10"; -- vermelho
	-- 		ELSIF vec_saidas(12) = '1' THEN
	-- 			leds(2 DOWNTO 0) <= "010";
	-- 			leds(4 DOWNTO 3) <= "11"; -- verde
	-- 		ELSE
	-- 			leds(2 DOWNTO 0) <= "010";
	-- 			leds(4 DOWNTO 3) <= "01"; -- amarelo
	-- 		END IF;
	-- 	ELSIF endereco = "011" THEN
	-- 		IF vec_saidas(19 DOWNTO 15) = "00000" THEN
	-- 			leds(2 DOWNTO 0) <= "011";
	-- 			leds(4 DOWNTO 3) <= "10"; -- vermelho
	-- 		ELSIF vec_saidas(18) = '1' THEN
	-- 			leds(2 DOWNTO 0) <= "011";
	-- 			leds(4 DOWNTO 3) <= "11"; -- verde
	-- 		ELSE
	-- 			leds(2 DOWNTO 0) <= "011";
	-- 			leds(4 DOWNTO 3) <= "01"; -- amarelo
	-- 		END IF;
	-- 	ELSIF endereco = "100" THEN
	-- 		IF vec_saidas(24 DOWNTO 20) = "00000" THEN
	-- 			leds(2 DOWNTO 0) <= "100";
	-- 			leds(4 DOWNTO 3) <= "10"; -- vermelho
	-- 		ELSIF vec_saidas(24) = '1' THEN
	-- 			leds(2 DOWNTO 0) <= "100";
	-- 			leds(4 DOWNTO 3) <= "11"; -- verde
	-- 		ELSE
	-- 			leds(2 DOWNTO 0) <= "100";
	-- 			leds(4 DOWNTO 3) <= "01"; -- amarelo
	-- 		END IF;
	-- 	END IF;
	-- END IF;
end architecture comportamental;

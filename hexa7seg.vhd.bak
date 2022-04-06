library ieee;
use ieee.std_logic_1164.all;

entity hexa7seg is
    port (
        hexa   : in  std_logic_vector(3 downto 0);
        sseg   : out std_logic_vector(6 downto 0)
    );
end entity hexa7seg;

architecture comportamental of hexa7seg is
begin

  sseg <= "1000000" when estado="0000" else  -- 0
          "1111001" when estado="0001" else  -- 1
          "0100100" when estado="0010" else  -- 2
          "0110000" when estado="0011" else  -- 3
          "0011001" when estado="0100" else  -- 4
          "0010010" when estado="0101" else  -- 5
          "0000010" when estado="0110" else  -- 6
          "1111000" when estado="0111" else  -- 7
          "0000000" when estado="1000" else  -- 8
          "0010000" when estado="1001" else  -- 9
          "0001000" when estado="1010" else  -- A
          "0000011" when estado="1011" else  -- B
          "1000110" when estado="1100" else  -- C
          "0100001" when estado="1101" else  -- D
          "0000110" when estado="1110" else  -- E
          "0001110" when estado="1111" else  -- F
          "1111111";

end architecture comportamental;

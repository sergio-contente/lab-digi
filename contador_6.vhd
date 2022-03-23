library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_6 is
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
end contador_6;

architecture comportamental of contador_6 is
    signal IQ: integer range 0 to 5;
begin
  
    -- contagem
    process (clock)
    begin
    
        if clock'event and clock='1' then
            if clr='0' then   IQ <= 0; 
            elsif ld='0' then IQ <= to_integer(unsigned(D));
            elsif ent='1' and enp='1' then
                if IQ=5 then IQ <= 0; 
                else          IQ <= IQ + 1; 
                end if;
            else              IQ <= IQ;
            end if;
        end if;

    end process;

    -- saida rco
    rco <= '1' when IQ=5 and ent='1' else
           '0';

    -- saida Q
    Q <= std_logic_vector(to_unsigned(IQ, Q'length));

end comportamental;

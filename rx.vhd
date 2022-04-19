-- VHDL do Receptor Serial modo 8N2

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx is
	generic (baudrate     : integer := 9600);
	port (
		clock		   : in  std_logic;													
		reset		   : in  std_logic;								
		sin			: in  std_logic;							
		dado			: out std_logic_vector(7 downto 0);
		fim			: out std_logic									
	);
end rx;

architecture exemplo of rx is 

	component hexa7seg is
    port (
        hexa   : in  std_logic_vector(3 downto 0);
        sseg   : out std_logic_vector(6 downto 0)
    );
	end component;

	signal clockdiv  : std_logic;
	signal IQ		  : unsigned(25 downto 0);
	signal IQ2		  : unsigned(3 downto 0);
	signal buff		  : std_logic_vector(7 downto 0);
	signal tick      : std_logic;
	signal encount	  : std_logic;
	signal resetcount: std_logic;
	
	type tipo_estado is (inicial, sb, d0, d1, d2, d3, d4, d5, d6, d7, final);
	signal estado   : tipo_estado;

begin 
	
	-- ===========================
	-- Divisor de clock
	-- ===========================
	process(clock, reset, IQ, clockdiv)
	begin
		if reset = '1' then
			IQ <= (others => '0');
		elsif clock'event and clock = '1' then
			if IQ = 50000000/(baudrate*16*2) then
				clockdiv <= not(clockdiv);
				IQ <= (others => '0');
			else
				IQ <= IQ + 1;
			end if;
		end if;
	end process;

	-- ===========================
	-- Superamostragem 16x
	-- ===========================		
	process(clockdiv, resetcount, encount)
	begin
		if resetcount = '1' then
			IQ2	  <= (others => '0');
		elsif clockdiv'event and clockdiv = '1' and encount = '1' then
			IQ2 <= IQ2 + 1;
		end if;
	end process;
	
	tick <= '1' when IQ2 = 8 else '0';
	
	-- ===========================
	-- Maquina de Estados do Transmissor
	-- ===========================
	process(clockdiv, reset, sin, tick, estado)
	begin
		if reset = '1' then
			estado <= inicial;
			
		elsif clockdiv'event and clockdiv = '1' then
			case estado is
				
				when inicial => if 	  sin = '0' then estado   <= sb;
									 else						  estado   <= inicial;
									 end if;
				
				when sb      => if 	 tick = '1' then estado   <= d0;
									 else						  estado   <= sb;
									 end if;
									 buff <= "00000000";
									 
				when d0      => if 	 tick = '1' then estado   <= d1;
				                                      buff(0)  <= sin;
									 else						  estado   <= d0;
									 end if;
									 
				when d1      => if 	 tick = '1' then estado   <= d2;
				                                      buff(1)  <= sin;
									 else						  estado   <= d1;
									 end if;
									 
				when d2      => if 	 tick = '1' then estado   <= d3;
				                                      buff(2)  <= sin;
									 else						  estado   <= d2;
									 end if;
									 
				when d3      => if 	 tick = '1' then estado   <= d4;
				                                      buff(3)  <= sin;
									 else						  estado   <= d3;
									 end if;
									 
				when d4      => if 	 tick = '1' then estado   <= d5;
				                                      buff(4)  <= sin;
									 else						  estado   <= d4;
									 end if;
									 
				when d5      => if 	 tick = '1' then estado   <= d6;
				                                      buff(5)  <= sin;
									 else						  estado   <= d5;
									 end if;
									 
				when d6      => if 	 tick = '1' then estado   <= d7;
				                                      buff(6)  <= sin;
									 else						  estado   <= d6;
									 end if;
									 
				when d7      => if 	 tick = '1' then estado   <= final;
				                                      buff(7)  <= sin;
									 else						  estado   <= d7;
									 end if;
				
				when final   => if 	 tick = '1' then estado   <= inicial;
									 else						  estado   <= final;
									 end if;		
									 
				when others => estado <= inicial;
			end case;
		end if;
	end process;
	
	with estado select encount <=
		'0' when inicial,
		'1' when others;

	with estado select resetcount <=
		'1' when inicial,
		'0' when others;
		
	-- ===========================
	-- Logica de saida
	-- ===========================
	with estado select fim <=
		'1' when final,
		'0' when others;
		
	dado <= buff;
end exemplo;

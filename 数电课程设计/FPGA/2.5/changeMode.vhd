library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity changeMode is
	port( button : in std_logic;
		Rflash, Yflash : out std_logic );
end entity;

architecture beh of changeMode is
signal change : integer range 0 to 3 := 0;

begin
	process(button, change)
	variable Rresult, Yresult, RSTresult : std_logic;
	variable cnt : integer range 0 to 100;
	begin
		--if( rising_edge(CLK1k) ) then
		if( button = '0' ) then
			cnt := cnt + 1;
			if( cnt > 20 ) then
				if( button = '1' ) then
					cnt := 0;
					change <= change + 1;
					if( change = 1 ) then
						Rresult := '0';
						Yresult := '1';
					elsif( change = 2 ) then
						Rresult := '1';
						Yresult := '0';
					elsif( change = 3 ) then
						Rresult := '1';
						Yresult := '1';
						change <= 0;
					end if;
				end if;
			end if;
		end if;
		--end if;
		Rflash <= Rresult;
		Yflash <= Yresult;
	end process;
end architecture;
						

 library ieee;
 use ieee.std_logic_1164.all;
 use ieee.std_logic_unsigned.all;
 
 entity div is
	port( CLK : in std_logic;
		  Q   : out std_logic);
end;

architecture bhv of div is
signal tempQ : std_logic;
signal num : integer range 0 to 100;
begin
	process(CLK)
	begin
		if( rising_edge(CLK) ) then
			num <= num + 1;
		end if;
		if( num < 30 ) then
			tempQ <= '0';
		else
			tempQ <= '1';
		end if;
		if( num > 60 ) then
			num <= 0;
		end if;
	end process;
	Q <= tempQ;
end architecture;
 library ieee;
 use ieee.std_logic_1164.all;
 use ieee.std_logic_unsigned.all;
 
 entity div is
	generic( n : integer := 1000);
	port( CLK : in std_logic;
		  Q   : out std_logic );
end;

architecture bhv of div is
signal tempQ : std_logic;
begin
	process(CLK)
	variable num : integer range 0 to n;
	begin
		if( rising_edge(CLK) ) then
			 if( num < n ) then
				num := num + 1;
			else 
				num := 0;
			end if;
			if( num <= n/2 ) then
				tempQ <= '0';
			else
				tempQ <= '1';
			end if;
		end if;
	end process;
	
	Q <= tempQ;
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity countdown is
	generic( t : integer := 1);
	port( CLK : in std_logic;
		stateQ : in std_logic_vector(1 downto 0);
		nsNum, ewNum : out std_logic_vector(6 downto 0) );
end entity;

architecture beh of countdown is
signal tempNStime : integer range 0 to 100; 
signal tempEWtime : integer range 0 to 100;
begin
	
	process(CLK)
	variable maxNStime, maxEWtime : integer range 0 to 100;
	begin
		if( rising_edge(CLK) ) then 
			if( stateQ = "00" ) then
				maxNStime := 5*t;
				maxEWtime := (5+1)*t;
			elsif( stateQ = "01" ) then
				maxNStime := 1*t;
			elsif( stateQ = "10" ) then
				maxNStime := (5+1)*t;
				maxEWtime := 5*t;
			elsif( stateQ = "11" ) then
				maxEWtime := 1*t;
			end if;
			tempNStime <= tempNStime + 1;
			tempEWtime <= tempEWtime + 1;
			if( tempNStime = maxNStime-1 ) then 
				tempNStime <= 0;
			end if;
			if( tempEWtime = maxEWtime-1 ) then
				tempEWtime <= 0;
			end if;
		end if;
		nsNum <= conv_std_logic_vector(tempNStime, 7);
		ewNum <= conv_std_logic_vector(tempEWtime, 7);
	end process;
end architecture;
			
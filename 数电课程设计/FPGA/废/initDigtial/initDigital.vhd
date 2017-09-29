library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity initDigital is
	generic( t : integer := 1);
	port( stateQ : in std_logic_vector(1 downto 0);
		 nsTime, ewTime : out std_logic_vector(6 downto 0) );
end entity;

architecture beh of initDigital is
begin
	process(stateQ)
	--variable tempState : std_logic_vector(1 downto 0) := stateQ;
	variable tempNStime, tempEWtime : integer range 0 to 100;
	begin
		if( stateQ = "00" ) then
			tempNStime := 5*t;
			tempEWtime := (5+1)*t;
		elsif( stateQ = "01" ) then
			tempNStime := 1*t;
		elsif( stateQ = "10" ) then
			tempNStime := (5+1)*t;
			tempEWtime := 5*t;
		elsif( stateQ = "11" ) then
			tempEWtime := 1*t;
		end if;
		nsTime <= conv_std_logic_vector(tempNStime, 7);
		ewTime <= conv_std_logic_vector(tempEWtime, 7);
	end process;
end architecture;

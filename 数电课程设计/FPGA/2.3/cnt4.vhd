library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cnt4 is
	port(	CLK : in std_logic;
		Q : out std_logic_vector(1 downto 0) );
end entity;

architecture beh of cnt4 is
signal tempQ : std_logic_vector(1 downto 0);
begin
	process(CLK)
	begin
		if( rising_edge(CLK) ) then
			tempQ <= tempQ + 1;
		end if;
	end process;
	Q <= tempQ;
end architecture;

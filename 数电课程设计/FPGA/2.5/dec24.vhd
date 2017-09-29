library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dec24 is
	port(	A : in std_logic_vector(1 downto 0);
		Y : out std_logic_vector(3 downto 0) );
end entity;

architecture beh of dec24 is
begin
	with A select
		Y <= "1110" when "00",
			"1101" when "01",
			"1011" when "10",
			"0111" when "11",
			"1111" when others;
end architecture;

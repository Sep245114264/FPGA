library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux41 is
	port(	D3, D2, D1, D0 : in std_logic_vector(3 downto 0);
		A : in std_logic_vector(1 downto 0);
		Y : out std_logic_vector(3 downto 0) );
end entity;

architecture beh of mux41 is
begin
	Y <= D0 when A = "00" else
		D1 when A = "01" else
		D2 when A = "10" else
		D3 when A = "11" else
		"0000";
end architecture;

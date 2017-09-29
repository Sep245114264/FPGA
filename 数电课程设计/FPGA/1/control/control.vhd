library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity control is
	generic( t : integer := 3;
		    s0 : integer := 0;
		    s1 : integer := 1;
		    s2 : integer := 2;
		    s3 : integer := 3;
		    s4 : integer := 4;	--双向红灯闪烁
		    s5 : integer := 5);	--黄闪	
	port(	CLK : in std_logic;
		RST : in std_logic;
		Rflash, Yflash : in std_logic;
		NSR, NSY, NSG, EWR, EWY, EWG : out std_logic;
		NSunit, EWunit, NSdecade, EWdecade : out std_logic_vector(3 downto 0)
		--NS, EW : out std_logic_vector(6 downto 0)
		);
end entity;

architecture beh of control is
signal state : integer range 0 to 5;
signal NStime : integer range 0 to 100;
signal EWtime : integer range 0 to 100;
begin
	process(CLK, RST, state, Rflash, Yflash)
	variable light : std_logic_vector(5 downto 0);
	begin
		if( RST = '1' ) then
			state <= s0;
			light := "000000";
			NStime <= 5*t-1;
			EWtime <= (5+1)*t-1;
		elsif( Rflash = '1' ) then
			state <= s4;
			light := "000000";
		elsif( Yflash = '1' ) then
			state <= s5;
			light := "000000";
		elsif( rising_edge(CLK) ) then
			if( state = s0 ) then
				light := "001100";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( NStime = 0 ) then
					state <= s1;
					NStime <= 1*t-1;
					EWtime <= 1*t-1;
					light := "010100";
				end if;
			elsif( state = s1 ) then 
				light := "010100";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( NStime = 0 ) then
					state <= s2;
					NStime <= (5+1)*t-1;
					EWtime <= 5*t-1;
					light := "100001";
				end if;
			elsif( state = s2 ) then
				light := "100001";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( EWtime = 0 ) then 
					state <= s3;
					NStime <= 1*t-1;
					EWtime <= 1*t-1;
					light := "100010";
				end if;
			elsif( state = s3 ) then
				light := "100010";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( EWtime = 0 ) then
					state <= s0;
					NStime <= 5*t-1;
					EWtime <= (5+1)*t-1;
					light := "001100";
				end if;
			elsif( state = s4 ) then
				light := "000000";
				NStime <= 88;
				EWtime <= 88;
			elsif( state = s5 ) then
				light := "010010";
				NStime <= 0;
				EWtime <= 0;
			end if;
			--NS <= conv_std_logic_vector(NStime, 7);
			--EW <= conv_std_logic_vector(EWtime, 7);
			--tempNum := NStime mod 10;
			NSunit <= conv_std_logic_vector(NStime mod 10, 4);
			--tempNum := NStime / 10;
			NSdecade <= conv_std_logic_vector(NStime / 10, 4);
			--tempNum := EWtime mod 10;
			EWunit <= conv_std_logic_vector(EWtime mod 10, 4);
			--tempNum := EWtime / 10;
			EWdecade <= conv_std_logic_vector(EWtime / 10, 4);
		end if;
		NSR <= light(5);
		NSY <= light(4);
		NSG <= light(3);
		EWR <= light(2);
		EWY <= light(1);
		EWG <= light(0);
		if( state = s4 ) then
			NSR <= CLK;
			EWR <= CLK;
		elsif( state = s5 ) then
			NSY <= CLK;
			EWY <= CLK;
		else
			if( light(4) = '1' )	then
				NSY <= CLK;
			end if;
			if( light(1) = '1' ) then
				EWY <= CLK;
			end if;
		end if;
	end process;
	
end architecture;
			

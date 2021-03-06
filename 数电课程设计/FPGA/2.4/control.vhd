library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;		--类型转换

entity control is
	generic( t : integer := 3;
		    s0 : integer := 0;
		    s1 : integer := 1;
		    s2 : integer := 2;
		    s3 : integer := 3;
		    s4 : integer := 4;	--双向红灯闪烁
		    s5 : integer := 5;	--黄闪	
		    s6 : integer := 6);	--流水灯+30#计数器
	port(	CLK : in std_logic;
		RST : in std_logic;
		Rflash, Yflash, RunLight: in std_logic;
		NSR, NSY, NSG, EWR, EWY, EWG : out std_logic;
		NSunit, EWunit, NSdecade, EWdecade : out std_logic_vector(3 downto 0)
		);
end entity;

architecture beh of control is
signal state : integer range 0 to 6;
signal NStime : integer range 0 to 100;
signal EWtime : integer range 0 to 100;
signal count : integer range 0 to 100;
begin
	process(CLK, RST, state, Rflash, Yflash, RunLight, NStime, EWtime)
	variable light : std_logic_vector(5 downto 0);
	begin
		if( RST = '0' ) then
			state <= s0;
			light := "001100";
			NStime <= 5*t-1;
			EWtime <= (5+1)*t-1;
		elsif( Rflash = '0' ) then
			state <= s4;
			light := "000000";
			NStime <= 88;
			EWtime <= 88;
		elsif( Yflash = '0' ) then
			--state <= s5;
			--light := "000000";
			--NStime <= 88;
			--EWtime <= 88;
		elsif( RunLight = '0' ) then
			state <= s6;
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
			end if;
		end if;
		NSunit <= conv_std_logic_vector(NStime mod 10, 4);
		--NSunit <= "0111";
		NSdecade <= conv_std_logic_vector(NStime / 10, 4);
		--NSdecade <= "1000";
		EWunit <= conv_std_logic_vector(EWtime mod 10, 4);
		--EWunit <= "0111";
		EWdecade <= conv_std_logic_vector(EWtime / 10, 4);
		--EWdecade <= "0110";
		NSR <= light(5);
		NSY <= light(4);
		NSG <= light(3);
		EWR <= light(2);
		EWY <= light(1);
		EWG <= light(0);
		if( state = s4 ) then				--红闪
			NSR <= CLK;
			EWR <= CLK;
		elsif( state = s5 ) then			--黄闪
			NSY <= CLK;
			EWY <= CLK;
		else							--黄灯闪烁
			if( light(4) = '1' )	then
				NSY <= CLK;
			end if;
			if( light(1) = '1' ) then
				EWY <= CLK;
			end if;
		end if;
	end process;
	
end architecture;
			

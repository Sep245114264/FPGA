library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control is
	generic( s0 : integer := 0;
		    s1 : integer := 1;
		    s2 : integer := 2;
		    s3 : integer := 3;
		    s4 : integer := 4;	--双向红灯闪烁
		    s5 : integer := 5;	--黄闪
		    s6 : integer := 6 );	--流水灯
	port(	CLK : in std_logic;
		RST : in std_logic;
		flash: in std_logic;
		NSR, NSY, NSG, EWR, EWY, EWG : out std_logic;
		NSunit, EWunit, NSdecade, EWdecade : out std_logic_vector(3 downto 0)
		);
end entity;

architecture beh of control is
signal state : integer range 0 to 6;
signal NStime, EWtime : std_logic_vector(7 downto 0);
signal mode : std_logic_vector(2 downto 0) := "100";
signal temp : std_logic;
signal key1 : std_logic;
signal cntLight : integer range 0 to 11;
begin
	process(CLK, RST, state, NStime, EWtime, flash, key1)
	variable light : std_logic_vector(5 downto 0);
	variable cnt : integer range 0 to 100;
	begin
		if( RST = '0' ) then			--初始状态 交通灯状态
			state <= s0;
			light := "001100";
			NStime <= "00100001";		--21
			EWtime <= "00100100";		--24
			mode <= "100";
		elsif( rising_edge(CLK) ) then
		--**********松手检测 闪烁状态切换*************
			if( flash = '0' ) then
				cnt := cnt + 1;
				if( cnt = 2 ) then				--长按1s，切换状态
					key1 <= '1';
					cnt := 0;
					if( mode(2) = '1' ) then
						state <= s4;
					elsif( mode(1) = '1' ) then
						state <= s5;
					elsif( mode(0) = '1' ) then
						state <= s6;
					end if;
				end if;
			elsif( flash = '1' ) then					--未达1s时松手，重新计时
				cnt := 0;
			end if;
			if( key1 = '1' ) then
				if( flash = '1' ) then
					key1 <= '0';
					cnt := 0;
					mode <= mode(1 downto 0) & mode(2);	--循环左移1位
				end if;
			end if;
		--************************************************
		
		--****************路口状态切换********************
			if( state = s0 ) then
				light := "001100";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( NStime(3 downto 0) = "0000" ) then
					if( NStime(7 downto 4) /= "0000" ) then
						NStime(7 downto 4) <= NStime(7 downto 4) - 1;
					end if;
					NStime(3 downto 0) <= "1001";		--9
				end if;
				if( EWtime(3 downto 0) = "0000" ) then
					if( EWtime(7 downto 4) /= "0000" ) then
						EWtime(7 downto 4) <= EWtime(7 downto 4) - 1;
					end if;
					EWtime(3 downto 0) <= "1001";		--9
				end if;
				if( NStime = 0 ) then
					state <= s1;
					NStime <= "00000010";		--2
					EWtime <= "00000010";		--2
					light := "010100";
				end if;
			elsif( state = s1 ) then 
				light := "010100";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( NStime = 0 ) then
					state <= s2;
					NStime <= "00100100";		--24
					EWtime <= "00100001";		--21
					light := "100001";
				end if;
			elsif( state = s2 ) then
				light := "100001";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( NStime(3 downto 0) = "0000" ) then
					if( NStime(7 downto 4) /= "0000" ) then
						NStime(7 downto 4) <= NStime(7 downto 4) - 1;
					end if;
					NStime(3 downto 0) <= "1001";
				end if;
				if( EWtime(3 downto 0) = "0000" ) then
					if( EWtime(7 downto 4) /= "0000" ) then
						EWtime(7 downto 4) <= EWtime(7 downto 4) - 1;
					end if;
					EWtime(3 downto 0) <= "1001";
				end if;
				if( EWtime = 0 ) then 
					state <= s3;
					NStime <= "00000010";		--2
					EWtime <= "00000010";		--2
					light := "100010";
				end if;
			elsif( state = s3 ) then
				light := "100010";
				NStime <= NStime - 1;
				EWtime <= EWtime - 1;
				if( EWtime = 0 ) then
					state <= s0;
					NStime <= "00100001";		--21
					EWtime <= "00100100";		--24
					light := "001100";
				end if;
			elsif( state = s6 ) then
				cntLight <= cntLight + 1;
				case cntLight is
					when 0 => light := "100000";
					when 1 => light := "010000";
					when 2 => light := "001000";
					when 3 => light := "000100";
					when 4 => light := "000010";
					when 5 => light := "000001";
					when 6 => light := "000010";
					when 7 => light := "000100";
					when 8 => light := "001000";
					when 9 => light := "010000";
					when others => light := "000000";
				end case;
				if( cntLight = 9 )	then
					cntLight <= 0;
				end if;
			end if;
		--**************************************************
		end if;
		NSR <= light(5);
		NSY <= light(4);
		NSG <= light(3);
		EWR <= light(2);
		EWY <= light(1);
		EWG <= light(0);
		if( state = s4 ) then				--红闪状态
			NSR <= CLK;
			NSY <= '0';
			NSG <= '0';
			EWR <= CLK;
			EWY <= '0';
			EWG <= '0';
			NStime <= "10001000";
			EWtime <= "10001000";
		elsif( state = s5 ) then			--黄闪状态
			NSR <= '0';
			NSY <= CLK;
			NSG <= '0';
			EWR <= '0';
			EWY <= CLK;
			EWG <= '0';
			NStime <= "10001000";
			EWtime <= "10001000";
		elsif( state /= s6 ) then							--黄灯闪烁 交通灯状态
			if( light(4) = '1' )	then
				NSY <= CLK;
			end if;
			if( light(1) = '1' ) then
				EWY <= CLK;
			end if;
		end if;
		NSunit <= NStime(3 downto 0);
		NSdecade <= NStime(7 downto 4);
		EWunit <= EWtime(3 downto 0);
		EWdecade <= EWtime(7 downto 4);
	end process;
	
end architecture;

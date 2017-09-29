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
		    s6 : integer := 6;	--流水灯
		    NSmaxDecade : std_logic_vector(3 downto 0) := "0001";		--1
		    NSmaxUnit : std_logic_vector(3 downto 0) := "0110";		--6
		    EWmaxDecade : std_logic_vector(3 downto 0) := "0010";		--2
		    EWmaxUnit : std_logic_vector(3 downto 0) := "0000";		--0
			warningTime : std_logic_vector(3 downto 0) := "0011"		--3
			);
	port(	CLK : in std_logic;
		RST : in std_logic;
		flash: in std_logic;
		NSR, NSY, NSG, EWR, EWY, EWG : out std_logic;
		NSunit, EWunit, NSdecade, EWdecade : out std_logic_vector(3 downto 0)
		);
end entity;

architecture beh of control is
signal state : integer range 0 to 6;
signal NStimeUnit, EWtimeUnit, NStimeDecade, EWtimeDecade : std_logic_vector(3 downto 0);
signal mode : std_logic_vector(2 downto 0) := "100";
signal key1 : std_logic;
signal cntLight : integer range 0 to 11;
begin
	process(CLK, RST, state, NStimeUnit, EWtimeUnit, NStimeDecade, EWtimeDecade, flash, key1)
	variable light : std_logic_vector(5 downto 0);
	variable cnt : integer range 0 to 100;
	begin
		if( RST = '0' ) then			--初始状态 交通灯状态
			state <= s0;
			light := "001100";
			NStimeDecade <= NSmaxDecade;
			NStimeUnit <= NSmaxUnit;
			EWtimeDecade <= EWmaxDecade;
			EWtimeUnit <= EWmaxUnit;
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
				NStimeUnit <= NStimeUnit - 1;
				if( NStimeUnit = 0 ) then 
					if( NStimeDecade /= 0 ) then
						NStimeDecade <= NStimeDecade - 1;
					end if;
					NStimeUnit <= "1001";
				end if;
				EWtimeUnit <= EWtimeUnit - 1;
				if( EWtimeUnit = 0 ) then
					if( EWtimeDecade /= 0 ) then
						EWtimeDecade <= EWtimeDecade - 1;
					end if;
					EWtimeUnit <= "1001";
				end if;
		
				if( NStimeUnit = 0 and NStimeDecade = 0 ) then
					state <= s1;
					NStimeDecade <= "0000";
					NStimeUnit <= warningTime;
					EWtimeDecade <= "0000";
					EWtimeUnit <= warningTime;
					light := "010100";
				end if;
			elsif( state = s1 ) then 
				light := "010100";
				NStimeUnit <= NStimeUnit - 1;
				EWtimeUnit <= EWtimeUnit - 1;
				if( NStimeUnit = 0 and NStimeDecade = 0 ) then
					state <= s2;
					NStimeDecade <= EWmaxDecade;
					NStimeUnit <= EWmaxUnit;
					EWtimeDecade <= NSmaxDecade;
					EWtimeUnit <= NSmaxUnit;
					light := "100001";
				end if;
			elsif( state = s2 ) then
				light := "100001";
				NStimeUnit <= NStimeUnit - 1;
				EWtimeUnit <= EWtimeUnit - 1;
				if( NStimeUnit = 0 ) then
					if( NStimeDecade /= 0 ) then
						NStimeDecade <= NStimeDecade - 1;
					end if;
					NStimeUnit <= "1001";
				end if;
				if( EWtimeUnit =0 ) then
					if( EWtimeDecade /= 0 ) then
						EWtimeDecade <= EWtimeDecade - 1;
					end if;
					EWtimeUnit <= "1001";
				end if;
				if( EWtimeUnit = 0 and EWtimeDecade = 0 ) then 
					state <= s3;
					NStimeDecade <= "0000";
					NStimeUnit <= warningTime;
					EWtimeDecade <= "0000";
					EWtimeUnit <= warningTime;
					light := "100010";
				end if;
			elsif( state = s3 ) then
				light := "100010";
				NStimeUnit <= NStimeUnit - 1;
				EWtimeUnit <= EWtimeUnit - 1;
				if( EWtimeUnit = 0 ) then
					state <= s0;
					NStimeDecade <= NSmaxDecade;
					NStimeUnit <= NSmaxUnit;
					EWtimeDecade <= EWmaxDecade;
					EWtimeUnit <= EWmaxUnit;
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
			NStimeDecade <= "1000";
			NStimeUnit <= "1000";
			EWtimeDecade <= "1000";
			EWtimeUnit <= "1000";
		elsif( state = s5 ) then			--黄闪状态
			NSR <= '0';
			NSY <= CLK;
			NSG <= '0';
			EWR <= '0';
			EWY <= CLK;
			EWG <= '0';
			NStimeDecade <= "1000";
			NStimeUnit <= "1000";
			EWtimeDecade <= "1000";
			EWtimeUnit <= "1000";
		elsif( state /= s6 ) then							--黄灯闪烁 交通灯状态
			if( light(4) = '1' )	then
				NSY <= CLK;
			end if;
			if( light(1) = '1' ) then
				EWY <= CLK;
			end if;
		end if;
		NSunit <= NStimeUnit;
		NSdecade <= NStimeDecade;
		EWunit <= EWtimeUnit;
		EWdecade <= EWtimeDecade;
	end process;
	
end architecture;

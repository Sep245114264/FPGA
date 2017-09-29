library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity state is
	generic( t : integer:= 1;
			 nsGewR : integer:= 0;		--状态变量
			 nsYewR : integer:= 1;
			 nsRewG : integer:= 2;
			 nsRewY : integer:= 3 );
	port( CLK : in std_logic;
		 stateQ : out std_logic_vector(1 downto 0)
		 );
end entity;

architecture beh of state is
begin
	process(CLK)
	variable num : integer range 0 to (12 * t);
	variable tempT : integer range 0 to 4:= 0;
	begin
		if( rising_edge(CLK) ) then 
			if( num > 12 * t ) then	--一个周期后，清零
				num := 0;
			else
				num := num + 1;
			end if;
			case num is
				when 5*t  => tempT := nsYewR;	--nsGewR占5t，计数满足后切换状态nsYewR
				when 6*t  => tempT := nsRewG;	--nsYewR占1t, 计数满足后切换状态nsRewG
				when 11*t => tempT := nsRewY;	--nsRewG占5t, 计数满足后切换状态nsRewY
				when 12*t => tempT := nsGewR;	--nsRewY占1t, 计数满足后切换状态nsYewG, 结束本次循环
				when others => tempT := tempT;	--其它状态保持不变
			end case;
		end if;
		stateQ <= conv_std_logic_vector(tempT, 2);	--数据类型转换
	end process;
end architecture;
			
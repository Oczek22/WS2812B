library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned."+";	

entity divider is
	port(
	clk_in : in std_logic;
	reset : in std_logic;
	clk_out : out std_logic;
	clk_debug : out std_logic
	);
end entity;

architecture rtl of divider is

signal div : std_logic_vector(23 downto 0);

begin
	
	main : process(reset, clk_in)
	begin
		if(reset = '1') then
			if(clk_in'event and clk_in = '1') then
				div <= div + 1;
			end if;
		else
			div <= (others => '0');
		end if;
	end process;
	
	clk_out <= div(3);
	clk_debug <= div(23);
end architecture;
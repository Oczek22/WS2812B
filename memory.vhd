library ieee;
use ieee.std_logic_1164.all;


entity memory is
	port(									   
	reset : in std_logic; 
	rotate : in std_logic;
	output : out std_logic;
	debug : out std_logic_vector(23 downto 0)
	);
end entity;	

architecture rtl of memory is

signal program : std_logic_vector (23 downto 0);

begin
	
	main : process(rotate, reset)
	begin 
		if(reset = '1') then
			if (rising_edge(rotate)) then
				program <= program (22 downto 0) & program(23);
			end if;
		else
	    	program <= "000000000000000000000001";		--GGRRBB? ; ciemny-Z,jasny-C,ciemny-C, jasny?-N,ciemny?-N, jasny-Z	
		end if;
	end process;
	
	output <= program(23);
	debug <= program;

end architecture;
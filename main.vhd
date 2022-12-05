library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned."+";
use ieee.std_logic_arith.all;			

entity main is
	port(
	clk : in std_logic;
	start : in std_logic;
	reset : in std_logic;
	switch : in std_logic;
	debuggers : in std_logic_vector(1 downto 0);
	output : out std_logic;
	dioda : out std_logic;
	clk_dioda : out std_logic;
	rotate_dioda : out std_logic;
	hex1 : out std_logic_vector(6 downto 0);
	hex2 : out std_logic_vector(6 downto 0);
	hex3 : out std_logic_vector(6 downto 0);
	cnt_hex : out std_logic_vector(6 downto 0);
	hex01 : out std_logic_vector(13 downto 0)
	);
end entity;

architecture rtl of main is

type state is (idle, s00, s01, s10, s11);
									  
signal current_state : state;
signal next_state : state; 
signal previous_state : state;

signal run : std_logic;						  
signal cycle_counter : std_logic_vector(0 downto 0);
signal diode_counter : std_logic_vector(6 downto 0);
signal index : std_logic_vector(4 downto 0); 
signal vall : std_logic;
signal int_clk : std_logic;

signal clock : std_logic; 
signal debug : std_logic;
signal program_debug : std_logic_vector(23 downto 0);	
signal rotation : std_logic;

component divider is
	port(
	clk_in : in std_logic;
	reset : in std_logic;
	clk_out : out std_logic;
	clk_debug : out std_logic
	);
end component;

component memory is
	port(									   
	reset : in std_logic; 
	rotate : in std_logic;
	output : out std_logic;
	debug : out std_logic_vector(23 downto 0)
	);
end component;

	-----------------funkcje-----------
	
	function value2hexes (
		signal wartosc : in std_logic_vector(4 downto 0)
	)
		return std_logic_vector is variable hexes : std_logic_vector(13 downto 0);
	begin
		case wartosc is
		when "00000" =>
		hexes := "00000010000001";
		when "00001" =>
		hexes := "00000011111001";
		when "00010" =>
		hexes := "00000010010010";
		when "00011" =>
		hexes := "00000010110000";
		when "00100" =>
		hexes := "00000011101000";
		when "00101" =>
		hexes := "00000010100100";
		when "00110" =>
		hexes := "00000010000100";
		when "00111" =>
		hexes := "00000011110001";
		when "01000" =>
		hexes := "00000010000000";
		when "01001" =>
		hexes := "00000010100000";
		when "01010" =>
		hexes := "11110010000001";
		when "01011" =>
		hexes := "11110011111001";
		when "01100" =>
		hexes := "11110010010010";
		when "01101" =>
		hexes := "11110010110000";
		when "01110" =>
		hexes := "11110011101000";
		when "01111" =>
		hexes := "11110010100100";
		when "10000" =>
		hexes := "11110010000100";
		when "10001" =>
		hexes := "11110011110001";
		when "10010" =>
		hexes := "11110010000000";
		when "10011" =>
		hexes := "11110010100000";
		when "10100" =>
		hexes := "00100100000001";
		when "10101" =>
		hexes := "00100101111001";
		when "10110" =>
		hexes := "00100100010010";
		when "10111" =>
		hexes := "00100100110000";
		when "11000" =>
		hexes := "00100101101000";
		when others =>
		hexes := "11111101111110";
		end case;
		return std_logic_vector(hexes);
	end function;
	
	function value2hex (
		signal wartosc : in std_logic_vector(3 downto 0)
	)
		return std_logic_vector is variable hex : std_logic_vector(6 downto 0);
	begin
		case wartosc is
		when "0000" =>
		hex := "0000001";
		when "0001" =>
		hex := "1111001";
		when "0010" =>
		hex := "0010010";
		when "0011" =>
		hex := "0110000";
		when "0100" =>
		hex := "1101000";
		when "0101" =>
		hex := "0100100";
		when "0110" =>
		hex := "0000100";
		when "0111" =>
		hex := "1110001";
		when "1000" =>
		hex := "0000000";
		when "1001" =>
		hex := "0100000";
		when "1010" =>
		hex := "1000000";
		when "1011" =>
		hex := "0001100";
		when "1100" =>
		hex := "0000111";
		when "1101" =>
		hex := "0011000";
		when "1110" =>
		hex := "0000110";
		when "1111" =>
		hex := "1000110";
		when others =>
		hex := "1111110";
		end case;
		return std_logic_vector(hex);
	end function;

begin  
	
	clk_div : divider port map(
	clk_in => clk,
	reset => reset,
	clk_out => int_clk,
	clk_debug => debug);
	
	programer : memory port map(
	reset => reset,
	rotate => rotation,
	output => vall,
	debug => program_debug);
	

	
	-----------------debuggery---------
	
	debuggery : process(switch, debuggers, current_state, vall)
	begin
		if(debuggers = "00") then			
			case current_state is
			when idle => 
			hex1 <= "1111001";
			hex2 <= "0011000";
			when s00 =>
			hex1 <= "0000001";
			hex2 <= "0000001";
			when s01 =>
			hex1 <= "0000001";
			hex2 <= "1111001";
			when s10 =>
			hex1 <= "1111001";
			hex2 <= "0000001";
			when s11 =>
			hex1 <= "1111001";
			hex2 <= "1111001";
			when others =>
			hex1 <= "1111110";
			hex2 <= "1111110";
			end case;
			
			if (vall = '1') then
				hex3 <= "1111001";
			else
				hex3 <= "0000001";
			end if;
			
			--cnt_hex <= value2hex(diode_counter);
			hex01 <= value2hexes(wartosc => index);
		
		else
			hex01 <= value2hex(program_debug(23 downto 20)) & value2hex(program_debug(19 downto 16));
			cnt_hex <= value2hex(program_debug(15 downto 12));
			hex3 <= value2hex(program_debug(11 downto 8));
			hex1 <= value2hex(program_debug(7 downto 4));
			hex2 <= value2hex(program_debug(3 downto 0));
		end if;
		if(switch = '0') then 
			clock <= int_clk;
		else
			clock <= debug;
		end if;
	end process;	
	
	clk_dioda <= clock;
	rotate_dioda <= vall;
	
	------------------koniec debuggerow-----------
	
	rotacja : process(current_state, run, reset, clock)
	begin  
		if(reset = '1') then	  
			if (rising_edge(clock)) then
				case (current_state) is
				when s01 =>
				if(run = '1') then
					if(cycle_counter = "1") then				
						rotation <= '1';
					end if;
				else
					rotation <= '0';
				end if;
				when s11 =>	
				if(run = '1') then
					rotation <= '1';  
				else 
					rotation <= '0';
				end if;
				when others =>
				rotation <= '0';
				end case;	
			end if;
		else
			rotation <= '0';
		end if;
	end process;
	
	automat : process(clock, reset)
	begin
		if(reset = '1') then
			if(falling_edge(clock)) then
				current_state <= next_state;	 
			end if;
		else
			current_state <= idle;
		end if;
	end process;
	
	przejscia : process(clock, reset)
	begin
		if(reset = '1') then
			if(rising_edge(clock)) then
				case (current_state) is 
					when idle =>
					if(run = '1') then
						if(vall = '0') then
							next_state <= s00;	
						else
							next_state <= s10;
						end if;
					end if;
					when s00 =>
					next_state <= s01;
					when s01 =>
					if(run = '1') then
						if (cycle_counter = "1")then
							if(vall = '0') then
								next_state <= s00;	
							else
								next_state <= s10;
							end if;
						end if;
					else
						next_state <= idle;
					end if;
					when s10 =>	
					if(cycle_counter = "1") then
						next_state <= s11;		
					end if;
					when s11 =>
					if(run = '1') then
						if(vall = '0') then
							next_state <= s00;	
						else
							next_state <= s10;
						end if;
					else
						next_state <= idle;
					end if;
					when others =>
					next_state <= idle;
				end case;
			end if;
		else
			next_state <= idle;
		end if;	
	end process;
	
	counter : process(current_state, clock, reset)
	begin
		if(reset = '1') then 
		if(run = '1') then
			if(rising_edge(clock)) then
				if (current_state = s01 or current_state = s10) then
					cycle_counter <= cycle_counter + 1;
				end if;
			end if;
		end if;
		else
			cycle_counter <= "0";
		end if;
	end process;			

	indexy : process(current_state, reset, clock, run)
	begin
		if(reset = '1') then
			if (rising_edge(clock)) then
				if(run = '0') then
					index <= "00000";
					diode_counter <= "0000000";
				else
					if (current_state = s01)then
						if(cycle_counter = "1") then
							if(index = "10111") then
								index <= (others => '0');
								diode_counter <= diode_counter + 1;
							else
								index <= index + 1;
							end if;
						end if;
					elsif (current_state = s11) then
						if(index = "10111") then
							index <= (others => '0');
							diode_counter <= diode_counter + 1;
						else
							index <= index + 1;
						end if;	
					end if;
				end if;					
			end if;
		else
			index <= "00000";
			diode_counter <= "0000000";
		end if;
	end process; 
	
	runner : process(start, index, reset)
	begin  
		if(reset = '1') then
			if (start'event and start = '1') then
				run <= '1';
			end if;
			if(diode_counter = "1110111") then						
				run <= '0';		
			end if;
		else
			run <= '0';
		end if;
	end process;
	
	setting_output : process(current_state)
	begin
		if(current_state = s00 or current_state = s10) then
			output <= '1';
			dioda <= '1';
		else
			output <= '0';
			dioda <= '0';
		end if;
	end process;
	
end architecture;
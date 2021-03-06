library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use IEEE.STD_LOGIC_SIGNED.ALL;
use std.textio.ALL;


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FilterLoad is
	Generic (filename : string := "filter.dat" ); 
    Port ( CLK : in std_logic;
           DOUT : out std_logic_vector(15 downto 0);
           AOUT : out std_logic_vector(8 downto 0);
           WEOUT : out std_logic;
			  LOAD : in std_logic);
end FilterLoad;

architecture Behavioral of FilterLoad is
	

	  	file inputfile : text; 
begin
	  process is
	  	variable val : integer := 0;
		variable valbit : std_logic_vector(21 downto 0) := (others => '0'); 
		
	  	variable L: line; 
	  begin
	  	  while 0 < 1 loop 
				val := 0;

				wait until rising_edge(LOAD);

				 file_open(inputfile, FILENAME, read_mode);
				 
				 for i in 0 to 255 loop
				 	  if not endfile(inputfile) then 
						  readline(inputfile, L);
					     read(L, val);
						  -- we write the low word first
						  valbit := conv_std_logic_vector(val, 22); 
					  
						  wait until rising_edge(clk); 
						  DOUT <= valbit(15 downto 0); 
						  AOUT <= conv_std_logic_vector(i*2, 9); 
						  WEOUT <= '1';

						  wait until rising_edge(clk); 
						  WEOUT <= '0';

						  wait until rising_edge(clk); 
						  DOUT <= ("0000000000" &  valbit(21 downto 16)); 
						  AOUT <= conv_std_logic_vector(i*2+1, 9); 
						  WEOUT <= '1';

						  wait until rising_edge(clk); 
						  WEOUT  <= '0'; 
						end if; 
				 end loop;  
				 file_close(inputfile); 


		  end loop;
	  end process; 

end Behavioral;

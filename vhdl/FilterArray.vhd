library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity FilterArray is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           WE : in std_logic;
           H : out std_logic_vector(21 downto 0);
           HA : in std_logic_vector(6 downto 0);
           AIN : in std_logic_vector(7 downto 0);
           DIN : in std_logic_vector(15 downto 0));
end FilterArray;

architecture Behavioral of FilterArray is
-- FILTERARRAY.VHD -- Array of filter coefficients. 22-bit values, 
-- which via creative input ram mapping are easily loaded sequentially. 

	signal we1, we2 : std_logic := '0';
	signal lh : std_logic_vector(31 downto 0) := (others => '0');
	signal addrin, addrout : std_logic_vector(7 downto 0) := (others => '0');


	 component RAMB4_S16_S16
	  generic (
	       INIT_00 : bit_vector ;
	       INIT_01 : bit_vector ;
	       INIT_02 : bit_vector ;
	       INIT_03 : bit_vector ;
	       INIT_04 : bit_vector ;
	       INIT_05 : bit_vector ;
	       INIT_06 : bit_vector ;
	       INIT_07 : bit_vector ;
	       INIT_08 : bit_vector ;
	       INIT_09 : bit_vector ;
	       INIT_0A : bit_vector ;
	       INIT_0B : bit_vector ;
	       INIT_0C : bit_vector ;
	       INIT_0D : bit_vector ;
	       INIT_0E : bit_vector ;
	       INIT_0F : bit_vector 
		  );


	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (15 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        RSTA   : in STD_logic;
	        RSTB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (7 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (7 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (15 downto 0)); 
	end component;

begin
   addrin <= '0' & AIN(7 downto 1); 
   addrout <= '0' & HA; 
   we1 <= WE and (not AIN(0));
   we2 <= WE and AIN(0);

   low_word: RAMB4_S16_S16 
   	  generic map(
			INIT_00 => X"000000000000000000000000000000000000000000000000000000000000FFFF",
			INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000"
		  )
	  port map (
	  	  DIA => DIN,
		  DIB => "0000000000000000",
		  ENA => '1',
		  ENB => '1',
		  WEA => we1,
		  WEB => '0',
		  RSTA => RESET,
		  RSTB => RESET,
		  CLKA => CLK,
		  CLKB => CLK,
		  ADDRA => addrin,
		  ADDRB => addrout,
		  DOA => open,
		  DOB => LH(15 downto 0)
	 );

   high_word: RAMB4_S16_S16 
   	  generic map(
			INIT_00 => X"000000000000000000000000000000000000000000000000000000000000001F",
			INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
			INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000"
		  )
	  port map (
	  	  DIA => DIN,
		  DIB => "0000000000000000",
		  ENA => '1',
		  ENB => '1',
		  WEA => we2,
		  WEB => '0',
		  RSTA => RESET,
		  RSTB => RESET,
		  CLKA => CLK,
		  CLKB => CLK,
		  ADDRA => addrin,
		  ADDRB => addrout,
		  DOA => open,
		  DOB => LH(31 downto 16)
	 );
	  	  

	process(CLK) is
	begin
	   if rising_edge(CLK) then
	      H <= lh(21 downto 0);
	   end if;								 
	end process; 

end Behavioral;

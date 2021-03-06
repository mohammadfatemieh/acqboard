library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity samplebuffer is
  port ( CLK       : in  std_logic;
         RESET     : in  std_logic;
         DIN       : in  std_logic_vector(15 downto 0);
         CHANIN    : in  std_logic_vector(3 downto 0);
         WE        : in  std_logic;
         AIN       : in  std_logic_vector(7 downto 0);
         DOUT      : out std_logic_vector(15 downto 0);
         AOUT      : in  std_logic_vector(7 downto 0);
         SAMPOUTEN : in  std_logic;
         ALLCHAN   : in  std_logic;
         ONLYONE   : in  std_logic;
         CHANOUT   : in  std_logic_vector(3 downto 0));
end samplebuffer;

architecture Behavioral of samplebuffer is
-- SAMPLEBUFFER.VHD                     -- sample buffers. Use 3 BlockSelect+ RAMs, 
-- each containing 4 channels. 
  signal we1, we2, we3              : std_logic := '0';
  signal data1, data2, data3, ldout : std_logic_vector(15 downto 0)
                                                := (others => '0');
  signal addra, addrb               : std_logic_vector(9 downto 0)
                                                := (others => '0');

  component RAMB16_S18_S18
    generic (
      WRITE_MODE_A : string     := "WRITE_FIRST";
      WRITE_MODE_B : string     := "WRITE_FIRST";
      INIT_A       : bit_vector := X"00000";
      SRVAL_A      : bit_vector := X"00000";

      INIT_B  : bit_vector := X"00000";
      SRVAL_B : bit_vector := X"00000";

      INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_00  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_01  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_02  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_03  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_04  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_05  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_06  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_07  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_08  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_09  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0A  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0B  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0C  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0D  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0E  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0F  : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"

      );

    port (DIA   : in  std_logic_vector (15 downto 0);
          DIB   : in  std_logic_vector (15 downto 0);
          DIPA  : in  std_logic_vector (1 downto 0);
          DIPB  : in  std_logic_vector (1 downto 0);
          ENA   : in  std_logic;
          ENB   : in  std_logic;
          WEA   : in  std_logic;
          WEB   : in  std_logic;
          SSRA  : in  std_logic;
          SSRB  : in  std_logic;
          CLKA  : in  std_logic;
          CLKB  : in  std_logic;
          ADDRA : in  std_logic_vector (9 downto 0);
          ADDRB : in  std_logic_vector (9 downto 0);
          DOA   : out std_logic_vector (15 downto 0);
          DOB   : out std_logic_vector (15 downto 0);
          DOPA  : out std_logic_vector (1 downto 0);
          DOPB  : out std_logic_vector (1 downto 0));
  end component;

begin
  ram1 : RAMB16_S18_S18 generic map (
    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
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
    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000")


    port map (
      DIA   => DIN,
      DIB   => X"0000",
      DIPA  => "00",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      WEA   => we1,
      WEB   => '0',
      SSRA  => RESET,
      SSRB  => RESET,
      CLKA  => CLK,
      CLKB  => CLK,
      ADDRA => addra,
      ADDRB => addrb,
      DOA   => open,
      DOB   => data1,
      DOPA  => open,
      DOPB  => open);


  ram2 : RAMB16_S18_S18
    port map (
      DIA   => DIN,
      DIB   => X"0000",
      DIPA  => "00",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      WEA   => we2,
      WEB   => '0',
      SSRA  => RESET,
      SSRB  => RESET,
      CLKA  => CLK,
      CLKB  => CLK,
      ADDRA => addra,
      ADDRB => addrb,
      DOA   => open,
      DOB   => data2,
      DOPA  => open,
      DOPB  => open);


  ram3 : RAMB16_S18_S18
    port map (
      DIA   => DIN,
      DIB   => X"0000",
      DIPA  => "00",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      WEA   => we3,
      WEB   => '0',
      SSRA  => RESET,
      SSRB  => RESET,
      CLKA  => CLK,
      CLKB  => CLK,
      ADDRA => addra,
      ADDRB => addrb,
      DOA   => open,
      DOB   => data3,
      DOPA  => open,
      DOPB  => open);

  we1 <= '1' when (WE = '1' and CHANIN(3 downto 2) = "00" )
         or (ALLCHAN = '1') else '0';

  we2 <= '1' when (WE = '1' and CHANIN(3 downto 2) = "01")
         or (ALLCHAN = '1') else '0';

  we3 <= '1' when (WE = '1' and CHANIN(3 downto 2) = "10")
         or (ALLCHAN = '1') else '0';

  addra(9 downto 8) <= CHANIN(1 downto 0) when ALLCHAN = '0' and ONLYONE = '0'
                       else "00";
  addra(7 downto 0) <= AIN;

  addrb(9 downto 8) <= CHANOUT(1 downto 0) when ONLYONE = '0' else "00"; 
  addrb(7 downto 0) <= AOUT;
  ldout             <= data1 when chanout(3 downto 2) = "00" or ONLYONE = '1'
                       else
                       data2 when chanout(3 downto 2) = "01" else
                       data3;

  process(CLK) is
  begin
    if rising_edge(clk) then
      DOUT <= ldout;
    end if;
  end process;


end Behavioral;

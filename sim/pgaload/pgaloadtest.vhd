
-- VHDL Test Bench Created from source file pgaload.vhd  -- 21:26:35 02/03/2005
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.Silly.all;
entity pgaloadtest is
end pgaloadtest;

architecture behavior of pgaloadtest is

  component pgaload
    port(
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      CHAN     : in  std_logic_vector(3 downto 0);
      GAIN     : in  std_logic_vector(2 downto 0);
      FILTER   : in  std_logic;
      GSET     : in  std_logic;
      ISET     : in  std_logic;
      FSET     : in  std_logic;
      PGARESET : in  std_logic;
      ISEL     : in  std_logic_vector(1 downto 0);
      SCLK     : out std_logic;
      RCLK     : out std_logic;
      SOUT     : out std_logic
      );

  end component;

  signal CLK      : std_logic                    := '0';
  signal RESET    : std_logic                    := '1';
  signal SCLK     : std_logic;
  signal RCLK     : std_logic;
  signal SOUT     : std_logic;
  signal CHAN     : std_logic_vector(3 downto 0) := (others => '0');
  signal GAIN     : std_logic_vector(2 downto 0) := (others => '0');
  signal FILTER   : std_logic                    := '0';
  signal GSET     : std_logic;
  signal ISET     : std_logic;
  signal FSET     : std_logic;
  signal PGARESET : std_logic                    := '0';
  signal ISEL     : std_logic_vector(1 downto 0) := (others => '0');

  component PGA
    port ( SCLK    : in  std_logic;
           RCLK    : in  std_logic;
           SIN     : in  std_logic;
           GAINS   : out chanarray;
           FILTERS : out chanarray;
           INSELA  : out integer;
           INSELB  : out integer
           );
  end component;

  signal pgadata : std_logic_vector(6*8-1 downto 0);

  -- parsing
  signal gains          : chanarray := (others => 0);
  signal filters        : chanarray := (others => 0);
  signal inselA, inselb : integer   := 0;


begin


  uut : pgaload port map(
    CLK      => CLK,
    RESET    => RESET,
    SCLK     => SCLK,
    RCLK     => RCLK,
    SOUT     => SOUT,
    CHAN     => CHAN,
    GAIN     => GAIN,
    FILTER   => FILTER,
    GSET     => GSET,
    ISET     => ISET,
    FSET     => FSET,
    PGARESET => PGARESET,
    ISEL     => ISEL
    );


  CLK   <= not CLK after 6.944 ns;
  RESET <= '0'     after 40 ns;

  PGAuut : PGA port map
    (SCLK    => SCLK,
     RCLK    => RCLK,
     SIN     => SOUT,
     FILTERS => filters,
     GAINS   => gains,
     INSELA  => insela,
     INSELB  => inselb);

  -- running code
  main : process is
  begin

    wait until falling_edge(RESET);
    wait for 20 ns;
    wait until rising_edge(CLK);

    CHAN <= "0000";
    GAIN <= "110";
    GSET <= '1';
    wait until rising_edge(CLK);
    GSET <= '0';
    for i in 1 to 300 loop
      wait until rising_edge(CLK);
    end loop;
    assert gains(0) = 6
      report "Error setting gains(0)"
      severity error;

    CHAN <= "0001";
    GAIN <= "101";
    GSET <= '1';
    wait until rising_edge(CLK);
    GSET <= '0';
    for i in 1 to 300 loop
      wait until rising_edge(CLK);
    end loop;
    assert gains(1) = 5
      report "Error setting gains(1)"
      severity error;

    CHAN   <= "0001";
    FILTER <= '1';
    FSET   <= '1';
    wait until rising_edge(CLK);
    FSET   <= '0';
    for i in 1 to 300 loop
      wait until rising_edge(CLK);
    end loop;
    assert filters(1) = 1
      report "Error setting filters(1)"
      severity error;


    CHAN <= "1000";
    GAIN <= "111";
    GSET <= '1';
    wait until rising_edge(CLK);
    GSET <= '0';
    for i in 1 to 300 loop
      wait until rising_edge(CLK);
    end loop;
    assert gains(8) = 7
      report "Error setting gains(8)"
      severity error;

    assert false
      report "End of simulation"
      severity failure;

  end process main;
end;


-- VHDL Test Bench Created from source file test_serialize.vhd -- 12:18:47 06/29/2003
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY serializetest IS
END serializetest;

ARCHITECTURE behavior OF serializetest IS 

	COMPONENT serialize
    Generic (filename : string := "input.dat"); 
    Port ( START : in std_logic;
           DOUT : out std_logic;
		 DONE : out std_logic);
	END COMPONENT;

	SIGNAL start :  std_logic := '0';
	SIGNAL dout :  std_logic;
	SIGNAL done :  std_logic;

BEGIN

	uut: serialize PORT MAP(
		start => start,
		dout => dout,
		done => done
	);

   start <= '1' after 10us; 
-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;

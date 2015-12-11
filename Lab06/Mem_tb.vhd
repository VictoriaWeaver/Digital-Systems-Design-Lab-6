----------------------------------------------------------------------------------
-- File:				Mem_tb.vhd
-- 
-- Entity:			Mem_tb
-- Architecture:	Behavioral
-- Author:			Victoria Weaver
-- Created:			11/19/15
-- Modified:		11/21/15
-- 
-- VHDL '93
-- Descritption:	The following is the test bench for the IO_Bus component.
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY Mem_tb IS
END Mem_tb;
 
ARCHITECTURE behavior OF Mem_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IO_Bus
    PORT(
         BUS_ID : IN  std_logic;
         RESET : IN  std_logic;
         RW : IN  std_logic;
         READY : IN  std_logic;
         BURST : IN  std_logic;
         CLK : IN  std_logic;
         ADDR : IN  std_logic_vector(2 downto 0);
         IDATA : IN  std_logic_vector(3 downto 0);
         ODATA : OUT std_logic_vector(3 downto 0);
			unused_anode : OUT  std_logic;
         hund_anode : OUT  std_logic;
         tens_anode : OUT  std_logic;
         ones_anode : OUT  std_logic;
         CAn : OUT  std_logic;
         CBn : OUT  std_logic;
         CCn : OUT  std_logic;
         CDn : OUT  std_logic;
         CEn : OUT  std_logic;
         CFn : OUT  std_logic;
         CGn : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal BUS_ID : std_logic := '0';
   signal RESET : std_logic := '0';
   signal RW : std_logic := '0';
   signal READY : std_logic := '0';
   signal BURST : std_logic := '0';
   signal CLK : std_logic := '0';
   signal ADDR : std_logic_vector(2 downto 0) := (others => '0');
	signal IDATA : std_logic_vector(3 downto 0);

 	--Outputs
   signal ODATA : std_logic_vector(3 downto 0);
	signal unused_anode : std_logic;
   signal hund_anode : std_logic;
   signal tens_anode : std_logic;
   signal ones_anode : std_logic;
   signal CAn : std_logic;
   signal CBn : std_logic;
   signal CCn : std_logic;
   signal CDn : std_logic;
   signal CEn : std_logic;
   signal CFn : std_logic;
   signal CGn : std_logic;
	
	-- Second IO_BUS
	signal BUS_ID2 : std_logic;
	signal ODATA2 : std_logic_vector(3 downto 0);
	signal unused_anode2 : std_logic;
   signal hund_anode2 : std_logic;
   signal tens_anode2 : std_logic;
   signal ones_anode2 : std_logic;
   signal CAn2 : std_logic;
   signal CBn2 : std_logic;
   signal CCn2 : std_logic;
   signal CDn2 : std_logic;
   signal CEn2 : std_logic;
   signal CFn2 : std_logic;
   signal CGn2 : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut1: IO_Bus PORT MAP (
          BUS_ID => BUS_ID,
          RESET => RESET,
          RW => RW,
          READY => READY,
          BURST => BURST,
          CLK => CLK,
          ADDR => ADDR,
          IDATA => IDATA,
			 ODATA => ODATA,
          unused_anode => unused_anode,
          hund_anode => hund_anode,
          tens_anode => tens_anode,
          ones_anode => ones_anode,
          CAn => CAn,
          CBn => CBn,
          CCn => CCn,
          CDn => CDn,
          CEn => CEn,
          CFn => CFn,
          CGn => CGn
        );
		  
	 uut2: IO_Bus PORT MAP (
          BUS_ID => BUS_ID2,
          RESET => RESET,
          RW => RW,
          READY => READY,
          BURST => BURST,
          CLK => CLK,
          ADDR => ADDR,
          IDATA => IDATA,
			 ODATA => ODATA2,
          unused_anode => unused_anode2,
          hund_anode => hund_anode2,
          tens_anode => tens_anode2,
          ones_anode => ones_anode2,
          CAn => CAn2,
          CBn => CBn2,
          CCn => CCn2,
          CDn => CDn2,
          CEn => CEn2,
          CFn => CFn2,
          CGn => CGn2
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '1';
		wait for CLK_period/2;
		CLK <= '0';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
	
      -- hold reset state for 100 ns.
		RESET <= '1';
		
		
		wait for 100 ns;
		
		RESET <= '0';
		BUS_ID <= '1';
		READY <= '0';
		
		BUS_ID2 <= '0';
		RW <= '1';
		
		-- Write		
		for i in 0 to 7 loop
			READY <= '0';
			ADDR <= std_logic_vector(to_unsigned(i, 3)); 
			IDATA <= std_logic_vector(to_unsigned(i, 4));
			wait for CLK_period*2;
			READY <= '1';
			wait for CLK_period;
			assert(ODATA = std_logic_vector(to_unsigned(i, 4)))
				report "WRITE ERROR";
		end loop;
		
		wait for CLK_period;
		
		-- Read
		RW <= '0'; -- Read mode
		BURST <= '0';
		
		BUS_ID <= '0';
		BUS_ID2 <= '1';
		
		
		for i in 0 to 7 loop
			READY <= '0';
			ADDR <= std_logic_vector(to_unsigned(i, 3)); 
			wait for CLK_period*2;
			READY <= '1';
			assert(ODATA = std_logic_vector(to_unsigned(i, 4)))
				report "READ ERROR";
			wait for CLK_period;
		end loop;
		
		READY <= '0';
		
		wait for CLK_period;
		
		-- Note: Previous two test confirm that data written is data read
		
		BUS_ID2 <= '0';
		BUS_ID <= '1';
		wait for CLK_period;
	
		-- Burst Read
		BURST <= '1';
		ADDR <= "000";
		
		for i in 0 to 3 loop
			READY <= '1';
			wait for CLK_period*5;
			assert(ODATA = std_logic_vector(to_unsigned(i, 4)))
				report "BURST ERROR";
			wait for CLK_period*5;
			READY <= '0';
			wait for CLK_period*5;
		end loop;
		
		-- Memory out of range
		assert ((to_integer(unsigned(ADDR)) <= 7) OR (to_integer(unsigned(ADDR)) >= 0))
			report "Invalid memory";

      wait;
   end process;

END;

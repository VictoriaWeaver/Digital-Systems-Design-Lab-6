----------------------------------------------------------------------------------
-- File:				IO_Bus.vhd
-- 
-- Entity:			IO_Bus
-- Architecture:	Behavioral
-- Author:			Victoria Weaver
-- Created:			11/19/15
-- Modified:		11/21/15
--						12/03/15
-- 
-- VHDL '93
-- Descritption:	The following is the entity and architectural description of 
-- 					the IO-Bus unit.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.bin_bcd.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO_Bus is
    Port ( BUS_ID : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           RW : in  STD_LOGIC;
           READY : in  STD_LOGIC;
           BURST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           ADDR : in  STD_LOGIC_VECTOR(2 downto 0);
           IDATA : in  STD_LOGIC_VECTOR(3 downto 0);
			  ODATA : out  STD_LOGIC_VECTOR(3 downto 0);
			  unused_anode : out STD_LOGIC; -- unused an3
			  hund_anode   : out STD_LOGIC; -- digilent an2
	        tens_anode   : out STD_LOGIC; -- digilent an3
	        ones_anode   : out STD_LOGIC; -- digilent an4
			  CAn,CBn,CCn,CDn,CEn,CFn,CGn : out STD_LOGIC); -- digilent cathode - used for all displays);
end IO_Bus;

architecture Behavioral of IO_Bus is

-- Memory Controller
component Mem_Controller is
    Port ( 	BUS_ID : in STD_LOGIC;	-- Asserted with making memory access
				RESET : in STD_LOGIC;	-- Reset signal
				RW : in STD_LOGIC;		-- Read/Write signal
				READY : in STD_LOGIC;	-- Ready signal
				BURST : in STD_LOGIC;	-- Burst signal
				CLK : in STD_LOGIC;		-- CLock signal
				OE : out STD_LOGIC;		-- Output enable signal: is asserted during each of the read cycles
				WE : out STD_LOGIC;		-- Write enable signal
				ADDR1 : out STD_LOGIC;	-- Memory address signal 1
				ADDR2 : out STD_LOGIC);	-- Memory address signal 2
end component;

-- SRAM
component SRAM is
    Port ( 	i_oe : in STD_LOGIC;	-- output enable signal: determines is the output is sent out
    		i_we : in STD_LOGIC;	-- write-enable signal
    		i_addr : in STD_LOGIC_VECTOR (2 downto 0);	-- address: the 8 memory indices
    		i_data : in STD_LOGIC_VECTOR (3 downto 0);	-- input data
    		o_data : out STD_LOGIC_VECTOR (3 downto 0));	-- output data			
end component;


-- Seven Segment Decoder
component seven_seg_decode is
    Port ( seven_seg_in : in  STD_LOGIC_VECTOR (11 downto 0);
           seven_seg_out : out  STD_LOGIC_VECTOR (20 downto 0));
end component;

-- Seven Segment Display
component seven_seg_disp is
    Port ( hund_disp_n  : in  STD_LOGIC_VECTOR (6 downto 0);
	        tens_disp_n  : in  STD_LOGIC_VECTOR (6 downto 0);
           ones_disp_n  : in  STD_LOGIC_VECTOR (6 downto 0);
	        clk          : in  STD_LOGIC; -- digilent board generated clock
			  reset_n      : in  STD_LOGIC; -- switch input
			  unused_anode : out STD_LOGIC; -- unused an3
			  hund_anode   : out STD_LOGIC; -- digilent an2
	        tens_anode   : out STD_LOGIC; -- digilent an3
	        ones_anode   : out STD_LOGIC; -- digilent an4
			  CAn,CBn,CCn,CDn,CEn,CFn,CGn : out STD_LOGIC); -- digilent cathode - used for all displays
end component;


-- Internal signals
signal int_oe, int_we : STD_LOGIC;
signal ssout : STD_LOGIC_VECTOR(20 downto 0);
signal hund, tens, ones : STD_LOGIC_VECTOR(6 downto 0);
signal disp_data : STD_LOGIC_VECTOR(11 downto 0);
signal offset : STD_LOGIC_VECTOR(1 downto 0);
signal int_addr : STD_LOGIC_VECTOR(2 downto 0);
signal int_odata: STD_LOGIC_VECTOR(3 downto 0);

begin

-- Instantiate all the components
inst_MC : Mem_Controller port map(BUS_ID, RESET, RW, READY, BURST, CLK, int_oe, int_we, offset(1), offset(0));

int_addr <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(ADDR)) + to_integer(unsigned(offset)), 3));

inst_SRAM : SRAM port map(int_oe, int_we, int_addr, IDATA, int_odata);

-- BCD Conversions
disp_data <= Bin_to_BCD("00000000" & int_odata);	-- Needs to be a 12-bit vector

ODATA <= int_odata;

-- Output to SSD
ssdecode : seven_seg_decode port map( disp_data ,ssout);

hund <= ssout(20 downto 14);
tens <= ssout(13 downto 7);
ones <= ssout(6 downto 0);


ssd : seven_seg_disp port map(hund, tens, ones, CLK, RESET, unused_anode, hund_anode, tens_anode, ones_anode,
										CAn, CBn, CCn, CDn, CEn, CFn, CGn);


end Behavioral;

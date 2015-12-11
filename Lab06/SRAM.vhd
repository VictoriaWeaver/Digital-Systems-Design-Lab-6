----------------------------------------------------------------------------------
-- File:				SRAM.vhd
-- 
-- Entity:			SRAM
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SRAM is
    Port (  i_oe : in STD_LOGIC;	-- output enable signal: determines is the output is sent out
				i_we : in STD_LOGIC;	-- write-enable signal
				i_addr : in STD_LOGIC_VECTOR (2 downto 0);	-- address: the 8 memory indices
				i_data : in STD_LOGIC_VECTOR (3 downto 0);	-- input data
				o_data : out STD_LOGIC_VECTOR (3 downto 0));	-- output data
end SRAM;

architecture Behavioral of SRAM is

-- Internal data wire
signal int_data : STD_LOGIC_VECTOR(3 downto 0);

type cell is array (0 to 7) of STD_LOGIC_VECTOR(3 downto 0);
signal cells: cell:= ("0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000");

begin

data_proc: process (i_addr, i_oe, i_we, int_data, i_data)
begin
	if ((i_oe = '0') AND (i_we = '1')) then
		int_data <= i_data;
		cells(to_integer(unsigned(i_addr))) <= int_data;
	elsif ((i_oe = '1') AND (i_we = '0')) then
		int_data <= cells(to_integer(unsigned(i_addr)));
	else
		int_data <= int_data;
	end if;

	o_data <= int_data;
end process;
end Behavioral;


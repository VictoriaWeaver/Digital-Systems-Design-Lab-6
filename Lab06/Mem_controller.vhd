----------------------------------------------------------------------------------
-- File:				Mem_controller.vhd
-- 
-- Entity:			Mem_controller
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mem_controller is
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
end Mem_controller;

architecture Behavioral of Mem_controller is

type STATE_TYPE is (IDLE, DECISION, WRITE_DATA, READ_1, READ_2, READ_3, READ_4, HOLD_1, HOLD_2, HOLD_3, HOLD_4);
signal STATE, NEXT_STATE: STATE_TYPE;

signal offset: STD_LOGIC_VECTOR(1 downto 0);

constant ID: STD_LOGIC:= '1';

begin

-- Synchronize with the clock (drives the state change)
SYNC_PROC: process (CLK, STATE, RESET) 
begin
	if (RESET = '1') then
		STATE <= IDLE;
	elsif (CLK'event and CLK = '1') then
		STATE <= NEXT_STATE;
	else
		STATE <= STATE;
	end if;
end process;


-- Determine the next state
NextStateDecode: process (STATE, RW, READY, BURST, BUS_ID, offset)
begin
	if (BUS_ID = ID) then
		case (STATE) is
		when IDLE =>
			if BUS_ID = ID then
				NEXT_STATE <= DECISION;
			else
				NEXT_STATE <= IDLE;
			end if;
					
		when DECISION =>
					if RW = '0' then
						NEXT_STATE <= READ_1;
					elsif RW = '1' then
						NEXT_STATE <= WRITE_DATA;
					end if;
					
		when WRITE_DATA =>
					if READY = '1' then
						NEXT_STATE <= IDLE;
					else
						NEXT_STATE <= WRITE_DATA;
					end if;
					
		when READ_1 =>
					if READY = '1' and BURST = '0' then
						NEXT_STATE <= IDLE;
					elsif READY = '1' and BURST = '1' then
						NEXT_STATE <= HOLD_1;
					else
						NEXT_STATE <= READ_1;
					end if;
		
		when HOLD_1 =>
					if READY = '0' then
						NEXT_STATE <= READ_2;
					else
						NEXT_STATE <= HOLD_1;
					end if;
					
		when READ_2 =>
					if READY = '1' then
						NEXT_STATE <= HOLD_2;
					else
						NEXT_STATE <= READ_2;
					end if;
		
		when HOLD_2 =>
					if READY = '0' then
						NEXT_STATE <= READ_3;
					else
						NEXT_STATE <= HOLD_2;
					end if;

		when READ_3 =>
					if READY = '1' then
						NEXT_STATE <= HOLD_3;
					else
						NEXT_STATE <= READ_3;					
					end if;
		
		when HOLD_3 =>
					if READY = '0' then
						NEXT_STATE <= READ_4;
					else
						NEXT_STATE <= HOLD_3;
					end if;
					
		when READ_4 =>
					if READY = '1' then
						NEXT_STATE <= HOLD_4;
					else
						NEXT_STATE <= READ_4;
					end if;
					
		when HOLD_4 =>
					if READY = '0' then
						NEXT_STATE <= IDLE;
					else
						NEXT_STATE <= HOLD_4;				
					end if;
					
		when others =>
			NEXT_STATE <= STATE;
		end case;
	else
		NEXT_STATE <= IDLE;
	end if;
end process;


-- Determines the offset of the address, 0 unless in burst mode
Offset_proc: process (STATE, offset)
begin
	case (STATE) is
	when READ_2 =>
		offset <= "01";
	when READ_3 =>
		offset <= "10";
	when READ_4 =>
		offset <= "11";
	when HOLD_1 =>
		offset <= offset;
	when HOLD_2 =>
		offset <= offset;
	when HOLD_3 =>
		offset <= offset;
	when HOLD_4 =>
		offset <= offset;
	when others =>
		offset <= "00";
	end case;

ADDR1 <= offset(1);
ADDR2 <= offset(0);

end process;


-- Determines the write enable signal
WE_proc: process (STATE) 
begin
	case (STATE) is
		when WRITE_DATA =>
			WE <= '1';
		when others =>
			WE <= '0';
	end case;
end process;


-- Determines the output enable signal
OE_proc: process (STATE) 
begin
	case (STATE) is
		when READ_1 =>
			OE <= '1';
		when READ_2 =>
			OE <= '1';
		when READ_3 =>
			OE <= '1';
		when READ_4 =>
			OE <= '1';
		when others =>
			OE <= '0';
	end case;
end process;



end Behavioral;


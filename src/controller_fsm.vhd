----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port (
        i_clk   : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        i_btnC  : in STD_LOGIC;                       -- button signal
        o_cycle : out STD_LOGIC_VECTOR (3 downto 0)   -- FSM state output
    );
end controller_fsm;

architecture FSM of controller_fsm is
    signal w_cycle    : std_logic_vector(3 downto 0) := "0001";
    signal btnC_sync0 : std_logic := '0';
    signal btnC_sync1 : std_logic := '0';
    signal btnC_edge  : std_logic := '0';
begin

    -- Edge detector for btnC (synchronized to i_clk)
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            btnC_sync0 <= i_btnC;
            btnC_sync1 <= btnC_sync0;
            btnC_edge  <= btnC_sync0 and not btnC_sync1;
        end if;
    end process;

    -- FSM: advance state only on rising edge of btnC
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                w_cycle <= "0001";
            elsif btnC_edge = '1' then
                case w_cycle is
                    when "0001" => w_cycle <= "0010";  -- State 1 → 2
                    when "0010" => w_cycle <= "0100";  -- State 2 → 3
                    when "0100" => w_cycle <= "1000";  -- State 3 → 4
                    when "1000" => w_cycle <= "0001";  -- State 4 → 1
                    when others => w_cycle <= "0001";  -- Default to state 1
                end case;
            end if;
        end if;
    end process;

    o_cycle <= w_cycle;

end FSM;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal result   : signed(7 downto 0);
    signal carry    : std_logic := '0';
    signal overflow : std_logic := '0';
begin

    process(i_A, i_B, i_op)
        variable A_ext, B_ext : signed(8 downto 0);
        variable sum          : signed(8 downto 0);
        variable A, B         : signed(7 downto 0);
    begin

        A_ext := (8 => i_A(7), 7 => i_A(7), 6 => i_A(6), 5 => i_A(5),
                  4 => i_A(4), 3 => i_A(3), 2 => i_A(2), 1 => i_A(1), 0 => i_A(0));

        B_ext := (8 => i_B(7), 7 => i_B(7), 6 => i_B(6), 5 => i_B(5),
                  4 => i_B(4), 3 => i_B(3), 2 => i_B(2), 1 => i_B(1), 0 => i_B(0));
                  
        case i_op is
            when "000" =>  -- ADD
                sum := A_ext + B_ext;
                result <= sum(7 downto 0);
                carry <= sum(8);
                -- ADD overflow detection
                if (i_A(7) = i_B(7)) and (i_A(7) /= sum(7)) then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;


            when "001" =>  -- SUB
                sum := A_ext - B_ext;
                result <= sum(7 downto 0);
                carry <= sum(8);
                -- SUB overflow detection
                if (i_A(7) /= i_B(7)) and (i_A(7) /= sum(7)) then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;




            when "010" =>  -- AND
                result <= A and B;
                carry <= '0';
                overflow <= '0';

            when "011" =>  -- OR
                result <= A or B;
                carry <= '0';
                overflow <= '0';

            when others =>
                result <= (others => '0');
                carry <= '0';
                overflow <= '0';
        end case;

        -- Output result
        o_result <= std_logic_vector(result);

        -- Set flags: Z N C V
        if result = to_signed(0, 8) then
            o_flags(3) <= '1';  -- Zero flag
        else
            o_flags(3) <= '0';
        end if;

        o_flags(2) <= result(7);                    -- Negative
        o_flags(1) <= carry;                        -- Carry
        o_flags(0) <= overflow;                     -- Overflow
    end process;


end Behavioral;
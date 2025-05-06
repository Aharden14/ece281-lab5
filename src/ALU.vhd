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
begin

    process(i_A, i_B, i_op)
        -- Signed & Unsigned variables
        variable A_s, B_s     : signed(7 downto 0);
        variable A_u, B_u     : unsigned(7 downto 0);
        variable sum_s        : signed(8 downto 0);
        variable sum_u        : unsigned(8 downto 0);
        variable result       : signed(7 downto 0);
        variable carry        : std_logic := '0';
        variable overflow     : std_logic := '0';
    begin
        A_s := signed(i_A);
        B_s := signed(i_B);
        A_u := unsigned(i_A);
        B_u := unsigned(i_B);

        case i_op is
            when "000" =>  -- ADD
                sum_u := resize(A_u, 9) + resize(B_u, 9);
                result := signed(sum_u(7 downto 0));
                carry := sum_u(8);
                if (A_s(7) = B_s(7)) and (A_s(7) /= result(7)) then
                    overflow := '1';
                else
                    overflow := '0';
                end if;

            when "001" =>  -- SUB
                sum_u := resize(A_u, 9) - resize(B_u, 9);
                result := signed(sum_u(7 downto 0));
                carry := sum_u(8);  -- In subtraction, this means "no borrow" = 1
                if (A_s(7) /= B_s(7)) and (A_s(7) /= result(7)) then
                    overflow := '1';
                else
                    overflow := '0';
                end if;

            when "010" =>  -- AND
                result := A_s and B_s;
                carry := '0';
                overflow := '0';

            when "011" =>  -- OR
                result := A_s or B_s;
                carry := '0';
                overflow := '0';

            when others =>
                result := (others => '0');
                carry := '0';
                overflow := '0';
        end case;

        -- Output result
        o_result <= std_logic_vector(result);

        -- Set flags: N Z C V (bit 3 downto 0)
        o_flags(3) <= result(7);  -- N = sign bit
        if result = to_signed(0, 8) then
            o_flags(2) <= '1';    -- Z
        else
            o_flags(2) <= '0';
        end if;
        o_flags(1) <= carry;      -- C
        o_flags(0) <= overflow;   -- V
    end process;

end Behavioral;


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
        variable A_ext, B_ext : signed(8 downto 0);
        variable sum          : signed(8 downto 0);
        variable A, B         : signed(7 downto 0);
        variable result       : signed(7 downto 0);
        variable carry        : std_logic := '0';
        variable overflow     : std_logic := '0';
    begin
        A := signed(i_A);
        B := signed(i_B);

        A_ext := resize(A, 9);
        B_ext := resize(B, 9);

        case i_op is
            when "000" =>  -- ADD
                sum := A_ext + B_ext;
                result := sum(7 downto 0);
                carry := sum(8);
                -- ADD overflow: same sign inputs, different sign output
                if (A(7) = B(7)) and (A(7) /= sum(7)) then
                    overflow := '1';
                else
                    overflow := '0';
                end if;

            when "001" =>  -- SUB
                sum := A_ext - B_ext;
                result := sum(7 downto 0);
                carry := sum(8);
                -- SUB overflow: different sign inputs, result sign != A
                if (A(7) /= B(7)) and (A(7) /= sum(7)) then
                    overflow := '1';
                else
                    overflow := '0';
                end if;

            when "010" =>  -- AND
                result := A and B;
                carry := '0';
                overflow := '0';

            when "011" =>  -- OR
                result := A or B;
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
            o_flags(2) <= '1';    -- Z = zero
        else
            o_flags(2) <= '0';
        end if;
        o_flags(1) <= carry;      -- C
        o_flags(0) <= overflow;   -- V
    end process;

end Behavioral;

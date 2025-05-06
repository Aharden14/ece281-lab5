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
--use IEEE.NUMERIC_STD.ALL;

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

    component ripple_adder is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC);
    end component;

    signal w_sum : std_logic_vector (7 downto 0);
    signal w_result : std_logic_vector (7 downto 0);
    signal w_Cout: std_logic;
    signal w_carry: std_logic;
    signal w_B_sum: std_logic_vector (7 downto 0);

begin

    ripple_adder_1_inst: ripple_adder
    port map(
        A     => i_A(3 downto 0),
        B     => w_B_sum(3 downto 0),
        Cin   => i_op(0),
        S     => w_sum(3 downto 0),
        Cout  => w_carry
    );
    
    ripple_adder_2_inst: ripple_adder
    port map(
        A     => i_A(7 downto 4),
        B     => w_B_sum(7 downto 4),
        Cin   => w_carry,
        S     => w_sum(7 downto 4),
        Cout  => w_Cout
    );                
     
    -- Implement mux
    with i_op(0) select
        w_B_sum <= i_B when '0',
                   (not i_B) when others;
    
    with i_op select
        w_result <= w_sum when "000",
                w_sum when "001",
                (i_A and i_B) when "010",
                (i_A or i_B) when "011",
                x"00" when others;
    
        o_result <= w_result;
        
    
        -- N
        o_flags(3) <= w_result(7);
        
        -- Z
        o_flags(2) <= (not w_result(7)) and (not w_result(6)) and (not w_result(5)) and (not w_result(4)) and (not w_result(3)) and (not w_result(2)) and (not w_result(1)) and (not w_result(0));
        
        -- C
        o_flags(1) <= (not i_op(1))and w_Cout;
        
        -- V
        o_flags(0) <=   (not (i_op(0) xor (i_A(7) xor i_B(7))))
                       and (i_A(7) xor w_sum(7))
                       and (not i_op(1));
 
end Behavioral;

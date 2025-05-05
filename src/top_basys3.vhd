--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_basys3 is
    port (
        clk     : in std_logic;
        sw      : in std_logic_vector(7 downto 0);
        btnU    : in std_logic;
        btnC    : in std_logic;
        led     : out std_logic_vector(15 downto 0);
        seg     : out std_logic_vector(6 downto 0);
        an      : out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is

    signal slow_clk     : std_logic;
    signal cycle        : std_logic_vector(3 downto 0);
    signal operand_A    : std_logic_vector(7 downto 0);
    signal operand_B    : std_logic_vector(7 downto 0);
    signal alu_result   : std_logic_vector(7 downto 0);
    signal alu_flags    : std_logic_vector(3 downto 0);
    signal sign         : std_logic;
    signal hundreds     : std_logic_vector(3 downto 0);
    signal tens         : std_logic_vector(3 downto 0);
    signal ones         : std_logic_vector(3 downto 0);
    signal display_data : std_logic_vector(3 downto 0);
    signal sel          : std_logic_vector(3 downto 0);
    signal signed_digit : std_logic_vector(3 downto 0);
    signal an_pre    : std_logic_vector(3 downto 0);
    signal seg_value : std_logic_vector(6 downto 0);  
    signal btnC_sync_0 : std_logic;
    signal btnC_sync_1 : std_logic;
    signal btnC_edge : std_logic;
    

    component controller_fsm
        port (
            i_reset : in std_logic;
            i_adv   : in std_logic;
            o_cycle : out std_logic_vector(3 downto 0)
        );
    end component;

    component clock_divider
        generic (
            K_DIV : integer := 2
        );
        port (
            i_clk   : in std_logic;
            i_reset : in std_logic;
            o_clk   : out std_logic
        );
    end component;

    component ALU
        port (
            i_A      : in std_logic_vector(7 downto 0);
            i_B      : in std_logic_vector(7 downto 0);
            i_op     : in std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0);
            o_flags  : out std_logic_vector(3 downto 0)
        );
    end component;

    component twos_comp
        port (
            i_bin     : in  std_logic_vector(7 downto 0);
            o_sign    : out std_logic;
            o_hund    : out std_logic_vector(3 downto 0);
            o_tens    : out std_logic_vector(3 downto 0);
            o_ones    : out std_logic_vector(3 downto 0)
        );
    end component;

    component TDM4
        generic (
            K_WIDTH : integer := 4
        );
        port (
            i_D3    : in std_logic_vector(K_WIDTH-1 downto 0);
            i_D2    : in std_logic_vector(K_WIDTH-1 downto 0);
            i_D1    : in std_logic_vector(K_WIDTH-1 downto 0);
            i_D0    : in std_logic_vector(K_WIDTH-1 downto 0);
            o_data  : out std_logic_vector(K_WIDTH-1 downto 0);
            o_sel   : out std_logic_vector(3 downto 0);
            i_clk   : in std_logic
        );
    end component;

    component sevenseg_decoder
        port (
            i_hex : in  std_logic_vector(3 downto 0);
            o_seg_n : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    clkdiv_inst : clock_divider
        generic map (K_DIV => 50000000)
        port map (
            i_clk   => clk,
            i_reset => btnU,
            o_clk   => slow_clk
        );

    process(clk)
    begin
        if rising_edge(clk) then
            btnC_sync_0 <= btnC;
            btnC_sync_1 <= btnC_sync_0;
            btnC_edge   <= btnC_sync_0 and not btnC_sync_1;  -- rising edge detector
        end if;
    end process;

    fsm_inst : controller_fsm
        port map (
            i_reset => btnU,
            i_adv   => btnC_edge,
            o_cycle => cycle
        );

    operand_A <= sw(7 downto 0) when cycle(1) = '1' else (others => '0');
    operand_B <= sw(7 downto 0) when cycle(2) = '1' else (others => '0');

    alu_inst : ALU
        port map (
            i_A      => operand_A,
            i_B      => operand_B,
            i_op     => sw(2 downto 0),
            o_result => alu_result,
            o_flags  => alu_flags
        );

    twos_compliment_inst : twos_comp
        port map (
            i_bin  => alu_result,
            o_sign => sign,
            o_hund => hundreds,
            o_tens => tens,
            o_ones => ones
        );

    signed_digit <= "1111" when sign = '1' else "0000";
    
    -- TDM4 display
    tdm_inst : TDM4
    generic map (K_WIDTH => 4)
    port map (
        i_D3   => signed_digit,
        i_D2   => hundreds,
        i_D1   => tens,
        i_D0   => ones,
        o_data => display_data,
        o_sel  => sel,
        i_clk  => slow_clk
    );


    seg_inst : entity work.sevenseg_decoder
    port map (
        i_Hex => display_data,    
        o_seg_n => seg_value     
    );


    -- One-hot digit enable logic based on TDM4 output
    -- One-hot enable based on TDM4 selector
    with sel select
        an_pre <= "1110" when "00",
                  "1101" when "01",
                  "1011" when "10",
                  "0111" when "11",
                  "1111" when others;
    
    -- Apply blanking for FSM cycle 3
    an <= "1111" when cycle = "1000" else an_pre;
    
    -- Blanking the segment output for FSM cycle 3
    seg <= "1111111" when cycle = "1000" else seg_value;

led(0) <= slow_clk;
led(8 downto 1) <= alu_result;

    
end top_basys3_arch;


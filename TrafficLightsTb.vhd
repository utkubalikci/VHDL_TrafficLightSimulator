library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TrafficLightsTb is
end entity;

architecture sim of TrafficLightsTb is

    -- We're slowing down the clock to speed up simulation time
    constant ClockFrequencyHz : integer := 100; -- 100 Hz
    constant ClockPeriod      : time    := 1000 ms / ClockFrequencyHz;

    signal Clk              : std_logic := '1';
    signal nRst             : std_logic := '0';
    signal VerticalRed      : std_logic;
    signal VerticalYellow   : std_logic;
    signal VerticalGreen    : std_logic;
    signal HorizontalRed    : std_logic;
    signal HorizontalYellow : std_logic;
    signal HorizontalGreen  : std_logic;
    signal CrosswalkGreen   : std_logic;
    signal CrosswalkRed     : std_logic;

begin

    -- The Device Under Test (DUT)
    i_TrafficLights : entity work.TrafficLights(rtl)
    generic map(ClockFrequencyHz => ClockFrequencyHz)
    port map(Clk              => Clk,
             nRst             => nRst,
             VerticalRed      => VerticalRed,
             VerticalYellow   => VerticalYellow,
             VerticalGreen    => VerticalGreen,
             HorizontalRed    => HorizontalRed,
             HorizontalYellow => HorizontalYellow,
             HorizontalGreen  => HorizontalGreen,
             CrosswalkGreen   => CrosswalkGreen,
             CrosswalkRed     => CrosswalkRed);

    -- Process for generating the clock
    Clk <= not Clk after ClockPeriod / 2;

    -- Testbench sequence
    process is
    begin
        wait until rising_edge(Clk);
        wait until rising_edge(Clk);

        -- Take the DUT out of reset
        nRst <= '1';

        wait;
    end process;

end architecture;
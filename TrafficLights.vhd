library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TrafficLights is
generic(ClockFrequencyHz : integer);
port(
    Clk               : in std_logic;
    nRst              : in std_logic; -- Negative reset
    VerticalRed       : out std_logic;
    VerticalYellow    : out std_logic;
    VerticalGreen     : out std_logic;
    HorizontalRed     : out std_logic;
    HorizontalYellow  : out std_logic;
    HorizontalGreen   : out std_logic;
    CrosswalkGreen    : out std_logic;
    CrosswalkRed      : out std_logic);
end entity;

architecture rtl of TrafficLights is

    -- Calculate the number of clock cycles in minutes/seconds
    function CounterVal(Minutes : integer := 0;
                        Seconds : integer := 0) return integer is
        variable TotalSeconds : integer;
    begin
        TotalSeconds := Seconds + Minutes * 60;
        return TotalSeconds * ClockFrequencyHz -1;
    end function;

    -- Enumerated type declaration and state signal declaration
    type t_State is (VerticalNext, StartVertical, Vertical, StopVertical,
                        HorizontalNext, StartHorizontal, Horizontal, StopHorizontal, Crosswalk, StopCrosswalk);
    signal State : t_State;

    -- Counter for counting clock periods, 1 minute max
    signal Counter : integer range 0 to ClockFrequencyHz * 60;

begin

    process(Clk) is
    begin
        if rising_edge(Clk) then
            if nRst = '0' then
                -- Reset values
                State           <= VerticalNext;
                Counter         <= 0;
                VerticalRed     <= '1';
                VerticalYellow  <= '0';
                VerticalGreen   <= '0';
                HorizontalRed   <= '1';
                HorizontalYellow<= '0';
                HorizontalGreen <= '0';
                CrosswalkGreen  <= '0';
                CrosswalkRed    <= '1';

            else
                -- Default values
                VerticalRed      <= '0';
                VerticalYellow   <= '0';
                VerticalGreen    <= '0';
                HorizontalRed    <= '0';
                HorizontalYellow <= '0';
                HorizontalGreen  <= '0';
                CrosswalkGreen   <= '0';
                CrosswalkRed     <= '1';

                Counter <= Counter + 1;

                case State is

                    -- Red in all directions
                    when VerticalNext =>
                        VerticalRed     <= '1';
                        HorizontalRed   <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= Crosswalk;
                        end if;
                        
                    -- Red for all vehicles and Green for crosswalk
                    when Crosswalk =>
                        VerticalRed    <= '1';
                        HorizontalRed  <= '1';
                        CrosswalkGreen <= '1';
                        CrosswalkRed   <= '0';
                        -- If 20 seconds have passed
                        if Counter = CounterVal(Seconds => 20) then
                            Counter <= 0;
                            State   <= StopCrosswalk;
                        end if;
                            
                    -- Red in all directions
                    when StopCrosswalk =>
                        VerticalRed    <= '1';
                        HorizontalRed  <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= StartVertical;
                        end if;

                    -- Red and yellow in Vertical/south direction
                    when StartVertical =>
                        VerticalRed    <= '1';
                        VerticalYellow <= '1';
                        HorizontalRed     <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= Vertical;
                        end if;

                    -- Green in Vertical/south direction
                    when Vertical =>
                        VerticalGreen <= '1';
                        HorizontalRed    <= '1';
                        -- If 1 minute has passed
                        if Counter = CounterVal(Minutes => 1) then
                            Counter <= 0;
                            State   <= StopVertical;
                        end if;

                    -- Yellow in Vertical/south direction
                    when StopVertical =>
                        VerticalYellow <= '1';
                        HorizontalRed     <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= HorizontalNext;
                        end if;

                    -- Red in all directions
                    when HorizontalNext =>
                        VerticalRed <= '1';
                        HorizontalRed  <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= StartHorizontal;
                        end if;

                    -- Red and yellow in Horizontal/east direction
                    when StartHorizontal =>
                        VerticalRed   <= '1';
                        HorizontalRed    <= '1';
                        HorizontalYellow <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= Horizontal;
                        end if;

                    -- Green in Horizontal/east direction
                    when Horizontal =>
                        VerticalRed  <= '1';
                        HorizontalGreen <= '1';
                        -- If 1 minute has passed
                        if Counter = CounterVal(Minutes => 1) then
                            Counter <= 0;
                            State   <= StopHorizontal;
                        end if;

                    -- Yellow in Horizontal/east direction
                    when StopHorizontal =>
                        VerticalRed   <= '1';
                        HorizontalYellow <= '1';
                        -- If 5 seconds have passed
                        if Counter = CounterVal(Seconds => 5) then
                            Counter <= 0;
                            State   <= VerticalNext;
                        end if;

                end case;

            end if;
        end if;
    end process;

end architecture;
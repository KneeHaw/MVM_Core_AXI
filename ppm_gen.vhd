-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: Network_Detection.vhd                                          --
-- Author: Phillip Jones (phjones@iastate.edu)                               --
-- Date: 2/1/2018                                                            --
--                                                                           --
-- Description: Example network data string identifier                       --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
entity ppm_gen is
    port (
        sysclk : in std_logic; -- system clock
        reset : in std_logic; -- reset registers and counters
        max_frame_cycles : in std_logic_vector(31 downto 0);
        max_wait_cycles : in std_logic_vector(31 downto 0);
        pulse_1_cycles : in std_logic_vector(31 downto 0);
        pulse_2_cycles : in std_logic_vector(31 downto 0);
        pulse_3_cycles : in std_logic_vector(31 downto 0);
        pulse_4_cycles : in std_logic_vector(31 downto 0);
        pulse_5_cycles : in std_logic_vector(31 downto 0);
        pulse_6_cycles : in std_logic_vector(31 downto 0);
        data : out std_logic;
        finished_frames : out std_logic_vector(31 downto 0)
    );
end ppm_gen;

architecture foo of ppm_gen is

    ----------------------------------------------
    --       Component declarations             --
    ----------------------------------------------

    -- None

    ----------------------------------------------
    --          Signal declarations             --
    ----------------------------------------------

    -- Declare types
    type STATE_TYPE is (IDLE, WAITING, PCOUNT, ERROR);

    -- signals
    signal current_state : STATE_TYPE; -- current state
    signal next_state : STATE_TYPE; -- next state


    signal state_over_flag : std_logic;
    signal wait_cycle_counter : std_logic_vector(31 downto 0); -- 
    signal pulse_cycle_counter : std_logic_vector(31 downto 0); -- 
    signal all_cycle_counter : std_logic_vector(31 downto 0); -- 
    signal pulse_counter : std_logic_vector(2 downto 0);
    signal finframes : std_logic_vector(31 downto 0);
begin
    -- Processes --

    ------------------------------------------------------------
    ------------------------------------------------------------
    --                                                        --
    -- Process Name: UPDATE_state                             --
    -- Description: Assign next state to current state        --
    --                                                        --
    ------------------------------------------------------------
    ------------------------------------------------------------
    UPDATE_state : process (sysclk)
    begin
        if (sysclk = '1' and sysclk'event) then
            if (reset = '0') then
                current_state <= WAITING;
            else
                current_state <= next_state;
            end if;
        end if;

    end process UPDATE_state;


    next_state_logic: process (current_state, pulse_counter, state_over_flag)
    begin
    -- TODO: add flags for stable state transitions
    -- defaults
        next_state <= current_state;
        -- change to cases
        case current_state is

          when IDLE =>
            if (state_over_flag = '1') then
                next_state <= WAITING;
            end if;
    
          when WAITING =>
            if (state_over_flag = '1') then
                if (pulse_counter = b"111") then
                    next_state <= IDLE;
                else 
                    next_state <= PCOUNT;
                end if;
            end if;
    
          when PCOUNT =>
            if (state_over_flag = '1') then
                next_state <= WAITING;
            end if;
    
          when others =>
            next_state <= WAITING;
        end case;
    end process;


    abomination_counter : process (sysclk)
    begin
        if (rising_edge(sysclk)) then
            if (reset = '0') then 
                pulse_cycle_counter <= (others => '0');
                state_over_flag <= '0';
                pulse_counter <= (others => '0');
                wait_cycle_counter <= (others => '0');
                finframes <= (others => '0');
                all_cycle_counter <= (others => '0');
            else
                if (all_cycle_counter < max_frame_cycles) then
                    all_cycle_counter <= all_cycle_counter + '1';
                    state_over_flag <= '0';
                else
                    finframes <= finframes + '1';
                    pulse_counter <= (others => '0');
                    all_cycle_counter <= (others => '0');
                    state_over_flag <= '1';
                end if;
                
                case current_state is 
                    when PCOUNT =>
                        if (pulse_counter = b"001") then
                            if (pulse_cycle_counter < pulse_1_cycles) then
                                pulse_cycle_counter <= pulse_cycle_counter + 1;
                                state_over_flag <= '0';
                            else
                                pulse_cycle_counter <= (others => '0');
                                state_over_flag <= '1';
                            end if;
                        elsif (pulse_counter = b"010") then
                            if (pulse_cycle_counter < pulse_2_cycles) then
                                pulse_cycle_counter <= pulse_cycle_counter + 1;
                                state_over_flag <= '0';
                            else
                                pulse_cycle_counter <= (others => '0');
                                state_over_flag <= '1';
                            end if;
                        elsif (pulse_counter = b"011") then
                            if (pulse_cycle_counter < pulse_3_cycles) then
                                pulse_cycle_counter <= pulse_cycle_counter + 1;
                                state_over_flag <= '0';
                            else
                                pulse_cycle_counter <= (others => '0');
                                state_over_flag <= '1';
                            end if;
                        elsif (pulse_counter = b"100") then
                            if (pulse_cycle_counter < pulse_4_cycles) then
                                pulse_cycle_counter <= pulse_cycle_counter + 1;
                                state_over_flag <= '0';
                            else
                                pulse_cycle_counter <= (others => '0');
                                state_over_flag <= '1';
                            end if;
                        elsif (pulse_counter = b"101") then
                            if (pulse_cycle_counter < pulse_5_cycles) then
                                pulse_cycle_counter <= pulse_cycle_counter + 1;
                                state_over_flag <= '0';
                            else
                                pulse_cycle_counter <= (others => '0');
                                state_over_flag <= '1';
                            end if;
                        elsif (pulse_counter = b"110") then
                            if (pulse_cycle_counter < pulse_6_cycles) then
                                pulse_cycle_counter <= pulse_cycle_counter + 1;
                                state_over_flag <= '0';
                            else
                                pulse_cycle_counter <= (others => '0');
                                state_over_flag <= '1';
                            end if;
                        end if;
                    when WAITING =>
                        if (wait_cycle_counter < max_wait_cycles) then
                            wait_cycle_counter <= wait_cycle_counter + 1;
                            state_over_flag <= '0';
                        else
                            state_over_flag <= '1';
                            pulse_counter <= pulse_counter + '1';
                            wait_cycle_counter <= (others => '0');
                        end if;
                    when others =>
                        state_over_flag <= '0';
                        wait_cycle_counter <= wait_cycle_counter;
                        pulse_cycle_counter <= pulse_cycle_counter;
                end case;
            end if;
        end if;
    end process abomination_counter;

    manage_data_out : process (next_state)
    begin
        data <= '0';
        case next_state is
          when IDLE =>
            data <= '1';
          when PCOUNT =>
            data <= '1';
          when WAITING =>
            data <= '0';
          when others =>
            data <= '0';
        end case;
    end process manage_data_out;

    finished_frames <= finframes;
end foo;
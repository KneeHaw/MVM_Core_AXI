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

entity ppm_read is
  port (
    sysclk           : in  std_logic; -- system clock
    reset            : in  std_logic; -- reset registers and coutners
    data             : in  std_logic;
    -- max_pulse_cycles : in  std_logic_vector(31 downto 0);
    max_frame_cycles : in  std_logic_vector(31 downto 0);
    -- max_wait_cycles  : in  std_logic_vector(31 downto 0);
    pulse_1_cycles   : out std_logic_vector(31 downto 0);
    pulse_2_cycles   : out std_logic_vector(31 downto 0);
    pulse_3_cycles   : out std_logic_vector(31 downto 0);
    pulse_4_cycles   : out std_logic_vector(31 downto 0);
    pulse_5_cycles   : out std_logic_vector(31 downto 0);
    pulse_6_cycles   : out std_logic_vector(31 downto 0);
    finished_frames  : out std_logic_vector(31 downto 0)
  );
end entity;

architecture foo of ppm_read is

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
  signal next_state    : STATE_TYPE; -- next state

  -- signal wait_cycle_start   : std_logic_vector(31 downto 0); -- value at which wait starts
  signal pcount_cycle_start : std_logic_vector(31 downto 0); -- value at which pcount starts

  signal fin_frames : std_logic_vector(31 downto 0);
  signal frame_cycle_counter : std_logic_vector(31 downto 0); -- which clock cycle are we on in a given frame
  signal pulse_counter       : std_logic_vector(2 downto 0);  -- which pulse / 6 are we on in a given frame
  -- signal state_cycle_counter : std_logic_vector(31 downto 0); -- all_cycle - cycle_start
  signal stable_samples : std_logic_vector(4 downto 0);
  signal stable_counter : std_logic_vector(4 downto 0);
  signal stable_high : std_logic;
  signal stable_low : std_logic;

  signal interstate_low2high : std_logic;
  signal interstate_high2low : std_logic;
  
    signal pulse_1_cyclest   :  std_logic_vector(31 downto 0);
    signal pulse_2_cyclest   : std_logic_vector(31 downto 0);
    signal pulse_3_cyclest   : std_logic_vector(31 downto 0);
    signal pulse_4_cyclest   : std_logic_vector(31 downto 0);
    signal pulse_5_cyclest   : std_logic_vector(31 downto 0);
    signal pulse_6_cyclest   : std_logic_vector(31 downto 0);
  
  signal transition_catch : std_logic;

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
  UPDATE_state: process (sysclk)
  begin
    if (sysclk = '1' and sysclk'event) then
      if (reset = '0') then
        current_state <= IDLE;
      else
        current_state <= next_state;
      end if;
    end if;

  end process;

  FRAME_counter: process (sysclk)
  begin
    if (sysclk = '1' and sysclk'event) then
        if (reset = '0') then
            frame_cycle_counter <= (others => '0');
            fin_frames <= (others => '0');
            pulse_counter <= (others => '0');
            pcount_cycle_start <= (others => '0');
            pulse_1_cyclest <= (others => '0');
            pulse_2_cyclest <= (others => '0');
            pulse_3_cyclest <= (others => '0');
            pulse_4_cyclest <= (others => '0');
            pulse_5_cyclest <= (others => '0');
            pulse_6_cyclest <= (others => '0');
        else
            if (frame_cycle_counter < max_frame_cycles) then
                frame_cycle_counter <= frame_cycle_counter + '1';
                if (transition_catch = '1') then
                    if (next_state = PCOUNT) then
                        pcount_cycle_start <= frame_cycle_counter;
                        pulse_counter <= pulse_counter + 1;
                    elsif (next_state = IDLE) then 
                        pulse_counter <= (others => '0');
                    elsif (next_state = WAITING) then
                        if (pulse_counter = b"001") then
                          pulse_1_cyclest <= frame_cycle_counter - pcount_cycle_start;
                        elsif (pulse_counter = b"010") then
                          pulse_2_cyclest <= frame_cycle_counter - pcount_cycle_start;
                        elsif (pulse_counter = b"011") then
                          pulse_3_cyclest <= frame_cycle_counter - pcount_cycle_start;
                        elsif (pulse_counter = b"100") then
                          pulse_4_cyclest <= frame_cycle_counter - pcount_cycle_start;
                        elsif (pulse_counter = b"101") then
                          pulse_5_cyclest <= frame_cycle_counter - pcount_cycle_start;
                        elsif (pulse_counter = b"110") then
                          pulse_6_cyclest <= frame_cycle_counter - pcount_cycle_start;
                        end if;
                    end if;
                end if;
            else
                fin_frames <= fin_frames + '1';
                frame_cycle_counter <= (others => '0');
            end if;
        end if;
      
    end if;
  end process;

  ------------------------------------------------------------
  ------------------------------------------------------------
  --                                                        --
  -- Process Name: state_transitions                        --
  -- Description: Transition various states                 --
  ------------------------------------------------------------
  ------------------------------------------------------------

  interstate_initiate: process (current_state, data, interstate_high2low, interstate_low2high)
  begin
    interstate_high2low <= '0';
    interstate_low2high <= '0';

    case current_state is

      when IDLE =>
        if (data = '0') then
          interstate_high2low <= '1';
        end if;

      when WAITING =>
        if (data = '1') then
          interstate_low2high <= '1';
        end if;

      when PCOUNT =>
        if (data = '0') then
          interstate_high2low <= '1';
        end if;

      when others =>
        interstate_high2low <= '0';
        interstate_low2high <= '0';

    end case;
  end process;

  next_state_logic: process (current_state, pulse_counter, stable_high, stable_low, interstate_high2low, interstate_low2high)
  begin
    -- TODO: add flags for stable state transitions
    -- defaults
    next_state <= current_state;
    transition_catch <= '0';

    if (interstate_high2low = '1') then
      if (stable_low = '1') then
        transition_catch <= '1';
        next_state <= WAITING;
      end if;

    elsif (interstate_low2high = '1') then
      if (stable_high = '1') then
        transition_catch <= '1';
        -- if ((frame_cycle_counter - wait_cycle_start) > max_wait_cycles) then
        --   next_state <= ERROR;
        if (pulse_counter = 6) then
          next_state <= IDLE;
        else
          next_state <= PCOUNT;
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------
  ------------------------------------------------------------
  --                                                        --
  -- Process Name: stability_flag_counter                   --
  -- Description: Confirm a stable state transition         --
  --              has actually occured                      --
  ------------------------------------------------------------
  ------------------------------------------------------------

    -- rid myself of all but clock
  stability_flag_counter: process (sysclk, data, stable_counter, stable_samples, stable_low, stable_high)
  begin
    if rising_edge(sysclk) then
        if (reset = '0') then
            stable_counter <= (others => '0');
            stable_samples <= (others => '0');
            -- add stable low/high reset
        else
            if stable_samples < 31 then
                if (data = '1') then
                    stable_samples <= stable_samples + 1;
                    stable_counter <= stable_counter + 1;
                elsif (data = '0') then
                    stable_samples <= stable_samples + 1;
                    stable_counter <= stable_counter ;
                end if;
            else
                if stable_counter > 26 then
                    stable_high <= '1';
                    stable_low <= '0';
                elsif (stable_counter < 5) then 
                    stable_low <= '1';
                    stable_high <= '0';
                end if;
                stable_counter <= (others => '0');
                stable_samples <= (others => '0');
            end if;
        end if;
    end if;
  end process;

  ------------------------------------------------------------
  ------------------------------------------------------------
  --                                                        --
  -- Process Name: stability_flag_setter                    --
  -- Description:  Setting flags for transitsions           --
  ------------------------------------------------------------
  ------------------------------------------------------------

--  stability_flag_setter: process (sysclk, flag_counter_ready, stable_samples)
--  begin
--    if rising_edge(sysclk) then
--        if (reset = '1') then
--            flag_counter_ready <= '0';
--            stable_low <= '0';
--            stable_high <= '0';
--        else
--            if (flag_counter_ready = '1') then
--                if stable_counter > 26 then
--                  stable_high <= '1';
--                elsif (stable_counter < 5) then 
--                  stable_low <= '1';
--                end if;
--                flag_counter_ready <= '0';
--                stable_samples <= (others => '0');
--                stable_counter <= (others => '0');
--            else
--                flag_counter_ready <= flag_counter_ready;
--            end if;
--        end if;
--    end if;
    
--  end process;
--if rising_edge(sysclk) then
--        if (reset = '1') then
        
--        else
        
--        end if;
--    end if;
  ------------------------------------------------------------
  ------------------------------------------------------------
  --                                                        --
  -- Process Name:Manage_Cnt_Reg                            --
  -- Description: Manage counters and registers             --
  --                                                        --
  ------------------------------------------------------------
  ------------------------------------------------------------

  -- Combinational assignments --
  --alert_cnt_out <= alert_cnt;   -- Send alert_counter to output
  finished_frames <= fin_frames;
  pulse_1_cycles <= pulse_1_cyclest;
  pulse_2_cycles <= pulse_2_cyclest;
  pulse_3_cycles <= pulse_3_cyclest;
  pulse_4_cycles <= pulse_4_cyclest;
  pulse_5_cycles <= pulse_5_cyclest;
  pulse_6_cycles <= pulse_6_cyclest;

  -- Wire up components
  -- None
end architecture;

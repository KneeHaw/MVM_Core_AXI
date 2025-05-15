-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: mvm_accelerator_tb.vhd                                         --
-- Author: Ethan Rogers (kneehaw@iastate.edu)                                --
-- Date: 5/14/2025                                                           --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.STD_LOGIC_ARITH.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;

entity mvm_accelerator_tb is
  port (
    my_in : in std_logic 
  );
end entity;

architecture rtl of mvm_accelerator_tb is

 component mvm_accelerator is
		generic (
			D : integer := 1024; -- size of data stream
			N : integer := 32;   -- core dimension (N x N)
			Y : integer := 32;   --number of cores = D / N
			M : integer := 8     -- Size of col outputs
		);
		port (
			sysclk  : in std_logic; -- system clock
			reset   : in std_logic; -- reset registers and coutners
			data_in : in std_logic_vector(D - 1 downto 0);
			
			transfer_in : in std_logic;
            transfer_out : in std_logic;
            
			loadw_i  : in std_logic_vector(Y - 1 downto 0);
			read_cmd : in std_logic;

            readout_complete : out std_logic;
			data_out : out std_logic_vector(D - 1 downto 0)
		);
	end component mvm_accelerator;

  type my_input_states is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11,
                           S12, S13, S14, S15, STOP_TEST);
  signal input_state : my_input_states; -- Direct which input vector to use
  signal clock_counter : integer;

  signal data_in_s : std_logic_vector(1023 downto 0);
  signal clk   : std_logic;
  signal reset : std_logic;
  signal transfer_in_s : std_logic;
  signal transfer_out_s : std_logic;
  signal loadw_i_s  : std_logic_vector(32 - 1 downto 0);
  signal read_cmd_s : std_logic;
  signal readout_complete_s : std_logic;
  signal data_out_s : std_logic_vector(1023 downto 0);
  
begin

  -- Processes
  system_clk_gen: process
  begin
    clk <= '0';
    wait for 10 ns;
    loop
      wait for 1 ns;
      clk <= '1';
      wait for 1 ns;
      clk <= '0';
    end loop;
  end process;


  toggle_reset: process
  begin
    reset <= '1';
    wait for 95 ns;
    reset <= '0';
    wait;
  end process;

  DUT_stimulus: process (clk)
  begin
    if (clk = '1' and clk'event) then

      -- Initialize the test
      if (reset = '1') then
        input_state <= S0;
        clock_counter <= 0;
      else
        clock_counter <= clock_counter + 1;
        
        case input_state is  -- reset state, wait for at least first 32 cycles
        
          -- Place system into a defaulted state
          when S0 =>
            data_in_s <= (others => '0'); -- default in to 0
            transfer_in_s <= '0';
            transfer_out_s <= '0';
            loadw_i_s <= (others => '0'); -- default load no weights
            read_cmd_s <= '0';
            if clock_counter >= 32 then
                input_state <= S1;
            end if;
            
          -- Load weights of '1' into select cores
          when S1 =>
            data_in_s <= (others => '1');
            transfer_in_s <= '1';
            loadw_i_s <= x"F00F00FF";  -- load weights into cores (0-3, 12-15, 23-31)
            if clock_counter >= 36 then
                input_state <= S2;
            end if;
            
          -- 
--          when S2 =>
--            data_in_s <= (others => '1'); -- default in to 0
--            transfer_in_s <= '1';
--            loadw_i_s <= x"F00F00FF";  -- load weights into cores (0-3, 12-15, 23-31)
--            if clock_counter >= 40 then
--                input_state <= S3;
--            end if;
            
          when S3 =>
            data_in_s <= (others => '0'); -- default in to 0
            transfer_in_s <= '0';
            transfer_out_s <= '1';
            loadw_i_s <= (others => '0'); -- default load no weights
            read_cmd_s <= '1';
            if readout_complete_s = '1' then
                input_state <= STOP_TEST;
            end if;
        
          when others =>
            input_state <= STOP_TEST;
          end case;
      end if;
    end if;
  end process;

  -- Connect DUT to the testbench
  my_dut: mvm_accelerator
    port map (
        sysclk => clk,
        reset => reset,
        data_in => data_in_s,
        transfer_in => transfer_in_s,
        transfer_out => transfer_out_s,
        loadw_i => loadw_i_s,
        read_cmd => read_cmd_s,
        readout_complete => readout_complete_s,
        data_out => data_out_s
    );

end architecture;

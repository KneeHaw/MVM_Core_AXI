-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: mvm_core.vhd                                                   --
-- Author: Ethan Rogers (kneehaw@iastate.edu)                                --
-- Date: 5/12/2025                                                           --
--                                                                           --
-- Description: N x N binary MVM core implementation, N-state output         --
-- Type: CLOCKED                                                             --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.STD_LOGIC_ARITH.all;
    use IEEE.STD_LOGIC_UNSIGNED.all;

entity mvm_NxN is
    generic (
        D       : integer := 1024; -- Data stream size
        N       : integer := 32;
        core_id : integer := 0 -- Assigned by upper level component
    );
    port (
        sysclk : in std_logic;                        -- system clock
        reset  : in std_logic;                        -- reset registers and coutners
        input  : in std_logic_vector(D - 1 downto 0); -- Input data stream of size D

        read_complete : in std_logic;
        new_data      : in std_logic;
        loadw         : in std_logic;

        busy   : out std_logic;
        done   : out std_logic;
        output : out std_logic_vector(N * N - 1 downto 0)
    );

end entity;

architecture mvm_core of mvm_NxN is

    component mvm_wcell
        port (
            X      : in std_logic;
            W      : in std_logic;
            sysclk : in std_logic;
            reset  : in std_logic;
            loadw  : in std_logic;

            result : out std_logic
        );
    end component;

    type STATE_TYPE is (IDLE, LOADING_W, DONE_STATE);

    signal current_state : STATE_TYPE; -- current state
    signal next_state    : STATE_TYPE; -- next state

    signal input_vector  : std_logic_vector(N - 1 downto 0);
    signal weight_matrix : std_logic_vector(N * N - 1 downto 0);

    signal cell_outputs : std_logic_vector(N * N - 1 downto 0);

begin

    -- Map weights [vector] to weight_matrix [matrix_2D]
    gen_weight_map : for idx in 0 to N * N - 1 generate
    begin
        weight_matrix(idx) <= input(idx);
    end generate;

    -- Generate core matrix
    gen_rows : for i in 0 to N - 1 generate -- Rows
        gen_cols : for j in 0 to N - 1 generate -- Columns
            cell_inst : mvm_wcell
            port map(
                X      => input(core_id * N + i),
                W      => weight_matrix(i * N + j),
                sysclk => sysclk,
                reset  => reset,
                loadw  => loadw,
                result => cell_outputs(i * N + j)
            );
        end generate;
    end generate;

    -- State machine for controller
    UPDATE_state : process (sysclk)
    begin
        if (sysclk = '1' and sysclk'event) then
            if (reset = '0') then
                current_state <= IDLE;
                busy          <= '0';
                done          <= '0';

            else
                current_state <= next_state;
                case current_state is
                    
                    when IDLE =>
                        busy <= '0';
                        done <= '0';

                    when LOADING_W =>
                        busy <= '1';
                        done <= '0';

                    when DONE_STATE =>
                        busy <= '0';
                        done <= '1';

                    when others =>
                        current_state <= IDLE;

                end case;
            end if;
        end if;
    end process;

    -- Next state logic
    NEXT_state_logic : process (current_state, loadw, new_data, read_complete)
    begin
        next_state <= current_state;

        case current_state is
            when IDLE =>
                if (loadw = '1' and new_data = '1') then
                    next_state <= LOADING_W;
                end if;

            when LOADING_W =>
                if (new_data = '1') then
                    next_state <= DONE_STATE;
                end if;

            when DONE_STATE =>
                if (read_complete = '1') then
                    next_state <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- Connect output
    output <= cell_outputs;

end mvm_core;

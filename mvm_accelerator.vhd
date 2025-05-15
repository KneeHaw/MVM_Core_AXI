-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: mvm_accelerator.vhd                                            --
-- Author: Ethan Rogers (kneehaw@iastate.edu)                                --
-- Date: 5/12/2025                                                           --
--                                                                           --
-- Description: contains Y (N x N) binary MVM cores                             --
-- Type: CLOCKED                                                             --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.STD_LOGIC_ARITH.all;
    use IEEE.STD_LOGIC_UNSIGNED.all;

entity mvm_accelerator is
    generic (
        D : integer := 1024; -- size of data stream
        N : integer := 32;
        Y : integer := 32; --number of cores = D / N
        M : integer := 8
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

end entity;

 architecture mvm_cores of mvm_accelerator is

    constant C : integer := 128; -- number of col adders

    component mvm_NxN is
        generic (
            D       : integer := D; -- Data stream size
            N       : integer := N;
            core_id : integer -- Assigned by upper level component
        );
        port (
            sysclk        : in std_logic;                        -- system clock
            reset         : in std_logic;                        -- reset registers and coutners
            input         : in std_logic_vector(D - 1 downto 0); -- Input data stream of size D
            read_complete : in std_logic;
            new_data      : in std_logic;
            loadw         : in std_logic;
            busy          : out std_logic;
            done          : out std_logic;
            output        : out std_logic_vector(N * N - 1 downto 0)
        );
    end component;

    component mvm_col_add is
        generic (
            N : integer := N;
            M : integer := 8
        );
        port (
            input  : in std_logic_vector(N - 1 downto 0);
            output : out std_logic_vector(8 - 1 downto 0)
        );
    end component;

    type STATE_TYPE is (IDLE, SENDING);  -- Idle allows weight load lower in hierarchy
    signal current_state : STATE_TYPE; -- current state
    signal next_state    : STATE_TYPE; -- next state
    signal core_cell_outs : std_logic_vector(Y * N * N - 1 downto 0);
    signal send_valid   : std_logic;
    signal col_vectors   : std_logic_vector(C * N - 1 downto 0);
    signal col_outputs   : std_logic_vector(C * M - 1 downto 0);
    signal done_i        : std_logic_vector(Y - 1 downto 0);
    signal busy_i        : std_logic_vector(Y - 1 downto 0);
    signal new_data_s    : std_logic;
    signal read_complete : std_logic;
    signal read_counter  : integer range 0 to M; --Read NxY M times
begin
    gen_mvm_cores : for i in 0 to Y - 1 generate -- Y cores
        -- Generate core matrix
        add_inst : mvm_NxN
        generic map(
            core_id => i
        )
        port map(
            sysclk        => sysclk,
            reset         => reset,
            input         => data_in,
            new_data      => new_data_s,
            loadw         => loadw_i(i),
            busy          => busy_i(i),
            done          => done_i(i),
            read_complete => read_complete,
            output      => core_cell_outs((i + 1) * N * N - 1 downto i * N * N)
        );
    end generate;

    gen_col_add : for i in 0 to C - 1 generate -- Column adders
        add_inst : mvm_col_add
        port map(
            input  => col_vectors((i + 1) * N - 1 downto i * N), -- All rows of column i
            output => col_outputs((i + 1) * M - 1 downto i * M)  -- populate byte output i
        );
    end generate;

    UPDATE_state : process (sysclk)
    begin
        if (sysclk = '1' and sysclk'event) then
            if (reset = '0') then
                current_state <= IDLE;

            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    NEXT_state_logic : process (current_state, read_cmd, loadw_i, read_counter)
    begin
        next_state <= current_state;
        read_complete <= '0';
        case current_state is
            when IDLE =>
                if (read_cmd = '1' and unsigned(loadw_i) = 0) then
                    next_state <= SENDING;
                end if;

            when SENDING =>
                if (read_counter >= 7) then
                    read_complete <= '1';
                    next_state    <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    output_logic : process (sysclk)
    begin
        if (sysclk = '1' and sysclk'event) then
            if (reset = '0') then
                data_out <= (others => '0');
            else
                case current_state is
                    when IDLE =>
                        data_out      <= (others => '0');

                    when SENDING =>
                        -- Only initiate data transfer out if data will be accepted.
                        if (send_valid ='1') then
                            for core_idx in read_counter * 4 to read_counter * 4 + 3 loop -- Cores
                                for i in 0 to N - 1 loop                                      -- Columns
                                    for j in 0 to N - 1 loop                                      -- Rows
                                        col_vectors(i * N + j) <= core_cell_outs(core_idx * N * N + j * N + i);
                                    end loop;
                                end loop;
                                read_counter <= read_counter + 1;
                            end loop;
                        end if;

                    when others         =>
                        data_out <= (others => '0');

                end case;
            end if;
        end if;
    end process;

    readout_complete <= read_complete;
    send_valid <= transfer_out;
    new_data_s <= transfer_in;
    data_out     <= col_outputs;

end mvm_cores;

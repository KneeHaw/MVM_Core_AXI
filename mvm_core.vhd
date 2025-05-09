library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.STD_LOGIC_ARITH.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;

library CUSTOM;
    use CUSTOM.custom_types.all;

entity mvm_NxN is
    generic(
		N : integer := 32
	);	
    port (
        sysclk           : in  std_logic; -- system clock
        reset            : in  std_logic; -- reset registers and coutners
        input            : in  std_logic_vector(N-1 downto 0);
        weights          : in  2D_matrix(N-1 downto 0)(N-1 downto 0);
        output           : out std_logic_vector(N-1 downto 0)
    );

end entity;

architecture mvm_core of mvm_NxN is

    type STATE_TYPE is (IDLE, RUNNNING);
    signal current_state : STATE_TYPE; -- current state
    signal next_state    : STATE_TYPE; -- next state

    signal compute_flag : std_logic;


begin


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

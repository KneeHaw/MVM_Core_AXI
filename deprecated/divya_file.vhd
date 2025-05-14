-- takes in input (image and weights 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mvm_weights is
    generic (
        N : integer := 64
    );
    port (
        X :       in std_logic_vector(N-1 downto 0); --64
        W :       in std_logic_vector((N*N-1) downto 0); --64^2
        sysclk:   in std_logic;
        reset:    in std_logic;
        in_flag:  in std_logic;

        results:     out std_logic_vector((N*N-1) downto 0);
        out_flag: out std_logic
    );
end mvm_weights;


-- read in weights 
architecture Calculations of mvm_weights is
    --store results?

-- can define popcount as a VHDL function 
function popcount (v: std_logic_vector) return integer is
    variable count: integer range 0 to N;
begin
    for i in v'range loop
        if v(i) = '1' then
            count := count + 1;
        end if;
    end loop;
    return count;
end function popcount;


begin -- W and X not in sens. list bc they don't change (?)
    mvm_mult: process(sysclk, reset) is
        variable row : integer; -- get the correct N bits from weights
        variable xor_result: std_logic_vector (N-1 downto 0); --store xor
        variable xor_temp :std_logic_vector (NN-1 downto 0);
        variable pop : integer; --store popct


        begin
            if (sysclk = '1' and sysclk'event) then
                if reset = '1' then
                    results <= (others => '0');
                else
                    for row in 0 to N-1 loop
                        xor_result := X xor W((row+1)N -1 downto rowN); -- just getting the N bits from the weight matrix and XORing them
                        -- not doing the N-2xsum or popcount stuff anymore bc using mux-like thing instead
                        xor_temp((row+1)N -1 downto row*N) <= xor_result;
                    end loop; 
                end if;
            end if;
    end process some_proc;
    results <= xor_temp;
end Calculations;
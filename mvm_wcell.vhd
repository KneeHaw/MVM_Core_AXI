-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: mvm_wcell.vhd                                                   --
-- Author: Ethan Rogers (kneehaw@iastate.edu)                                --
-- Date: 5/12/2025                                                           --
--                                                                           --
-- Description: Weight cell that also performs cell computation              --
-- Type: CLOCKED                                                             --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- All outputs are either 0 or 1 
-- 0 is negative and 1 is positive
-- |   X   |   W   |  OUT  |
-- |   0   |   0   |   1   |  -1 * -1 =  1
-- |   0   |   1   |   0   |  -1 *  1 = -1
-- |   1   |   0   |   0   |   1 * -1 = -1
-- |   1   |   1   |   1   |   1 *  1 =  1
-- Operation is similar to that of an XNOR
-- We can remove the not and just treat as an XOR, working in reverse!

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.STD_LOGIC_ARITH.all;
    use IEEE.STD_LOGIC_UNSIGNED.all;
    
entity mvm_wcell is
    port (
        X      : in std_logic;
        W      : in std_logic;
        sysclk : in std_logic;
        reset  : in std_logic;
        loadw  : in std_logic;

        result : out std_logic
    );

end mvm_wcell;

architecture comp_dff of mvm_wcell is

    signal weight_val : std_logic; -- This is the persistently stored weight val (DFF)

begin

    -- Update W on rising edge IF loading weight (now have DFF for weight_val)
    UPDATE_w : process (sysclk)
    begin
        if (sysclk = '1' and sysclk'event) then
            if (reset = '0' and loadw = '1') then
                weight_val <= W;
            else
                weight_val <= weight_val;
            end if;
        end if;
    end process;

    COMPUTE_result : process (X, W)
    begin
        result <= (X xor W); -- Optional (not),  (XOR means counting -1's, XNOR counts 1's)
    end process;
    
end comp_dff;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: mvm_core.vhd                                                   --
-- Author: Ethan Rogers (kneehaw@iastate.edu)                                --
-- Date: 5/12/2025                                                           --
--                                                                           --
-- Description: N-long binary column adder implementation                    --
--              Implemented as a parallel tree adder                         --
--              Output is one byte for simplicity (thus scalable if altered) --
-- Type: COMBINATIONAL                                                       --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Let's say we have 64 values, let's assume they are all negative, so -64
-- Let's say we have M ones, we obtain -64 + M, up to 0.
-- If we offset this value by 32 to begin with, we en up with possible values of -32 to 32
-- 
-- Every column, therefore, should be just a pop-count of ones
-- result = -32 + {pop-count}
--
-- Alternatively, you can use an XOR, starting at 31, then subtract for every '1' seen!
-- result = 31 - {pop-count}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library CUSTOM;
use CUSTOM.custom_types.all;

entity mvm_col_add is
    generic (
        N : integer := 32;
        M : integer := 5
    );
    port (
        input  : in std_logic_vector(N - 1 downto 0);
        output : out std_logic_vector(8 - 1 downto 0) -- byte output
    );

end mvm_col_add;
architecture structure of mvm_col_add is

    signal intermediate_0 : matrix_2D((N/2 - 1) downto 0)(1 downto 0);  -- N to N/2
    signal intermediate_1 : matrix_2D((N/4 - 1) downto 0)(2 downto 0);  -- N/2 to N/4
    signal intermediate_2 : matrix_2D((N/8 - 1) downto 0)(3 downto 0);  -- N/4 to N/8
    signal intermediate_3 : matrix_2D((N/16 - 1) downto 0)(4 downto 0); -- N/8 to N/16

    signal out_sum : std_logic_vector(M - 1 downto 0);  -- N/16 to 1
    signal zeros : std_logic_vector(8 - M - 1 downto 0) := (others => '0');

begin

    stage0 : for i in 0 to N/2 - 1 generate
        intermediate_0(i) <= (input(2 * i) + input(2 * i + 1));
    end generate;

    stage1 : for i in 0 to N/4 - 1 generate
        intermediate_1(i) <= (intermediate_0(2 * i) + intermediate_0(2 * i + 1));
    end generate;

    stage2 : for i in 0 to N/8 - 1 generate
        intermediate_2(i) <= (intermediate_1(2 * i) + intermediate_1(2 * i + 1));
    end generate;

    stage3 : for i in 0 to N/16 - 1 generate
        intermediate_3(i) <= (intermediate_2(2 * i) + intermediate_2(2 * i + 1));
    end generate;

    sum2out : process (intermediate_3)
    begin

        out_sum <= intermediate_3(0) + intermediate_3(1);

    end process;

    result <= zeros & out_sum;

end structure;

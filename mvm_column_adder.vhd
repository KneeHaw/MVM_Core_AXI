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

entity mvm_col_add is
    generic (
        N : integer := 32;
        M : integer := 8
    );
    port (
        input  : in std_logic_vector(N - 1 downto 0);
        output : out std_logic_vector(M - 1 downto 0) -- byte output
    );

end mvm_col_add;
architecture structure of mvm_col_add is

    signal intermediate_0 : std_logic_vector(16 * 2 - 1 downto 0);  -- N to N/2
    signal intermediate_1 : std_logic_vector(8 * 3 - 1 downto 0);  -- N/2 to N/4
    signal intermediate_2 : std_logic_vector(4 * 4 - 1 downto 0);  -- N/4 to N/8
    signal intermediate_3 : std_logic_vector(2 * 5 - 1 downto 0); -- N/8 to N/16

    signal out_sum : std_logic_vector(M - 1 downto 0);  -- N/16 to 1

begin

    stage0 : for i in 0 to N/2 - 1 generate
        intermediate_0(2 * (i + 1) - 1 downto 2 * i) <= unsigned(input(1 * (i + 1) - 1 downto 1 * i)) + unsigned(input(1 * (i + 2) - 1 downto 1 * (i + 1)));
    end generate;

    stage1 : for i in 0 to N/4 - 1 generate
        intermediate_1(3 * (i + 1) - 1 downto 2 * i) <= unsigned(intermediate_0(2 * (i + 1) - 1 downto 2 * i)) + unsigned(intermediate_0(2 * (i + 2) - 1 downto 2 * (i + 1)));
    end generate;

    stage2 : for i in 0 to N/8 - 1 generate
        intermediate_2(4 * (i + 1) - 1 downto 2 * i) <= unsigned(intermediate_1(3 * (i + 1) - 1 downto 3 * i)) + unsigned(intermediate_1(3 * (i + 2) - 1 downto 3 * (i + 1)));
    end generate;

    stage3 : for i in 0 to N/16 - 1 generate
        intermediate_3(5 * (i + 1) - 1 downto 2 * i) <= unsigned(intermediate_2(4 * (i + 1) - 1 downto 4 * i)) + unsigned(intermediate_2(4 * (i + 2) - 1 downto 4 * (i + 1)));
    end generate;

    sum2out : process (intermediate_3)
    begin

        out_sum <= unsigned(intermediate_3(5 - 1 downto 0)) + unsigned(intermediate_3(10 - 1 downto 5));

    end process;

    output <= out_sum;

end structure;

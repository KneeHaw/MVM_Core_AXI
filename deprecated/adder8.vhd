-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: mvm_core.vhd                                                   --
-- Author: Ethan Rogers (kneehaw@iastate.edu)                                --
-- Date: 5/12/2025                                                           --
--                                                                           --
-- Description: 8-bit adder   (to be used in an array fashion)               --
-- Type: COMBINATIONAL                                                       --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.STD_LOGIC_ARITH.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;

entity mvm_col_add is
    generic(
		N : integer := 
        M : integer := 3 
	);	
    port (
        input            : in  std_logic_vector(N-1 downto 0);
        output           : out std_logic_vector(M-1 downto 0)
    );

end mvm_col_add;



architecture structure of mvm_col_add is

    signal intermediate;

begin


end structure;



-- function get_column(
--     signal mat   : matrix_2D;
--     constant col : integer
-- )
--     return std_logic_vector is
--     variable result : std_logic_vector(N - 1 downto 0);
-- begin

--     for j in 0 to N - 1 loop
--         result(j) := mat(j)(col);
--     end loop;

--     return result;

-- end function;
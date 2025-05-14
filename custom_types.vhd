library IEEE;
use IEEE.std_logic_1164.all;

package custom_types is
    
    type matrix_2D is array ( natural range <> ) of std_logic_vector;

end package custom_types;
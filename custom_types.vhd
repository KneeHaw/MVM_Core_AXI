library IEEE;
use IEEE.std_logic_1164.all;

package custom_types is
    
    type row_type is array (natural range <>) of std_logic;
    type matrix_2D is array (natural range <>) of row_type;

end package custom_types;
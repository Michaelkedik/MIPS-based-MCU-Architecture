library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
 
entity Hex is port (
	hex_input : in std_logic_vector(3 downto 0);	
	hex_output: out std_logic_vector(6 downto 0)
	); 
end Hex;

architecture hex of Hex is
  
begin
	hex_output <=  "1111001" when (hex_input = "0001") else
				"0100100" when (hex_input = "0010") else
				"0110000" when (hex_input = "0011") else
				"0011001" when (hex_input = "0100") else
				"0010010" when (hex_input = "0101") else
				"0000010" when (hex_input = "0110") else
				"1111000" when (hex_input = "0111") else
				"0000000" when (hex_input = "1000") else
				"0010000" when (hex_input = "1001") else
				"0001000" when (hex_input = "1010") else
				"0000011" when (hex_input = "1011") else
				"1000110" when (hex_input = "1100") else
				"0100001" when (hex_input = "1101") else
				"0000110" when (hex_input = "1110") else
				"0001110" when (hex_input = "1111") else
				"1000000" ;

end hex;




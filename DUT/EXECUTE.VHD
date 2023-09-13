--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.SIGNED;
USE ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Shamt           : IN	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALU_ctl 		: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );


BEGIN

	
	
	Ainput <= Read_data_1;
						-- ALU input mux
	Binput <= Read_data_2 WHEN ( ALUSrc = '0' ) ELSE  
			  Sign_extend( 31 DOWNTO 0 ) ;


						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) WHEN  ALU_ctl = "0111" ELSE
				  ALU_output_mux( 15 DOWNTO 0 ) & X"0000" WHEN ALU_ctl = "1001" ELSE
				   ALU_output_mux( 31 DOWNTO 0 );
				   
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl, Ainput, Binput, Shamt )
	variable mul   : STD_LOGIC_VECTOR( 63 DOWNTO 0 );
	BEGIN
	mul := std_logic_vector(ieee.numeric_std.SIGNED(Ainput) * ieee.numeric_std.SIGNED(Binput));
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALUresult = A_input XOR B_input
 	 	WHEN "0011" 	=>	ALU_output_mux  <= Ainput XOR Binput;
						-- ALU performs ALUresult = A_input * B_input (without overflow)
 	 	WHEN "0100" 	=>	ALU_output_mux 	<=  mul(31 downto 0);
						-- ALU performs sll
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= std_logic_vector(shift_left(unsigned(Binput) ,to_integer(unsigned(Shamt))));
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
						-- ALU performs srl
 	 	WHEN "1000" 	=>	ALU_output_mux 	<=  std_logic_vector(shift_right(unsigned(Binput) ,to_integer(unsigned(Shamt))));
						-- ALU performs A_input + B_input but with different ALU_ctl for lui
  	 	WHEN "1001" 	=>	ALU_output_mux 	<= Ainput + Binput ;
		WHEN "1111" 	=>	ALU_output_mux 	<= Ainput OR x"0000"&Binput(15 DOWNTO 0) ;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;


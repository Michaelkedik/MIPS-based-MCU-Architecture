		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	Function_opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Beq 		: OUT 	STD_LOGIC;
	Bne 		: OUT 	STD_LOGIC;
	Jump 		: OUT 	STD_LOGIC;
	Jr 		    : OUT 	STD_LOGIC;
	Shift 		    : OUT 	STD_LOGIC;
	ALU_ctl 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Andi, Addi, Ori, Xori, Shiftll, Shiftrl, Slti , Lui, Mul, Jal 	: STD_LOGIC;
	SIGNAL	ALUop 		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  (Opcode = "000000" OR Opcode = "011100")  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
  	RegDst    	<=  R_format;
	Shiftll     <=  '1'  WHEN  (Function_opcode = "000000" AND R_format = '1')  ELSE '0';
	Shiftrl     <=  '1'  WHEN  (Function_opcode = "000010" and Mul = '0' and R_format = '1')  ELSE '0';
 	ALUSrc  	<=  '1' WHEN Lw = '1' OR Sw = '1' OR Addi= '1' OR Andi ='1' OR Ori = '1' OR Xori ='1' OR Slti ='1' OR Lui ='1'
					    ELSE
					'0';
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw OR Lui OR Addi OR Andi OR Ori OR Xori OR Slti OR Jal;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  '1'  WHEN  (Opcode = "000101" OR Opcode = "000100") ELSE '0';
	Andi        <=  '1'  WHEN  Opcode = "001100"  ELSE '0';
	Addi        <=  '1'  WHEN  Opcode = "001000"  ELSE '0';
	Ori         <=  '1'  WHEN  Opcode = "001101"  ELSE '0';
	Xori        <=  '1'  WHEN  Opcode = "001110"  ELSE '0';
	Slti        <=  '1'  WHEN  Opcode = "001010"  ELSE '0';
	Lui         <=  '1'  WHEN  Opcode = "001111"  ELSE '0';
	Bne         <=  '1'  WHEN  Opcode = "000101"  ELSE '0';
	Jump        <=  '1'  WHEN  (Opcode = "000010" OR Jal = '1') ELSE '0';
	Jal         <= 	'1'  WHEN  Opcode = "000011"  ELSE '0';
	Jr          <= 	'1'  WHEN  (Function_opcode = "001000" AND R_format = '1')  ELSE '0';
	Mul         <= 	'1'  WHEN  Opcode = "011100"  ELSE '0';
	Shift       <= 	'1'  WHEN  (Shiftll = '1' or Shiftrl = '1')  ELSE '0';

	
	
	
	
							-- Generate ALU control bits

	ALU_ctl <=  "0000" when (ALUOp(1) = '1' AND Function_opcode = "100100") OR (Andi = '1') else  -- and
			    "0001" when (ALUOp(1) = '1' AND Function_opcode = "100101")  else  -- or
				"1111" when (Ori = '1') else  -- ori
				"0011" when (ALUOp(1) = '1' AND Function_opcode = "100110") OR (Xori = '1') else  -- xor
				"0100" when (ALUOp(1) = '1' AND Mul = '1') else                  -- mult
				"0101" when (ALUOp(1) = '1' AND Function_opcode = "000000") else                  -- sll
				"0110" when (ALUOp(1) = '1' AND Function_opcode = "100010") OR ALUOp( 0 ) = '1' else                  -- sub
				"0111" when (ALUOp(1) = '1' AND Function_opcode = "101010") OR (Slti = '1') else                  -- slt
				"1000" when (ALUOp(1) = '1' AND Function_opcode = "000010") else                  --srl
				"1001" when (Lui = '1') else
				"0010"; --add

					

   END behavior;

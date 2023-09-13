				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS
	
	GENERIC ( N : positive := 10); --10 for Quartus 8 for modelsim
	PORT( reset, clock, enable			: IN 	STD_LOGIC;
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		INTR_in					        : IN 	STD_LOGIC;
		read_from_bus                   : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		IO_read_out                     : OUT   STD_LOGIC;
		write_data_IO                   : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Instruction_out                 : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		MemRead_out                     : OUT   STD_LOGIC;
		Memwrite_out                    : OUT   STD_LOGIC;
		INTA_out                        : OUT   STD_LOGIC;
		GIE_out                         : OUT   STD_LOGIC
		);
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch IS
		GENERIC ( N : positive := 10); --10 for Quartus 8 for modelsim
		PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				SIGNAL ALU_Result 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				SIGNAL IntAddress       : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				SIGNAL J_addr           : IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				SIGNAL Beq 			    : IN 	STD_LOGIC;
				SIGNAL Bne 			    : IN 	STD_LOGIC;
				SIGNAL Jump 			: IN 	STD_LOGIC;
				SIGNAL Jr				: IN 	STD_LOGIC;
				SIGNAL INTA      		: IN 	STD_LOGIC;
				SIGNAL Zero 			: IN 	STD_LOGIC;
				SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				SIGNAL clock, reset 	: IN 	STD_LOGIC;
				SIGNAL enable       	: IN 	STD_LOGIC);
	END COMPONENT;

	COMPONENT Idecode IS
		  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 	: IN 	STD_LOGIC;
				MemtoReg 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC;
				Jump 		: IN 	STD_LOGIC;
				Jr   		: IN 	STD_LOGIC;			
				Shift 		: IN 	STD_LOGIC;
				INTR     	: IN 	STD_LOGIC;
				GIE 		: OUT 	STD_LOGIC;
				PC_plus_4 	: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				J_addr 	    : OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control IS
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
		Jr 		: OUT 	STD_LOGIC;
		Shift 		    : OUT 	STD_LOGIC;
		ALU_ctl 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
		clock, reset	: IN 	STD_LOGIC );

	END COMPONENT;

	COMPONENT  Execute IS
		PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				Shamt           : IN	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				ALU_ctl 		: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				ALUSrc 			: IN 	STD_LOGIC;
				Zero 			: OUT	STD_LOGIC;
				ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				clock, reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT dmemory
		 GENERIC ( N : positive := 10); --10 for Quartus 8 for modelsim
	     PORT(	read_data 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 					: IN 	STD_LOGIC_VECTOR((N-1) DOWNTO 0 );
        		write_data 					: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite 	        : IN 	STD_LOGIC;
        		Clock,reset					: IN 	STD_LOGIC );
	END COMPONENT;
	
	COMPONENT gpio IS
	   PORT( 	
		Data_in         										  : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Data_out         										  : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Address_Bus              								  : IN	STD_LOGIC_VECTOR( 11 DOWNTO 0 ); 
		MemRead, Memwrite 								          : IN 	STD_LOGIC;
		GIE, INTA 								                  : IN 	STD_LOGIC;
		reset,clock 									          : IN 	STD_LOGIC;
		key_1                                                     : IN  STD_LOGIC;
		key_2                                                     : IN  STD_LOGIC;
		key_3                                                     : IN  STD_LOGIC;
		SW_in                                                     : IN  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		HEX0_out,HEX1_out,HEX2_out,HEX3_out,HEX4_out,HEX5_out     : OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
		LEDR_out							                      : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		INTR									                  : OUT STD_LOGIC
			);

	END COMPONENT;
	
	COMPONENT BidirPin is
		generic( width: integer:=32 );
		port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
				en:		in 		std_logic;
				Din:	out		std_logic_vector(width-1 downto 0);
				IOpin: 	inout 	std_logic_vector(width-1 downto 0)
		);
	end COMPONENT;

					
					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL ALU_ctl 		  	: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	SIGNAL J_addr 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL RegDst 			: STD_LOGIC;
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL Beq 			    : STD_LOGIC;
	SIGNAL Bne 			    : STD_LOGIC;
	SIGNAL Jump 			: STD_LOGIC;
	SIGNAL Jr 			    : STD_LOGIC;
	SIGNAL Shift 		    : STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL enable_write	    : STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Shamt	    	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL address_s		: STD_LOGIC_VECTOR((N-1) DOWNTO 0 );
	SIGNAL read_data_mem    : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL TYPEx            : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL IO_write 		: STD_LOGIC;
	SIGNAL INTR, INTA 		: STD_LOGIC;
	SIGNAL GIE 		        : STD_LOGIC;
	SIGNAL IO_read 		    : STD_LOGIC;

BEGIN
	   
   --added (move to top)
   IO_read          <= '1' WHEN (Instruction(11 DOWNTO 8) = "1000" AND MemRead = '1') OR INTA = '0' ELSE '0'; 
   IO_write         <= '1' WHEN (Instruction(11 DOWNTO 8) = "1000" AND MemWrite = '1') ELSE '0'; 
   read_data        <= read_from_bus WHEN IO_read ='1' ELSE read_data_mem;
   write_data_IO    <= read_data_2 WHEN IO_write ='1' ELSE (OTHERS => 'Z');

   enable_write     <= MemWrite AND(NOT(IO_write));
   
   -- send to top
   IO_read_out      <= IO_read;
   MemRead_out      <= MemRead;
   Memwrite_out     <= Memwrite;
   INTA_out         <= INTA;
   GIE_out          <= GIE;
   Instruction_out  <= Instruction;
   
   --receive from Top
   INTR <= INTR_in;
   
   
   
					-- connect the 5 MIPS components 

   G1: IF N=10 generate	
		address_s   <=  "00"&TYPEx(7 DOWNTO 2)&"00" WHEN INTA = '0' ELSE 
						ALU_Result (9 DOWNTO 2) & "00"; -- Quartus
		END GENERATE;
		
   G2: IF N=8 generate	
		address_s   <=  "00"&TYPEx(7 DOWNTO 2) WHEN INTA = '0' ELSE
						ALU_Result (9 DOWNTO 2); --Modelsim
		END GENERATE;
		
		
  IFE : Ifetch
	GENERIC MAP(N)
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				ALU_Result 		=> ALU_Result,
				J_addr 		    => J_addr,
				Beq 			=> Beq,
				Bne 			=> Bne,
				Jump 			=> Jump,
				Jr 				=> Jr,
				Zero 			=> Zero,
				INTA            => INTA,
				IntAddress      => read_data_mem,
				PC_out 			=> PC,        		
				clock 			=> clock,  
				reset 			=> reset,
				enable          => enable );

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				Jump 		    => Jump,
				Jr 		        => Jr,
				J_addr 		    => J_addr,
				Shift           => Shift,
				GIE             => GIE,
				INTR            => INTR,
				PC_plus_4 	    => PC_plus_4,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				Beq 		    => Beq,
				Bne 		    => Bne,
				Jump            => Jump,
				Jr              => Jr,
				Shift           => Shift,
				MemWrite 		=> MemWrite,
				ALU_ctl         => ALU_ctl,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				Shamt           => Instruction( 10 downto 6),
				ALU_ctl         => ALU_ctl,				
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset );

   MEM:  dmemory
	GENERIC MAP(N)
	PORT MAP (	read_data 		=> read_data_mem,
				address 		=> address_s,
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> enable_write,		
                clock 			=> clock,  
				reset 			=> reset );
				
				
	PROCESS (clock,reset,INTR)
	BEGIN
		IF (reset = '0') THEN
			INTA <= '1';
		ELSIF (rising_edge(clock)) THEN 
			IF (INTA = '1' AND INTR = '1') THEN
				INTA <= '0';
			ELSIF (INTA = '0') THEN 
				INTA <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	TYPEx <= read_from_bus(7 DOWNTO 0);
END structure;


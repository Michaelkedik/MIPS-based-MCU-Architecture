LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY Top IS
	
	GENERIC ( N : positive := 10); --10 for Quartus 8 for modelsim
	PORT( reset, clock, enable			: IN 	STD_LOGIC; 
		LEDR_out                  		: OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
		HEX0_out               			: OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1_out               			: OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2_out               			: OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3_out               			: OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4_out               			: OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5_out               			: OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
		key_1                           : IN    STD_LOGIC;
		key_2                           : IN    STD_LOGIC;
		key_3                           : IN    STD_LOGIC;
		SW_in                           : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
		Out_Signal                      : OUT   STD_LOGIC
		);
END 	Top;

ARCHITECTURE structure OF Top IS

	COMPONENT MIPS IS
		
		GENERIC ( N : positive := 10); --10 for Quartus 8 for modelsim
		PORT( reset, clock, enable			: IN 	STD_LOGIC;
			PC								: OUT   STD_LOGIC_VECTOR( 9 DOWNTO 0 );
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
	END 	COMPONENT;

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
		INTR, Out_Signal									      : OUT STD_LOGIC
			);

	END COMPONENT;
	
	COMPONENT BidirPin is
	generic( width: integer:=32 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
	END COMPONENT;
	
	
	SIGNAL read_data_IO       : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_from_bus      : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Instruction		  : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL write_data_IO      : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL INTR, INTA 		  : STD_LOGIC;
	SIGNAL GIE, IO_read       : STD_LOGIC;
	SIGNAL MemRead, Memwrite  : STD_LOGIC;
	SIGNAL PC                 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	
	
BEGIN 
	
	CPU:  MIPS
   	PORT MAP (	reset 	          => reset,
             	clock 	          => clock,
				enable            => enable,
				PC                => PC,
				read_from_bus     => read_from_bus,
				IO_read_out       => IO_read,
				write_data_IO     => write_data_IO,
				Instruction_out   => Instruction,
				MemRead_out    	  => MemRead,
				Memwrite_out      => Memwrite,
				INTR_in           => INTR,
				INTA_out          => INTA,
				GIE_out           => GIE);	
	
		
	
	IO:  GPIO
	PORT MAP (	Data_in 		=> read_from_bus,
				Data_out 		=> read_data_IO,
				Address_Bus 	=> Instruction(11 DOWNTO 0),
				MemRead 		=> MemRead,  
				Memwrite 		=> MemWrite, 
				LEDR_out 		=> LEDR_out,
				HEX0_out 		=> HEX0_out,
				HEX1_out 		=> HEX1_out,
				HEX2_out 		=> HEX2_out,
				HEX3_out 		=> HEX3_out,
				HEX4_out 		=> HEX4_out,
				HEX5_out        => HEX5_out,
				SW_in           => SW_in,
				INTR            => INTR,
				INTA            => INTA,
				key_1           => key_1,
				key_2           => key_2,
				key_3           => key_3,
				GIE             => GIE,
				Out_Signal      => Out_Signal,
                clock 			=> clock,  
				reset 			=> reset );
				
					
	BiBus:  BidirPin
   	PORT MAP (	Dout 	=> read_data_IO,
             	en 	    => IO_read,
				Din 	=> read_from_bus,
                IOpin	=> write_data_IO);

END structure;
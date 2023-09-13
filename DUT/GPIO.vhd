LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
--USE work.aux_package.all;

ENTITY gpio IS
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

END gpio;

ARCHITECTURE behavior OF gpio IS

	COMPONENT Hex is port (
	hex_input : in std_logic_vector(3 downto 0);	
	hex_output: out std_logic_vector(6 downto 0)
	); 
	END COMPONENT;
	
	COMPONENT Timer IS
	   PORT( 	
		BTCTL 						   : IN  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		Data_in 					   : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		clock, reset,BTCNT_en   	   : IN  STD_LOGIC;
		BTCCR_en                       : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		BTCNT_out					   : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Set_BTIFG, Out_Signal 		   : OUT STD_LOGIC
		);

	END COMPONENT;

	COMPONENT INTCTL IS
	   PORT( 	
		Data_in 		         : IN     STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Address                  : IN     STD_LOGIC_VECTOR( 11 DOWNTO 0 );
		irq                      : IN     STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		clock, reset	         : IN     STD_LOGIC;
		INTA, CS, GIE            : IN     STD_LOGIC;
		Memwrite_IO, Memread_IO  : IN     STD_LOGIC;
		INTR     		         : OUT    STD_LOGIC;
		Data_out 		         : OUT    STD_LOGIC_VECTOR( 31 DOWNTO 0 )
		);

	END COMPONENT;
	
	SIGNAL  IO,Memwrite_IO,Memread_IO,BTCNT_en,Set_BTIFG            : STD_LOGIC;
	SIGNAL  cs1,cs2,cs3,cs4,cs5,cs6,cs7,cs8,cs9,cs10                : STD_LOGIC;
	SIGNAL  HEX0,HEX1,HEX2,HEX3,HEX4,HEX5            				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	SIGNAL  Address_opt 											: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL  LEDR,SW,BTCTL, irq                     					: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL  read_data_in, BTCNT_out, INTER_out                      : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL  BTCCR_en                                                : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	
	

BEGIN 

	---------------------------------- Timer ---------------------------------------
	BT:  Timer
   	PORT MAP (	BTCTL 	    => BTCTL,
             	Data_in     => read_data_in,
				clock 	    => clock,
				reset 	    => reset,
				BTCNT_en 	=> BTCNT_en,
				BTCCR_en 	=> BTCCR_en,
				BTCNT_out 	=> BTCNT_out,
				Set_BTIFG 	=> Set_BTIFG,
                Out_Signal	=> Out_Signal);
				
	INTER : INTCTL
	PORT MAP (  Data_in     => read_data_in,
				Address     => Address_Bus,
				irq         => irq,
				clock       => clock,
				reset       => reset,
				INTA        => INTA,
				CS          => cs10,
				GIE         => GIE,
				Memwrite_IO => Memwrite_IO,
				Memread_IO  => Memread_IO,
				INTR        => INTR,
				Data_out    => INTER_out
	);

    ---------------------------------- Signals --------------------------------------------------
	IO          <= '1' WHEN Address_Bus(11 downto 8) = "1000" ELSE '0';
	Memwrite_IO <= Memwrite and IO;
	Memread_IO  <= MemRead and IO;
	read_data_in  <= Data_in;
	Address_opt <= Address_Bus(11) & Address_Bus(5 downto 2);
	BTCNT_en <= '1' WHEN (cs2 = '1' AND Memwrite_IO = '1') ELSE '0';
	BTCCR_en <= "01" WHEN (cs8 = '1' AND Memwrite_IO = '1') ELSE
				"10" WHEN (cs9 = '1' AND Memwrite_IO = '1') ELSE
	            "00";
				
	irq <= "00"&key_3&key_2&key_1&Set_BTIFG&"00";
	
	

	---------------------------------- Optimized Address Decoder (CS) ---------------------------------------
	cs1  <= '1' WHEN Address_opt = "10000" ELSE '0'; --LEDR
	cs2  <= '1' WHEN Address_opt = "11000" ELSE '0'; --BTCNT
	cs3  <= '1' WHEN Address_opt = "10111" ELSE '0'; --BTCTL
	cs4  <= '1' WHEN Address_opt = "10011" ELSE '0'; --HEX4 OR HEX5
	cs5  <= '1' WHEN Address_opt = "10010" ELSE '0'; --HEX2 OR HEX3
	cs6  <= '1' WHEN Address_opt = "10001" ELSE '0'; --HEX0 OR HEX1 
	cs7  <= '1' WHEN Address_opt = "10100" ELSE '0'; --SW 
	cs8  <= '1' WHEN Address_opt = "11001" ELSE '0'; --BTCCR0
	cs9  <= '1' WHEN Address_opt = "11010" ELSE '0'; --BTCCR1
	cs10 <= '1' WHEN Address_opt = "11011" ELSE '0'; --INTERUPT


	----------------------------- Data Output ----------------------------------------------------------------
	
	Data_out <= X"000000"& SW_in WHEN (Memread_IO = '1' AND cs7= '1') ELSE
				INTER_out WHEN INTA = '0' OR (Memread_IO = '1' AND cs10= '1') ELSE
				 (OTHERS => 'Z');
	
	---------------------------------- LEDR Register ---------------------------------------
	PROCESS (clock,reset)
		BEGIN
			IF reset = '0' THEN
				   LEDR <= "00000000" ; 
			ELSIF rising_edge(clock) THEN 
			IF (Memwrite_io = '1' AND cs1= '1') THEN 
				   LEDR <= read_data_in(7 downto 0);
				 end IF;
			END IF;
	END PROCESS;
	LEDR_out <= LEDR;
	
	---------------------------------- HEX0/HEX1 Register ---------------------------------------
	PROCESS (clock,reset)
		BEGIN
			IF reset = '0' THEN
				   HEX0 <= "0000"; 
				   HEX1 <= "0000";
			ELSIF rising_edge(clock) THEN 
				IF (Memwrite_io = '1' and cs6= '1' AND Address_Bus(0) = '0') THEN 
					   HEX0 <= read_data_in(3 downto 0);
				ELSIF (Memwrite_io = '1' AND cs6= '1' AND Address_Bus(0) = '1') THEN 
					   HEX1 <= read_data_in(3 downto 0);
					 END IF;
			END IF;
	END PROCESS;
	
	---------------------------------- HEX2/HEX3 Register ---------------------------------------
	PROCESS (clock,reset)
		BEGIN
			IF reset = '0' THEN
				   HEX2 <= "0000"; 
				   HEX3 <= "0000";
			ELSIF rising_edge(clock) THEN 
				IF (Memwrite_io = '1' AND cs5= '1' AND Address_Bus(0) = '0') THEN 
					   HEX2 <= read_data_in(3 downto 0);
				ELSIF (Memwrite_io = '1' AND cs5= '1' AND Address_Bus(0) = '1') THEN 
					   HEX3 <= read_data_in(3 downto 0);
					 END IF;
			END IF;
	END PROCESS;
	
	---------------------------------- HEX4/HEX5 Register ---------------------------------------
	PROCESS (clock,reset)
		BEGIN
			IF reset = '0' THEN
				   HEX4 <= "0000"; 
				   HEX5 <= "0000";
			ELSIF rising_edge(clock) THEN 
				IF (Memwrite_io = '1' AND cs4= '1' AND Address_Bus(0) = '0') THEN 
					   HEX4 <= read_data_in(3 downto 0);
				ELSIF (Memwrite_io = '1' AND cs4= '1' AND Address_Bus(0) = '1') THEN 
					   HEX5 <= read_data_in(3 downto 0);
					 END IF;
			END IF;
	END PROCESS;

	
	---------------------------------- BTCTL Register ---------------------------------------
	PROCESS (clock,reset)
		BEGIN
			IF reset = '0' THEN
				   BTCTL <= X"20" ; -- BTHOLD '1' OTHERS '0'
			elsif rising_edge(clock) THEN 
			IF (Memwrite_io = '1' AND cs3= '1') THEN 
				   BTCTL <= Data_in(7 downto 0);
				 END IF;
			END IF;
	END PROCESS;
	
	
	---------------------------------- Convert to HEX ---------------------------------------
	hex_0: Hex
	PORT MAP (
		hex_input => HEX0,
		hex_output =>   HEX0_out );
		
	hex_1: Hex
	PORT MAP (
		hex_input => HEX1,
		hex_output =>   HEX1_out );
	
	hex_2: Hex
	PORT MAP (
		hex_input => HEX2,
		hex_output =>   HEX2_out );
	
	hex_3: Hex
	PORT MAP (
		hex_input => HEX3,
		hex_output =>   HEX3_out );
	
	hex_4: Hex
	PORT MAP (
		hex_input => HEX4,
		hex_output =>   HEX4_out );
		
	hex_5: Hex
	PORT MAP (
		hex_input => HEX5,
		hex_output =>   HEX5_out );
	
	

	


END behavior;



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
--USE work.aux_package.all;

ENTITY INTCTL IS
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

END INTCTL;

ARCHITECTURE behavior OF INTCTL IS

	COMPONENT D_latch IS
    PORT ( D, EN, CLR : IN  STD_LOGIC;
           Q          : OUT STD_LOGIC);
	END COMPONENT;

    SIGNAL  IE, IFG, TYPEx    : STD_LOGIC_VECTOR (7 downto 0); 
	SIGNAL  IRQ_LATCH         : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL  clr_irq		      : STD_LOGIC_VECTOR (5 DOWNTO 0);

BEGIN           
	
	PROCESS (clock,reset)
	BEGIN
		IF(reset = '0') THEN		
			IE      <= X"00";
			clr_irq <= (OTHERS => '1');	
			
		ELSIF (rising_edge(clock)) THEN	
			IF (CS = '1' AND Memwrite_IO = '1' AND Address(3 DOWNTO 0) = X"C") THEN
					IE <= Data_in(7 DOWNTO 0);
			ELSIF (CS = '1' AND Memwrite_IO = '1' AND Address(3 DOWNTO 0) = X"D") THEN
				clr_irq <= NOT(IFG(5 DOWNTO 0));
			ELSIF (INTA = '0' AND TYPEx = X"10") THEN
				clr_irq(2) <= '1';
			ELSE
			    clr_irq <= (OTHERS => '0');
			END IF;	
			
		END IF;
    END PROCESS;
	
	
	GENERATE_LATCH : FOR i IN 5 DOWNTO 0 GENERATE 
		D_latch_PROCESS : D_latch PORT MAP (D => '1', EN => irq(i), CLR => clr_irq(i), Q => IRQ_LATCH(i));
	END GENERATE;		
					  
	IFG <= 	Data_in(7 DOWNTO 0) WHEN (CS = '1' AND Memwrite_IO = '1' AND Address(3 DOWNTO 0) = X"D") ELSE
			"00"&(IRQ_LATCH AND IE(5 DOWNTO 0));
	
	TYPEx <= X"00" WHEN reset  = '0' ELSE -- RESET
			 X"08" WHEN IFG(0) = '1' ELSE -- UART RX
			 X"0C" WHEN IFG(1) = '1' ELSE -- UART TX
			 X"10" WHEN IFG(2) = '1' ELSE -- Basic Timer
			 X"14" WHEN IFG(3) = '1' ELSE -- KEY1
			 X"18" WHEN IFG(4) = '1' ELSE -- KEY2
			 X"1C" WHEN IFG(5) = '1' ELSE -- KEY3
			 Data_in(7 DOWNTO 0) WHEN (CS = '1' AND Memwrite_IO = '1' AND Address(3 DOWNTO 0) = X"E") ELSE
			 unaffected;                    
	
	INTR <= NOT(reset) OR --NMI
			(GIE AND (IFG(0) OR IFG(1) OR IFG(2) OR IFG(3) OR IFG(4) OR IFG(5))); -- Maskable Interrupt
	
	Data_out <= (X"000000")&IE    WHEN (CS = '1' AND Memread_IO = '1' AND Address = X"82C") ELSE
				(X"000000")&IFG   WHEN (CS = '1' AND Memread_IO = '1' AND Address = X"82D") ELSE
				(X"000000")&TYPEx WHEN ((CS = '1' AND Memread_IO = '1' AND Address = X"82E") OR INTA =  '0') ELSE
				(OTHERS => 'Z');
    
END behavior;
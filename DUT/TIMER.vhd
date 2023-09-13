LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
--USE work.aux_package.all;

ENTITY Timer IS
   PORT( 	
	BTCTL 						   : IN  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	Data_in 					   : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	clock, reset,BTCNT_en   	   : IN  STD_LOGIC;
    BTCCR_en                       : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	BTCNT_out					   : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	Set_BTIFG, Out_Signal 		   : OUT STD_LOGIC
	);

END Timer;

ARCHITECTURE behavior OF Timer IS

    SIGNAL  clock_divider                               : std_logic_vector (4 downto 0);
	SIGNAL  Mclk_2, Mclk_4, Mclk_8,timer_clock       	: STD_LOGIC;
	SIGNAL  BTHOLD,BTOUTEN	                            : STD_LOGIC;
	SIGNAL  BTCNT, BTCL0, BTCL1                         :STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL  BTSSEL                                      :STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL  BTIPx                                       :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL  BTCL0_compare,BTCL1_compare,BTCNT_compare   :STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL  temp_sig                                    : STD_LOGIC;                 

BEGIN           
	
	-------------------------------- Control Signals ---------------------------------
	
	BTHOLD  <= NOT(BTCTL(5));
	BTSSEL  <= BTCTL(4 downto 3);
	BTIPx   <= BTCTL(2 downto 0);
	BTOUTEN <= BTCTL(6);
	
	-------------------------- Clock Devider----------------------------------------
	PROCESS (clock,reset)
	BEGIN
		IF(reset='0') THEN
			clock_divider <= (OTHERS => '0');
		ELSIF (rising_edge(clock)) THEN	   
			clock_divider <= clock_divider + 1;
		END IF;
    END PROCESS;
	
    Mclk_2 <= clock_divider(0);
	Mclk_4 <= clock_divider(1);
	Mclk_8 <= clock_divider(2);
		
	-------------------------------------- Clock Selection ----------------------------
	
	timer_clock <= 	Mclk_8 WHEN BTSSEL = "11" ELSE
					Mclk_4 WHEN BTSSEL = "10" ELSE
					Mclk_2 WHEN BTSSEL = "01" ELSE
					clock;
	
	--------------------------------------- Set_BTIFG ----------------------------------
	
	set_BTIFG <= 	BTCNT(0) WHEN BTIPx = "000" ELSE
					BTCNT(3) WHEN BTIPx = "001" ELSE
					BTCNT(7) WHEN BTIPx = "010" ELSE
					BTCNT(11) WHEN BTIPx = "011" ELSE
					BTCNT(15) WHEN BTIPx = "100" ELSE
					BTCNT(19) WHEN BTIPx = "101" ELSE
					BTCNT(23) WHEN BTIPx = "110" ELSE
					BTCNT(25);
	
	------------------------------------- Timer  -----------------------------------	
	PROCESS (timer_clock,reset)
		BEGIN
			IF(reset='0') THEN
				BTCNT <= (others => '0');
			ELSIF (rising_edge(timer_clock)) THEN
				IF BTCNT_en = '1' THEN
					BTCNT <= Data_in;
				ELSIF BTHOLD = '1' THEN				
					BTCNT <= BTCNT + 1;
				END IF;
			END IF;
		END PROCESS;
		

		PROCESS (timer_clock,reset)
			BEGIN
				IF(reset='0') THEN
					BTCNT_compare <= (others => '0');
					BTCL0 <= (others => '0');
					BTCL1 <= (others => '0');
				ELSIF BTCCR_en = "01" THEN
						BTCL0 <= Data_in;
						temp_sig <= '1';
				ELSIF BTCCR_en = "10" THEN
						BTCL1 <= Data_in;
						temp_sig <= '1';
				ELSIF (rising_edge(timer_clock)) THEN
					IF (BTHOLD = '1') THEN 
						BTCNT_compare <= BTCNT_compare + 1;
						IF BTCL0_compare = X"00000000" THEN
								temp_sig <= '1';
								BTCNT_compare    <= (OTHERS => '0');
						ELSIF BTCL1_compare = X"00000000" THEN
								temp_sig <= '0';
						END IF;
					END IF;
				END IF;		
		END PROCESS;
		
		BTCL0_compare <= BTCL0 - BTCNT_compare;
		BTCL1_compare <= BTCL1 - BTCNT_compare;	
		BTCNT_out <= BTCNT;		
		Out_Signal <= temp_sig WHEN BTOUTEN = '1' ELSE '0'; --? 
	
	
   END behavior;
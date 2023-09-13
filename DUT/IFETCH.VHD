-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	GENERIC ( N : positive := 10); --10 for Quartus 8 for modelsim
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL ALU_Result 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			SIGNAL IntAddress       : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			SIGNAL J_addr          	: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL INTA 			: IN 	STD_LOGIC;
        	SIGNAL Beq 			    : IN 	STD_LOGIC;
			SIGNAL Bne 			    : IN 	STD_LOGIC;
			SIGNAL Jump 			: IN 	STD_LOGIC;
			SIGNAL Jr				: IN 	STD_LOGIC;
        	SIGNAL Zero 			: IN 	STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC;
			SIGNAL enable 	        : IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL Mem_Addr : STD_LOGIC_VECTOR((N-1) DOWNTO 0 ); 	 
	
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => N,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\TestPrograms\Project- Modelsim\L1_Caches\asm_ver1\my_program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr, 
		q_a 			=> Instruction );
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
		
							-- send address to inst. memory address register
		G1: IF N = 10 GENERATE 
				Mem_Addr <= Next_PC &"00"; --Quartus				
			END GENERATE;
		G2: IF N = 8 GENERATE 
				Mem_Addr <= Next_PC; --Modelsim
			END GENERATE;
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		Next_PC  <= X"00"                         WHEN Reset = '0'  ELSE
					IntAddress(9 DOWNTO 2)        WHEN INTA = '0'   ELSE
			        Add_result                    WHEN ( (Beq = '1' AND Zero = '1') OR (Bne = '1' AND Zero = '0')) ELSE 
					J_addr                        WHEN Jump = '1'   ELSE 
					"00" & ALU_Result(7 downto 2) WHEN (Jr = '1')   ELSE
					PC_plus_4( 9 DOWNTO 2 );
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' ) AND enable ='1';
			IF reset = '0' THEN
				   PC( 9 DOWNTO 2) <= "00000000" ; 
			ELSE 
				   PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
	END PROCESS;
END behavior;

-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- MIPS Processor VHDL Behavioral Model
--
-- Ifetch module (provides the PC and instruction memory) 
-- 
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Ifetch IS
  PORT( Instruction    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_plus_4      : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        Add_result     : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        PCSrc          : IN  STD_LOGIC;
        PC_out         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock, reset   : IN  STD_LOGIC );
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
  TYPE INST_MEM IS ARRAY (0 to 15) of STD_LOGIC_VECTOR (31 DOWNTO 0);
  
  SIGNAL iram : INST_MEM := (
      X"00612024",    -- and $4,$3,$1
      X"00244025",    -- or  $8,$1,$4
      X"00841822",    -- sub $$3,$4,$4
      X"00832820",    -- add $5,$4,$$3
      X"00C70824",    -- and $1,$6,$7
      X"10040002",  --beq $0, $4, 8 [label1-(PC+1)]; -- beq $0, $4, label1
      X"00444020",  --add $8, $2, $4                  ; -- add $8, $2, $4
      X"00a12820",  --add $5, $5, $1                  ; -- add $5, $5, $1
      X"11050001",  --beq $8, $5, 4 [label2-(PC+1)]; -- beq $8, $5, label2
      X"00a42822",  --sub $5, $5, $4                  ; -- sub $5, $5, $4
      X"10a6ffff",  --beq $5, $6, -4 [label2-(PC+1)]; -- beq $5, $6, label2
      X"1000ffff",  --beq $0, $0, -4 [label3-(PC+1)]; -- beq $0, $0, label3
      X"00000000",   -- nop 
      X"00000000",   -- nop  
      X"00000000",   -- nop    
      X"00000000"    -- nop
  );
    
  SIGNAL PC, next_PC   : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL D_Instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL D_PC_plus_4   : STD_LOGIC_VECTOR(9 DOWNTO 0);
  
  BEGIN
    PC_out        <= PC;
    next_PC       <= D_PC_plus_4 WHEN (PCSrc = '0') ELSE ADD_result;
    D_Instruction <= iram(CONV_INTEGER(B"00" & PC(9 DOWNTO 2))) WHEN (pcsrc = '0') ELSE X"00000000";
    D_PC_plus_4   <= PC + 4;

  PROCESS
    BEGIN
      WAIT UNTIL (clock'EVENT AND clock = '1');
        IF reset = '1' THEN
          Instruction   <= X"00000000";
          PC_plus_4     <= B"0000000000";
          PC            <= B"0000000000";
        ELSE
          Instruction   <= D_Instruction;
          PC_plus_4     <= D_PC_plus_4;
          PC            <= next_PC;
        END IF;
  END PROCESS;
END behavior;

-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- MIPS Processor VHDL Behavioral Model
--
-- Execute module (implements the data ALU and Branch Address Adder)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY Execute IS
  PORT( regdst           : IN  STD_LOGIC;
        ALUOp            : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
        ALUSrc           : IN  STD_LOGIC;
        sign_extend      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        opcode           : IN  STD_LOGIC_VECTOR(5  DOWNTO 0);
        read_data_1      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALU_result       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_rt           : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
        reg_rd           : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
        write_register   : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        D_write_reg_out  : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        DD_write_reg_out : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        D_ALU_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        clock, reset     : IN  STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS 
  SIGNAL ALU_A, ALU_B                        : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ALU_ctl                             : STD_LOGIC_VECTOR(2  DOWNTO 0);
  SIGNAL ALU_output                          : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  SIGNAL D_ALU_result                        : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL D_write_register, DD_write_register : STD_LOGIC_VECTOR(4  DOWNTO 0);
  
  BEGIN
    ALU_A      <= read_data_1;
    ALU_B      <= read_data_2 WHEN (ALUSrc = '0') ELSE sign_extend(31 DOWNTO 0);
    ALU_ctl(0) <= (opcode(0) OR opcode(3)) AND ALUOp(1);
    ALU_ctl(1) <= (NOT opcode(2)) OR (NOT ALUOp(1));
    ALU_ctl(2) <= (opcode(1) AND ALUOp(1)) OR ALUOp(0);
    
    ALU_output <= (ALU_A AND ALU_B) WHEN (ALU_ctl = B"000") ELSE
                  (ALU_A OR  ALU_B) WHEN (ALU_ctl = B"001") ELSE
                  (ALU_A +   ALU_B) WHEN (ALU_ctl = B"010") ELSE
                  (ALU_A -   ALU_B) WHEN (ALU_ctl = B"110" OR ALU_ctl = B"111") ELSE X"00000000";
                  
    D_ALU_result <= X"0000000" & B"000" & ALU_output(31) WHEN ALU_ctl = "111" 
                    ELSE ALU_output(31 DOWNTO 0);
    
    D_write_register <= reg_rt WHEN (regdst = '0') ELSE reg_rd;

    D_write_reg_out  <= D_write_register;
    DD_write_reg_out <= DD_write_register;
    D_ALU_result_out <= D_ALU_result;                  

  PROCESS
    BEGIN
      WAIT UNTIL (clock'EVENT AND clock = '1');
      IF reset = '1' THEN
        ALU_result        <= X"00000000";
        
        write_register    <= B"00000";
        DD_write_register <= B"00000";
      ELSE
        ALU_result        <= D_ALU_result;
        
        write_register    <= DD_write_register;
        DD_write_register <= D_write_register;
      END IF; 
  END PROCESS;
END behavior;

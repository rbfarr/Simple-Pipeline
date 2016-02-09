-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- MIPS Processor VHDL Behavioral Model
--                            
--  Dmemory module (implements the data
--  memory for the MIPS computer)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dmemory IS
  PORT( memread         : IN  STD_LOGIC;
        memwrite        : IN  STD_LOGIC;
        ALU_result      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data2     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        D_read_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        memtoreg        : IN  STD_LOGIC;
        clock, reset    : IN  STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS 
  TYPE DATA_RAM IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
  
  SIGNAL ram : DATA_RAM := (
    X"55",
    X"55",
    X"55",
    X"55",
    X"AA",
    X"AA",
    X"AA",
    X"AA",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00",
    X"00" );
    
    SIGNAL D_read_data   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL address       : STD_LOGIC_VECTOR(7  DOWNTO 0);
    
    BEGIN
      D_read_data_out <= D_read_data;
      D_read_data     <= mem_read_data WHEN (memtoreg = '1') ELSE ALU_result;
      address         <= ALU_result(7 DOWNTO 0);
      
      PROCESS(clock)
        BEGIN
          IF (clock = '1') THEN
            IF (reset = '1') THEN
              read_data <= X"00000000";
            ELSE
              read_data <= D_read_data;
            END IF; 
          ELSE
            IF (memread = '1') THEN
              mem_read_data(7  DOWNTO 0)     <= ram(CONV_INTEGER(address));
              mem_read_data(15 DOWNTO 8)     <= ram(CONV_INTEGER(address+1));
              mem_read_data(23 DOWNTO 16)    <= ram(CONV_INTEGER(address+2));
              mem_read_data(31 DOWNTO 24)    <= ram(CONV_INTEGER(address+3));
            ELSIF (memwrite = '1') THEN
              ram(CONV_INTEGER(address))   <= write_data2(7  DOWNTO 0);
              ram(CONV_INTEGER(address+1)) <= write_data2(15 DOWNTO 8);
              ram(CONV_INTEGER(address+2)) <= write_data2(23 DOWNTO 16);
              ram(CONV_INTEGER(address+3)) <= write_data2(31 DOWNTO 24);   
            END IF;           
          END IF;         
      END PROCESS;
END behavior;

-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--                            
-- writeback module
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY wb IS
  PORT( read_data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
END wb;

ARCHITECTURE behavior OF wb IS 
  BEGIN      
    write_data <= read_data; --moved memtoreg mux to MEM stage, so this file is no longer useful
END behavior;

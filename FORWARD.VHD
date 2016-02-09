-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- forwarding module
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--

LIBRARY IEEE;            
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY forward IS
  PORT( read_register1 : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        read_register2 : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        read_data_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        read_data_mux2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_dest_exe   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        reg_dest_mem   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        clock, reset   : IN  STD_LOGIC );
END forward;

ARCHITECTURE behavior OF forward IS
  BEGIN
    PROCESS
    BEGIN
      WAIT UNTIL (clock'EVENT AND clock = '0');
      IF (reset = '1') THEN
        read_data_mux1 <= "00";
        read_data_mux2 <= "00";
      ELSE
        IF (read_register1 = "00000") THEN
          read_data_mux1 <= "00";
        ELSIF (read_register1 = reg_dest_exe) THEN
          read_data_mux1 <= "01";
        ELSIF (read_register1 = reg_dest_mem) THEN
          read_data_mux1 <= "10";
        ELSE
          read_data_mux1 <= "00";
        END IF;
    
        IF (read_register2 = "00000") THEN
          read_data_mux2 <= "00";
        ELSIF (read_register2 = reg_dest_exe) THEN
          read_data_mux2 <= "01";
        ELSIF (read_register2 = reg_dest_mem) THEN
          read_data_mux2 <= "10";
        ELSE
          read_data_mux2 <= "00";
        END IF;
      END IF;
    END PROCESS;
END behavior;

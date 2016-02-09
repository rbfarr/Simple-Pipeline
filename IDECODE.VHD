-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- MIPS Processor VHDL Behavioral Model
--             
-- Idecode module (implements the register file)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--

LIBRARY IEEE;            
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
  PORT( regwrite       : IN  STD_LOGIC;
        instruction    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_1    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_register : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
        write_data     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        sign_extend    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        opcode         : OUT STD_LOGIC_VECTOR(5  DOWNTO 0);
        reg_rt         : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        reg_rd         : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        write_data2    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        c_opcode       : OUT STD_LOGIC_VECTOR(5  DOWNTO 0);
        read_reg1_out  : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        read_reg2_out  : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
        reg_mux1_sel   : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
        reg_mux2_sel   : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
        forward_exe    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        forward_mem    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch         : IN  STD_LOGIC;
        pcsrc          : OUT STD_LOGIC;
        PC_plus_4      : IN  STD_LOGIC_VECTOR(9  DOWNTO 0);
        ADD_result     : OUT STD_LOGIC_VECTOR(9  DOWNTO 0);
        decode_zero    : OUT STD_LOGIC;
        clock, reset   : IN  STD_LOGIC );
END Idecode;

ARCHITECTURE behavior OF Idecode IS
  TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL register_array                : register_file;
  SIGNAL D_read_data_1                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL D_read_data_2                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL D_sign_extend                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL D_opcode                      : STD_LOGIC_VECTOR(5  DOWNTO 0);
  SIGNAL D_reg_rt                      : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL D_reg_rd                      : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL D_write_data2, DD_write_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL regfile_read1, regfile_read2  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL zero                          : STD_LOGIC;
  SIGNAL mult_by_4                     : STD_LOGIC_VECTOR(9  DOWNTO 0);

  BEGIN
    decode_zero <= zero;
    ADD_result  <= mult_by_4 + PC_plus_4;
    mult_by_4   <= D_sign_extend(7 DOWNTO 0) & B"00";
    zero        <= '1' WHEN (D_read_data_1 = D_read_data_2) ELSE '0';
    pcsrc       <= branch AND zero;
    
    D_read_data_1 <= regfile_read1 WHEN (reg_mux1_sel = "00") ELSE
                     forward_exe   WHEN (reg_mux1_sel = "01") ELSE
                     forward_mem   WHEN (reg_mux1_sel = "10") ELSE X"00000000";
    
    D_read_data_2 <= regfile_read2 WHEN (reg_mux2_sel = "00") ELSE
                     forward_exe   WHEN (reg_mux2_sel = "01") ELSE
                     forward_mem   WHEN (reg_mux2_sel = "10") ELSE X"00000000";
    
    regfile_read1 <= register_array(CONV_INTEGER(instruction(25 DOWNTO 21)));
    regfile_read2 <= register_array(CONV_INTEGER(instruction(20 DOWNTO 16)));
    
    -- fixed to work with forwarding hardware by setting to 0 when branch
    D_reg_rt      <= instruction(20 DOWNTO 16) WHEN (branch = '0') ELSE "00000";
    D_reg_rd      <= instruction(15 DOWNTO 11) WHEN (branch = '0') ELSE "00000";
    
    D_write_data2 <= D_read_data_2;
    D_opcode      <= instruction(5  DOWNTO 0);
    c_opcode      <= instruction(31 DOWNTO 26);
    
    D_sign_extend <= X"0000" & instruction(15 DOWNTO 0)
                     WHEN instruction(15) = '0'
                     ELSE X"FFFF" & instruction (15 DOWNTO 0);
                  
    read_reg1_out <= instruction(25 DOWNTO 21);
    read_reg2_out <= instruction(20 DOWNTO 16);
                       
  PROCESS(clock)
    BEGIN
      IF clock = '1' THEN
        IF reset = '1' THEN
          FOR i IN 0 TO 31 LOOP
            register_array(i) <= CONV_STD_LOGIC_VECTOR(i, 32);
          END LOOP;
        
          read_data_1     <= X"00000000";
          read_data_2     <= X"00000000";
          reg_rt          <= B"00000";
          reg_rd          <= B"00000";
          sign_extend     <= X"00000000";
          opcode          <= B"000000";
          write_data2     <= X"00000000";
          DD_write_data2  <= X"00000000";
        ELSE
          read_data_1     <= D_read_data_1;
          read_data_2     <= D_read_data_2;
          reg_rt          <= D_reg_rt;
          reg_rd          <= D_reg_rd;
          sign_extend     <= D_sign_extend;
          opcode          <= D_opcode;
          write_data2     <= DD_write_data2;
          DD_write_data2  <= D_write_data2;
        END IF;
      ELSE
        IF regwrite = '1' AND write_register /= 0 THEN
          register_array(CONV_INTEGER(write_register)) <= write_data;
        END IF;
      END IF;
  END PROCESS;
END behavior;

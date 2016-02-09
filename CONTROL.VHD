-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- MIPS Processor VHDL Behavioral Model
--        
-- control module (implements MIPS control unit)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
  PORT( c_opcode     : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
        RegDst       : OUT STD_LOGIC;
        ALUSrc       : OUT STD_LOGIC;
        MemtoReg     : OUT STD_LOGIC;
        RegWrite     : OUT STD_LOGIC;
        MemRead      : OUT STD_LOGIC;
        MemWrite     : OUT STD_LOGIC;
        Branch       : OUT STD_LOGIC;
        ALUop        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        clock, reset : IN  STD_LOGIC );
END control;

ARCHITECTURE behavior OF control IS
  SIGNAL R_format, Lw, Sw, Beq                 : STD_LOGIC;
  SIGNAL D_RegDst                              : STD_LOGIC;
  SIGNAL D_ALUSrc                              : STD_LOGIC;
  SIGNAL D_MemtoReg, DD_MemtoReg               : STD_LOGIC;
  SIGNAL D_RegWrite, DD_RegWrite, DDD_RegWrite : STD_LOGIC;
  SIGNAL D_MemRead, DD_MemRead                 : STD_LOGIC;
  SIGNAL D_MemWrite, DD_MemWrite               : STD_LOGIC;
  SIGNAL D_ALUop                               : STD_LOGIC_VECTOR(1 DOWNTO 0);

  BEGIN
    -- Code to generate control signals using opcode bits
    R_format   <= '1' WHEN c_opcode = "000000" ELSE '0';
    Lw         <= '1' WHEN c_opcode = "100011" ELSE '0';
    Sw         <= '1' WHEN c_opcode = "101011" ELSE '0';
    Beq        <= '1' WHEN c_opcode = "000100" ELSE '0';
    
    D_RegDst   <= R_format;
    D_ALUSrc   <= Lw OR Sw;
    D_MemtoReg <= Lw;
    D_RegWrite <= R_format OR Lw;
    D_MemRead  <= Lw;
    D_MemWrite <= Sw;
    Branch     <= Beq;
    D_ALUop    <= R_format & Beq;
    
  PROCESS
    BEGIN
      WAIT UNTIL (clock'EVENT AND clock = '1');
        IF (reset = '1') THEN
          RegDst       <= '0';
          
          ALUSrc       <= '0';
          
          MemtoReg     <= '0';
          DD_MemtoReg  <= '0';
          
          RegWrite     <= '0';
          DDD_RegWrite <= '0';
          DD_RegWrite  <= '0';
          
          MemRead      <= '0';
          DD_MemRead   <= '0';
          
          MemWrite     <= '0';
          DD_MemWrite  <= '0';
          
          ALUop        <= B"00";
        ELSE
          RegDst       <= D_RegDst;
          
          ALUSrc       <= D_ALUSrc;
          
          MemtoReg     <= DD_MemtoReg;
          DD_MemtoReg  <= D_MemtoReg;
          
          RegWrite     <= DDD_RegWrite;
          DDD_RegWrite <= DD_RegWrite;
          DD_RegWrite  <= D_RegWrite;
          
          MemRead      <= DD_MemRead;
          DD_MemRead   <= D_MemRead;
          
          MemWrite     <= DD_MemWrite;
          DD_MemWrite  <= D_MemWrite;
          
          ALUop        <= D_ALUop;
        END IF;
  END PROCESS;
END behavior;

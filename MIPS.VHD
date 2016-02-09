-- ECE 3056 Computer Architecture and Operating Systems
-- Richard Farr (rfarr6)
--
-- MIPS Processor VHDL Behavioral Model
--                  
-- Top Level Structural Model for MIPS Processor Core
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS
  PORT( reset, clock     : IN STD_LOGIC; 
        -- Output important signals to pins for easy display in Simulator
        PC_out           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,     
        Instruction_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Branch_out, Zero_out, Memwrite_out, 
        Regwrite_out     : OUT STD_LOGIC;
        forward_mux1_out, forward_mux2_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );
END MIPS;

ARCHITECTURE structure OF MIPS IS
  COMPONENT Ifetch
    PORT( instruction  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          PC_plus_4    : OUT STD_LOGIC_VECTOR(9  DOWNTO 0);
          ADD_result   : IN  STD_LOGIC_VECTOR(9  DOWNTO 0);
          PCSrc        : IN  STD_LOGIC;
          PC_out       : OUT STD_LOGIC_VECTOR(9  DOWNTO 0);
          clock, reset : IN  STD_LOGIC );
  END COMPONENT; 

  COMPONENT Idecode
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
  END COMPONENT;

  COMPONENT control
    PORT( c_opcode     : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
          regdst       : OUT STD_LOGIC;
          ALUSrc       : OUT STD_LOGIC;
          memtoreg     : OUT STD_LOGIC;
          regwrite     : OUT STD_LOGIC;
          memread      : OUT STD_LOGIC;
          memwrite     : OUT STD_LOGIC;
          branch       : OUT STD_LOGIC;
          ALUop        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          clock, reset : IN  STD_LOGIC );
  END COMPONENT;

  COMPONENT Execute
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
  END COMPONENT;

  COMPONENT dmemory
    PORT( memread         : IN  STD_LOGIC;
          memwrite        : IN  STD_LOGIC;
          ALU_result      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          write_data2     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
          read_data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          D_read_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          memtoreg        : IN  STD_LOGIC;
          clock, reset    : IN  STD_LOGIC );
  END COMPONENT;
  
  COMPONENT wb
    PORT ( read_data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
           write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
  END COMPONENT;
  
  COMPONENT forward
    PORT ( read_register1 : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
           read_register2 : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
           read_data_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
           read_data_mux2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
           reg_dest_exe   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
           reg_dest_mem   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
           clock, reset   : IN  STD_LOGIC ); 
  END COMPONENT;

  -- declare signals used to connect VHDL components
  SIGNAL instruction    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus_4      : STD_LOGIC_VECTOR(9  DOWNTO 0);
  SIGNAL read_data_1    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL read_data_2    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL sign_extend    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL opcode         : STD_LOGIC_VECTOR(5  DOWNTO 0);
  SIGNAL reg_rt         : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL reg_rd         : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL write_data2    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL c_opcode       : STD_LOGIC_VECTOR(5  DOWNTO 0);
  SIGNAL regdst         : STD_LOGIC;
  SIGNAL ALUSrc         : STD_LOGIC;
  SIGNAL memtoreg       : STD_LOGIC;
  SIGNAL regwrite       : STD_LOGIC;
  SIGNAL memread        : STD_LOGIC;
  SIGNAL memwrite       : STD_LOGIC;
  SIGNAL branch         : STD_LOGIC;
  SIGNAL ALUop          : STD_LOGIC_VECTOR(1  DOWNTO 0);
  SIGNAL ADD_result     : STD_LOGIC_VECTOR(9  DOWNTO 0);
  SIGNAL ALU_result     : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL write_register : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL PCSrc          : STD_LOGIC;
  SIGNAL read_data      : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL write_data     : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  SIGNAL read_reg1_out    : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL read_reg2_out    : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL D_read_data_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL D_write_reg_out  : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL DD_write_reg_out : STD_LOGIC_VECTOR(4  DOWNTO 0);
  SIGNAL D_ALU_result_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL read_data_mux1   : STD_LOGIC_VECTOR(1  DOWNTO 0);
  SIGNAL read_data_mux2   : STD_LOGIC_VECTOR(1  DOWNTO 0);
  SIGNAL decode_zero      : STD_LOGIC;

  BEGIN
    -- copy important signals to output pins for easy 
    -- display in Simulator
    Instruction_out  <= instruction;
    ALU_result_out   <= ALU_result;
    read_data_1_out  <= read_data_1;
    read_data_2_out  <= read_data_2;
    write_data_out   <= write_data;
    Branch_out       <= branch;
    Zero_out         <= decode_zero;
    RegWrite_out     <= regwrite;
    MemWrite_out     <= memwrite;

    forward_mux1_out <= read_data_mux1; 
    forward_mux2_out <= read_data_mux2;
    
    -- connect the 5 MIPS components      
    IFE : Ifetch
    PORT MAP ( instruction  => instruction,
               PC_plus_4    => PC_plus_4,
               ADD_result   => ADD_result,
               PCSrc        => PCSrc,
               PC_out       => PC_out,
               clock        => clock,
               reset        => reset );

    ID : Idecode
    PORT MAP ( regwrite       => regwrite,
               instruction    => instruction,
               read_data_1    => read_data_1,
               read_data_2    => read_data_2,
               write_register => write_register,
               write_data     => write_data,
               sign_extend    => sign_extend,
               opcode         => opcode,
               reg_rt         => reg_rt,
               reg_rd         => reg_rd,
               write_data2    => write_data2,
               c_opcode       => c_opcode,
               read_reg1_out  => read_reg1_out,
               read_reg2_out  => read_reg2_out,
               reg_mux1_sel   => read_data_mux1,
               reg_mux2_sel   => read_data_mux2,
               forward_exe    => D_ALU_result_out,
               forward_mem    => D_read_data_out,
               branch         => branch,
               pcsrc          => pcsrc,
               PC_plus_4      => PC_plus_4,
               ADD_result     => ADD_result,
               decode_zero    => decode_zero,
               clock          => clock,
               reset          => reset );

    CTL : control
    PORT MAP ( c_opcode     => c_opcode,
               regdst       => regdst,
               ALUSrc       => ALUSrc,
               memtoreg     => memtoreg,
               regwrite     => regwrite,
               memread      => memread,
               memwrite     => memwrite,
               branch       => branch,
               ALUop        => ALUop,
               clock        => clock,
               reset        => reset );

    EXE : Execute
    PORT MAP ( regdst           => regdst,
               ALUOp            => ALUOp,
               ALUSrc           => ALUSrc,
               sign_extend      => sign_extend,
               opcode           => opcode,
               read_data_1      => read_data_1,
               read_data_2      => read_data_2,
               ALU_result       => ALU_result,
               reg_rt           => reg_rt,
               reg_rd           => reg_rd,
               write_register   => write_register,
               D_write_reg_out  => D_write_reg_out,
               DD_write_reg_out => DD_write_reg_out,
               D_ALU_result_out => D_ALU_result_out,
               clock            => clock,
               reset            => reset );

    MEM : dmemory
    PORT MAP ( memread         => memread,
               memwrite        => memwrite,
               ALU_result      => ALU_result,
               write_data2     => write_data2,
               read_data       => read_data,
               D_read_data_out => D_read_data_out,
               memtoreg        => memtoreg,
               clock           => clock,
               reset           => reset );
  
    WRITEBACK : wb
    PORT MAP ( read_data  => read_data,
               write_data => write_data );
                            
    FORW : forward
    PORT MAP( read_register1 => read_reg1_out,
              read_register2 => read_reg2_out,
              read_data_mux1 => read_data_mux1,
              read_data_mux2 => read_data_mux2,
              reg_dest_exe   => D_write_reg_out,
              reg_dest_mem   => DD_write_reg_out,
              clock          => clock,
              reset          => reset );
                     
END structure;

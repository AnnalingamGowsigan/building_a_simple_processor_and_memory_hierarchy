`include "alu_file_modules.v"
`include "reg_file_modules.v"
`include "lab5_modules.v"

`timescale 1ns/100ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module cpu(PC, INSTRUCTION, CLK, RESET, WRITE, READ, BUSYWAIT, REGOUT1, ALURESULT, READDATA);
    input [31:0] INSTRUCTION;
    input CLK, RESET;
    output [31:0] PC;

    output WRITE, READ;
    input  BUSYWAIT;
    output [7:0]  REGOUT1, ALURESULT;
    input [7:0]  READDATA;


    //////create internal cpu wires//////
    //create INSTRUCTION divided wire parts//
    wire [7:0] OPCODE;
    wire [2:0] READREG2;    //RS
    wire [2:0] READREG1;    //RT
    wire [2:0] WRITEREG;    //RD
    wire [7:0] IMMEDIATE;   //RS_imm
    wire [7:0] RD_IMMEDIATE;//RD_imm

    assign OPCODE       =  INSTRUCTION[31:24];
    assign WRITEREG     =  INSTRUCTION[18:16];
    assign READREG1     =  INSTRUCTION[10:8];
    assign READREG2     =  INSTRUCTION[2:0];
    assign IMMEDIATE    =  INSTRUCTION[7:0];    
    assign RD_IMMEDIATE =  INSTRUCTION[23:16];  // for seeing gtkwave easy


    //for jump_branch_selector module
    wire jump_branch_selector_result;

    mux4_1 my_mux4_1(1'b0  , 1'b1  , ZERO  , ~ZERO  , jump_branch_selector_result, BRANCH            , JUMP);
    //module mux4_1 (input0, input1, input2, input3 , mux_result                 , mux_seletor_branch, mux_seletor_jump);

    //branch  jump   zero   result
    //  0       0     0/1    0     input0
    //  0       1     0/1    1     input1
    //  1       0     0/1    zero  input2
    //  1       1     0/1    zero' input3
    

    ////for PC
    wire ISBUSYWAIT;
    PC my_PC   (RESET, CLK, PC, INSTRUCTION[23:16], jump_branch_selector_result, ISBUSYWAIT); // RD => Offset
    //module PC(RESET, CLK, PC, RD_imm            , jump_branch_selector       , ISBUSYWAIT);

    ////for control Unit
    wire WRITEENABLE;
    wire MUX1_SELECTOR_FOR_SUB;
    wire MUX2_SELECTOR_FOR_IMM;
    wire [2:0] ALUOP;
    wire JUMP;
    wire BRANCH;

    Control_unit my_Control_unit (INSTRUCTION[31:24], WRITEENABLE, MUX1_SELECTOR_FOR_SUB, MUX2_SELECTOR_FOR_IMM, ALUOP, JUMP, BRANCH, WRITE, READ, BUSYWAIT, DATA_MEMORY_MUX_SELECTOR, ISBUSYWAIT);
    //module Control_unit        (OPCODE            , WRITEENABLE, MUX1_SELECTOR_FOR_SUB, MUX2_SELECTOR        , ALUOP, JUMP, BRANCH, WRITE, READ, BUSYWAIT, DATA_MEMORY_MUX_SELECTOR, ISBUSYWAIT);
    
    // for DATA_MEMORY_MUX
    wire [7:0] DATA_MEMORY_MUX_result;

    mux2_1 my_DATA_MEMORY_MUX (ALURESULT, READDATA, DATA_MEMORY_MUX_result, DATA_MEMORY_MUX_SELECTOR);
    //module mux2_1           (input0   , input1  , mux_result            , mux_seletor);


    //for regFile
    //PART6***wire [7:0] REGOUT1;
    wire [7:0] REGOUT2;
    //PART6***wire [7:0] ALURESULT;

    reg_file my_reg_file (DATA_MEMORY_MUX_result, REGOUT1, REGOUT2, INSTRUCTION[18:16], INSTRUCTION[10:8]      , INSTRUCTION[2:0]       , WRITEENABLE, CLK, RESET);
    //reg_file reg_file_1(IN                    , REGOUT1, REGOUT2, WRITEREG(RD)      ,READREG1(RT)/OUT1ADDRESS,READREG2(RS)/OUT2ADDRESS, WRITEENABLE, CLK, RESET);


    //for twosCompliment
    wire [7:0] twosCompliment_1_result;

    twosCompliment my_twosCompliment(REGOUT2, twosCompliment_1_result);


    ////for MUX1 module
    wire [7:0] MUX1_result;

    mux2_1 my_MUX1 (REGOUT2, twosCompliment_1_result, MUX1_result, MUX1_SELECTOR_FOR_SUB);
    //module mux2_1(input0 , input1                 , mux_result , mux_seletor);
    

    ////for MUX2 module
    wire [7:0] MUX2_result;

    mux2_1 my_MUX2 (MUX1_result, INSTRUCTION[7:0], MUX2_result, MUX2_SELECTOR_FOR_IMM);
    //mux2_1 MUX2  (MUX1_result, IMMEDIATE(RS)   , MUX2_result, MUX2_SELECTOR_FOR_IMM);


    ////for alu module
    wire ZERO;

    alu my_alu  (REGOUT1, MUX2_result, ALURESULT, ZERO, ALUOP);
    //module alu(DATA1  , DATA2      , RESULT   , ZERO, SELECT);

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module PC(RESET, CLK, PC, RD_imm, jump_branch_selector, ISBUSYWAIT);// RD => Offset
    input RESET, CLK, jump_branch_selector;         // 1 bit input ports
    input [7:0] RD_imm;     // 8 bit IMMEDIATE Offset
    output reg [31:0] PC;   //output port

    reg [31:0] PC_reg;      //programme counter register

    input ISBUSYWAIT;

   
    ////for signextender
    wire [31:0] my_signextender_result;
 
    signextender my_signextender  (RD_imm[7:0]   , my_signextender_result);
    //signextender my_signextender(unextended    , extended);


    ////for shiftleft_2
    wire [31:0] my_shiftleft_2_result;
 
    shiftleft_2 my_shiftleft_2(my_signextender_result, my_shiftleft_2_result);
    //module signleft_2       (IN                    , OUT);


    ////for taget_adder module
    reg [31:0] targetAddress;

    always @(my_shiftleft_2_result) begin
        #2 targetAddress = PC_reg + my_shiftleft_2_result;
    end


    ////for BRANCH MUX 
    wire [31:0] jump_branch_selector_result;

    mux2_1_forPC my_mux2_1_forPC(PC_reg, targetAddress, jump_branch_selector_result, jump_branch_selector);
    //module mux2_1_forPC       (input0, input1       , mux_result                 , mux_seletor);


    //for gtkwave
    wire [31:0] nextAddress;
    assign nextAddress =  jump_branch_selector_result;


    always @(posedge CLK ) begin    //when clk posedge
        #0.1
        if (ISBUSYWAIT == 0)begin   //if ISBUSYWAIT is 1 don't update pc value(stall the CPU)
            if(RESET == 1) begin        //if reset is high, pc will update to 0
                #0.9 PC = 32'h00000000;   //after 1 sec delay ,assign zero value to PC
            end else begin
                #0.9 PC = nextAddress;    //if reset is low ,PC is updated by nextAddress
            end
        end
    end

    //PC+4 adder
    always@(PC) begin               //when PC is changed 
        #1 PC_reg = PC + 4;         //PC_register is updated by PC + 4
    end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Control_unit(OPCODE, WRITEENABLE, MUX1_SELECTOR, MUX2_SELECTOR, ALUOP, ISJUMP, ISBRANCH, WRITE, READ, BUSYWAIT, DATA_MEMORY_MUX_SELECTOR, ISBUSYWAIT);
    input [7:0] OPCODE;     //geting INSTRUCTION[31:24] and store in OPCODE
    output reg WRITEENABLE, MUX1_SELECTOR, MUX2_SELECTOR, ISJUMP, ISBRANCH;
    output reg [2:0] ALUOP; // selecting ALU Functions

                                                                // *
    output reg WRITE, READ, DATA_MEMORY_MUX_SELECTOR; // for data memory
    
    input BUSYWAIT;
    output ISBUSYWAIT;

    assign ISBUSYWAIT = BUSYWAIT;// sent ISBUSYWAIT signal to PC
    
    always @(OPCODE) begin  // if OPCODE is changed
        #1                  // 1sec delay for instruction decode(generating controal signals)

        //decodeing the opcode
        case(OPCODE)
            8'b00000000:                    // for loadi
                begin                       // loadi 4 0xff
                WRITEENABLE     = 1'b1;     // 1 for write the  0xff in reg 4
                ALUOP           = 3'b000;   // select forward function
                MUX1_SELECTOR   = 1'b0;     // ignore 
                MUX2_SELECTOR   = 1'b1;     // 1 for select Immediate
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000001:                    // for mov
                begin                       // mov 4 1
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data in reg4
                ALUOP           = 3'b000;   // select forward function
                MUX1_SELECTOR   = 1'b0;     // ignore
                MUX2_SELECTOR   = 1'b0;     // 0 for select REGOUT2
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000010:                    //for add
                begin                       //add 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data + reg2 data in reg4
                ALUOP           = 3'b001;   // select add function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000011:                    // for sub
                begin                       // sub 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data - reg2 data in reg4
                ALUOP           = 3'b001;   // select add function
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000100:                    // for and
                begin                       // and 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data & reg2 data in reg4
                ALUOP           = 3'b010;   // select and function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000101:                    // for or
                begin                       // or 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data | reg2 data in reg4
                ALUOP           = 3'b011;   // select or function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000110:                    // for jump
                begin                       // j 0x02
                WRITEENABLE     = 1'b0;     // 0 for don't write 
                //ALUOP           = 3'bxxx; // don't needed //
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                ISJUMP          = 1'b1;     // 0 for jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            8'b00000111:                    // for branch equal
                begin                       // beq 
                WRITEENABLE     = 1'b0;     // 0 for don't write
                ALUOP           = 3'b001;   // select add function  //for sub
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b1;     // 0 for branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end
            ////////////////////////////////////////////////////////////////////////////////
            8'b00001000:                    // for lwd
                begin                       // lwd 4 2 read memAdd in register 2 and store in register 4
                WRITEENABLE     = 1'b1;     // 1 for write
                ALUOP           = 3'b000;   // select forward function  //for give address
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2  
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for branch signal
                WRITE                   = 1'b0; // not write in to data memory
                READ                    = 1'b1; // read the data memory
                DATA_MEMORY_MUX_SELECTOR= 1'b1; // get READDATE from data memory and join to IN port in regfile
                end

            8'b00001001:                    // for lwi
                begin                       // lwi 4 Ox1F  read memAdd(Ox1F) and store in register 4
                WRITEENABLE     = 1'b1;     // 1 for  write
                ALUOP           = 3'b000;   // select forward function  //for give address
                //MUX1_SELECTOR   = 1'b0;     // ignore
                MUX2_SELECTOR   = 1'b1;     // 1 for select Immediate(Ox1F)
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for branch signal
                WRITE                   = 1'b0; // not write in to data memory
                READ                    = 1'b1; // read the data memory
                DATA_MEMORY_MUX_SELECTOR= 1'b1; // get READDATE from data memory and join to IN port in regfile
                end

            8'b00001010:                    // for swd
                begin                       // swd 2 3  write value from register 2 to the memAdd given in register 3
                WRITEENABLE     = 1'b0;     // 0 for don't write
                ALUOP           = 3'b000;   // select forward function  //for give address
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 (address) 
                MUX2_SELECTOR   = 1'b0;     // 0 for select REGOUT2 (address)
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for branch signal
                WRITE                   = 1'b1; // write in to data memory
                READ                    = 1'b0; // not read the data memory
                DATA_MEMORY_MUX_SELECTOR= 1'b0; // get aluresult from alu and join to IN port in regfile
                end

            8'b00001011:                    // for swi 
                begin                       // swi 2 0x8c  write value from register 2 to the memAdd in 0x8c
                WRITEENABLE     = 1'b0;     // 0 for don't write
                ALUOP           = 3'b000;   // select forward function  //for give address
                //MUX1_SELECTOR   = 1'b0;     // ignore
                MUX2_SELECTOR   = 1'b1;     // 1 for select Immediate(0x8c)
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for branch signal
                WRITE                   = 1'b1; // write in to data memory
                READ                    = 1'b0; // not read the data memory
                DATA_MEMORY_MUX_SELECTOR= 1'b0; // get aluresult from alu and join to IN port in regfile
                end
                // char *op_lwd 	= "00001000";
                // char *op_lwi 	= "00001001";
	            // char *op_swd 	= "00001010";
	            // char *op_swi 	= "00001011";
            ////////////////////////////////////////////////////////////////////////////////    
            8'b00010000:                    // for branch not equal
                begin                       // bne 
                WRITEENABLE     = 1'b0;     // 0 for don't write
                ALUOP           = 3'b001;   // select add function  //for sub
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
                ISJUMP          = 1'b1;     // 1 for don't jump signal
                ISBRANCH        = 1'b1;     // 1 for branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                end

            8'b00010001:                    // for multiply
                begin                       // mult 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write
                ALUOP           = 3'b100;   // select multiply function 
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for branch signal
                WRITE                   = 1'b0;
                READ                    = 1'b0;
                DATA_MEMORY_MUX_SELECTOR= 1'b0;
                 end
            ////////////////////////////////////////////////////////////////////////////////    
            default:
                begin                       
                WRITEENABLE     = 1'bx;     // 0 for don't write
                //ALUOP           = 3'bxxx;   
                //MUX1_SELECTOR   = 1'bx;     
                //MUX2_SELECTOR   = 1'bx;     
                ISJUMP          = 1'bx;     // 0 for don't jump signal
                ISBRANCH        = 1'bx;     // 0 for don't branch signal
                WRITE                   = 1'bx;
                READ                    = 1'bx;
                DATA_MEMORY_MUX_SELECTOR= 1'bx;
                end
            //.......
        endcase        
    end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

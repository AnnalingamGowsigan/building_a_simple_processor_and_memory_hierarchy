// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: group 35

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    //wire [31:0] INSTRUCTION;
    reg [31:0] INSTRUCTION;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg [7:0] instr_mem[1023:0];


    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    always @(PC) begin
        #2
        INSTRUCTION = {instr_mem[PC+3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
    end

    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem                                                                     //      wA 1A 2A      
                                                                                                                                    //      rd rt rs
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]}        = 32'b00000000_00000000_00000000_00001001;  //loadi 0     #9
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]}        = 32'b00000000_00000001_00000000_00001000;  //loadi 1     #8
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]}      = 32'b00000010_00000010_00000001_00000000;  //add   2   1  0
        {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]}    = 32'b00000011_00000011_00000000_00000001;  //sub   3   0  1
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("programmer/instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #2
        RESET = 1'b1;

        #4
        RESET= 1'b0;

        // #20
        // RESET = 1'b1;

        // #4
        // RESET= 1'b0; 



        // finish simulation after some time
        #50
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////










/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module cpu(PC, INSTRUCTION, CLK, RESET);
    input [31:0] INSTRUCTION;
    input CLK, RESET;
    output [31:0] PC;

    PC PC_1(RESET, CLK, PC);

    //////create internal cpu wires//////
    //create INSTRUCTION divided wire parts//
    wire [7:0] OPCODE;
    wire [2:0] READREG2;    //RS
    wire [2:0] READREG1;    //RT
    wire [2:0] WRITEREG;    //RD
    wire [7:0] IMMEDIATE;

    assign OPCODE   =  INSTRUCTION[31:24];
    assign WRITEREG =  INSTRUCTION[18:16];
    assign READREG1 =  INSTRUCTION[10:8];
    assign READREG2 =  INSTRUCTION[2:0];
    assign IMMEDIATE=  INSTRUCTION[7:0]; // for seeing gtkwave easy  
    

    ////for control Unit
    wire WRITEENABLE;
    wire MUX1_SELECTOR_FOR_SUB;
    wire MUX2_SELECTOR_FOR_IMM;
    wire [2:0] ALUOP;

    Control_unit Control_unit_1  (INSTRUCTION[31:24], WRITEENABLE, MUX1_SELECTOR_FOR_SUB, MUX2_SELECTOR_FOR_IMM, ALUOP);
    //Control_unit Control_unit_1(OPCODE            , WRITEENABLE, MUX1_SELECTOR_FOR_SUB, MUX2_SELECTOR_FOR_IMM, ALUOP);


    //for regFile
    wire [7:0] REGOUT1;
    wire [7:0] REGOUT2;
    wire [7:0] ALURESULT;

    reg_file reg_file_1  (ALURESULT, REGOUT1, REGOUT2, INSTRUCTION[18:16], INSTRUCTION[10:8]      , INSTRUCTION[2:0]       , WRITEENABLE, CLK, RESET);
    //reg_file reg_file_1(IN       , REGOUT1, REGOUT2, WRITEREG(RD)      ,READREG1(RT)/OUT1ADDRESS,READREG2(RS)/OUT2ADDRESS, WRITEENABLE, CLK, RESET);


    //for twosCompliment
    wire [7:0] twosCompliment_1_result;

    twosCompliment twosCompliment_1(REGOUT2, twosCompliment_1_result);


    ////for MUX1 module
    wire [7:0] MUX1_result;

    mux2_1 MUX1    (REGOUT2, twosCompliment_1_result, MUX1_result, MUX1_SELECTOR_FOR_SUB);
    //module mux2_1(input0 , input1                 , mux_result , mux_seletor);
    

    ////for MUX2 module
    wire [7:0] MUX2_result;

    mux2_1 MUX2  (MUX1_result, INSTRUCTION[7:0], MUX2_result, MUX2_SELECTOR_FOR_IMM);
    //mux2_1 MUX2(MUX1_result, IMMEDIATE(RS)   , MUX2_result, MUX2_SELECTOR_FOR_IMM);


    ////for alu module
    alu alu_1(REGOUT1, MUX2_result, ALURESULT, ALUOP);
    //alu    (DATA1  , DATA2      , RESULT   , SELECT);

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module PC(RESET, CLK, PC);
    input RESET, CLK;       //1 bit input ports
    output reg [31:0] PC;   //output port

    reg [31:0] PC_reg;      //programme counter register

    //PC_adder PC_adder1(PC, PC_reg); //adder to update pc = pc + 4

    always @(posedge CLK ) begin    //when clk posedge
        if(RESET == 1) begin        //if reset is high, pc will update to 0
            #1 PC = 32'h00000000;   //after 1 sec delay ,assign zero value to PC
        end else begin
            #1 PC = PC_reg;         //if reset is low ,PC is updated by PC + 4
        end
    end

    always@(PC) begin               //when PC is changed 
        #1 PC_reg = PC + 4;         //PC_register is updated by PC + 4
    end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Control_unit(OPCODE, WRITEENABLE, MUX1_SELECTOR, MUX2_SELECTOR, ALUOP);
    input [7:0] OPCODE;     //geting INSTRUCTION[31:24] and store in OPCODE
    output reg WRITEENABLE, MUX1_SELECTOR, MUX2_SELECTOR;
    output reg [2:0] ALUOP; // selecting ALU Functions

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
                end
            8'b00000001:                    // for mov
                begin                       // mov 4 1
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data in reg4
                ALUOP           = 3'b000;   // select forward function
                MUX1_SELECTOR   = 1'b0;     // ignore
                MUX2_SELECTOR   = 1'b0;     // 0 for select REGOUT2
                end
            8'b00000010:                    //for add
                begin                       //add 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data + reg2 data in reg4
                ALUOP           = 3'b001;   // select add function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2
                end
            8'b00000011:                    // for sub
                begin                       // sub 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data - reg2 data in reg4
                ALUOP           = 3'b001;   // select add function
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment
                end
            8'b00000100:                    // for and
                begin                       // and 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data & reg2 data in reg4
                ALUOP           = 3'b010;   // select and function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                end
            8'b00000101:                    // for or
                begin                       // or 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data | reg2 data in reg4
                ALUOP           = 3'b011;   // select or function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                end
            //.......
                 
        endcase        
    end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//this is used to convert numbers into minus in two's complement
module twosCompliment(in, result);
    input [7:0] in;
    output [7:0] result;
    // reg result;

    // always@(in) begin
    //     #1 result = ~in+1;
    // end

    assign #1 result = ~in + 1;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//this is a implementation of a 2 to 1 multiplexer
module mux2_1(input0, input1, mux_result, mux_seletor);
    input [7:0] input0;         //input ports
    input [7:0] input1;         
    output [7:0] mux_result;    
    input mux_seletor;          //1 bit selector

    assign mux_result = mux_seletor ? input1 : input0;  //if mux_seletor = 1; select input1
                                                        //if mux_seletor = 0; select input0
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////










/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module alu(DATA1, DATA2, RESULT, SELECT);

    input [7:0] DATA1;
    input [7:0] DATA2;
    input [2:0] SELECT;
    output reg [7:0] RESULT;

    //Creating wires for getting the outputs.
    wire [7:0] FORWARD_result, ADD_result, AND_result, OR_result;

    //initiate functions, and assign the results to the wires.
    FORWARD FORWARD_1(DATA2, FORWARD_result);
    ADD     ADD_1(DATA1, DATA2, ADD_result);
    AND     AND_1(DATA1, DATA2, AND_result);
    OR      OR_1(DATA1, DATA2, OR_result);

    //This always block is executed whenever values in this sensitivity list change. 
    always @ (SELECT or FORWARD_result or ADD_result or AND_result or OR_result) begin
        case (SELECT)
            3'b000: RESULT = FORWARD_result;    //FORWARD forward1 (DATA2, RESULT);
        
            3'b001: RESULT = ADD_result;        //ADD add1(DATA1, DATA2, RESULT);
             
            3'b010: RESULT = AND_result;        //AND and1(DATA1, DATA2, RESULT);
            
            3'b011: RESULT = OR_result;         //OR or1(DATA1, DATA2, RESULT);
             
            default: RESULT = 8'bxxxxxxxx;      //Default case
        endcase
    end
   
endmodule

module FORWARD(DATA2, RESULT);
    input [7:0] DATA2;      //data input port
    output [7:0] RESULT;    //data output port

    assign #1 RESULT = DATA2; 

endmodule

module ADD(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;
    output[7:0] RESULT;
    
    assign #2 RESULT = DATA1 + DATA2;
    
endmodule

module AND(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;    //8 bit input data
    output[7:0] RESULT;         //8 bit output data

    assign #1 RESULT = DATA1 & DATA2;

endmodule

module OR(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;
    output[7:0] RESULT;

    assign #1 RESULT = DATA1 | DATA2;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
    input [7:0] IN;                                     //data input port
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;    //3 bits address ports
    input CLK, RESET, WRITE;                            //for specific tasks
    output [7:0] OUT1, OUT2;                            //8 bits output ports

    reg [7:0]  register [7:0];                          //an array of 8 registers each of 8 bit

    // parallel data outputs
    /*retrieve output values from registorfile*/
    assign #2 OUT1 = register[OUT1ADDRESS];             //retrived OUT1ADDRESS register data 
    assign #2 OUT2 = register[OUT2ADDRESS];             //retrived OUT2ADDRESS register data 
                                                        //add artificial delays

    always @(posedge CLK) begin                         //The always block is triggered at the positive edge of clock

    #1                                                  //add artificial delays
        if (RESET) begin                                //when RESET is set high All register should be cleared in reset event
            register[0] <= 8'b00000000;
            register[1] <= 8'b00000000;
            register[2] <= 8'b00000000;
            register[3] <= 8'b00000000;
            register[4] <= 8'b00000000;
            register[5] <= 8'b00000000;
            register[6] <= 8'b00000000;
            register[7] <= 8'b00000000;
        end  

        else if(WRITE) begin                            //WRITE is set high
            register[INADDRESS] <= IN;                  //written to the input register specified by the INADDRESS
        end
   end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    // char *op_loadi 	= "00000000";
	// char *op_mov 	= "00000001";
	// char *op_add 	= "00000010";
	// char *op_sub 	= "00000011";
	// char *op_and 	= "00000100";
	// char *op_or 	    = "00000101";
	// char *op_j		= "00000110";
	// char *op_beq	    = "00000111";
    // char *op_bne	    = "00001000";

    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem                                                                     //      wA 1A 2A      
                                                                                                                                    //      rd rt rs
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]}        = 32'b00000000_00000000_00000000_00001001;  //loadi 0     #9
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]}        = 32'b00000110_00000001_00000000_00000000;  //j     #1     
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]}      = 32'b00000000_00000001_00000000_00000100;  //loadi 1     #8
        {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]}    = 32'b00000000_00000001_00000000_00001010;  //loadi 1     #10  
        {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]}    = 32'b00001000_00000011_00000001_00000000;  //bne   #3  1  0
        {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]}    = 32'b00000000_00000010_00000000_00001001;  //loadi 2     #9
        {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]}    = 32'b00000111_00000001_00000010_00000000;  //beq   #1  2  0
        {instr_mem[10'd31], instr_mem[10'd30], instr_mem[10'd29], instr_mem[10'd28]}    = 32'b00000011_00000011_00000000_00000001;  //sub   3   0  1
        {instr_mem[10'd35], instr_mem[10'd34], instr_mem[10'd33], instr_mem[10'd32]}    = 32'b00000010_00000011_00000000_00000001;  //add   3   0  1
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("..\\CPU Programming Tools-20220123\\instr_mem.mem", instr_mem);
        //$readmemb("instr_mem.mem", instr_mem, 0, 11);//  0 , (instruction * 4)-1

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
        #100
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

    //////create internal cpu wires//////
    //create INSTRUCTION divided wire parts//
    wire [7:0] OPCODE;
    wire [2:0] READREG2;    //RS
    wire [2:0] READREG1;    //RT
    wire [2:0] WRITEREG;    //RD
    wire [7:0] IMMEDIATE;   //RS_imm
    wire [7:0] RD_IMMEDIATE;   //RD_imm

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
    PC my_PC   (RESET, CLK, PC, INSTRUCTION[23:16], jump_branch_selector_result); // RD => Offset
    //module PC(RESET, CLK, PC, RD_imm            , jump_branch_selector);

    ////for control Unit
    wire WRITEENABLE;
    wire MUX1_SELECTOR_FOR_SUB;
    wire MUX2_SELECTOR_FOR_IMM;
    wire [2:0] ALUOP;
    wire JUMP;
    wire BRANCH;

    Control_unit my_Control_unit (INSTRUCTION[31:24], WRITEENABLE, MUX1_SELECTOR_FOR_SUB, MUX2_SELECTOR_FOR_IMM, ALUOP, JUMP, BRANCH);
    //module Control_unit        (OPCODE            , WRITEENABLE, MUX1_SELECTOR_FOR_SUB, MUX2_SELECTOR        , ALUOP, JUMP, BRANCH);
    

    //for regFile
    wire [7:0] REGOUT1;
    wire [7:0] REGOUT2;
    wire [7:0] ALURESULT;

    reg_file my_reg_file (ALURESULT, REGOUT1, REGOUT2, INSTRUCTION[18:16], INSTRUCTION[10:8]      , INSTRUCTION[2:0]       , WRITEENABLE, CLK, RESET);
    //reg_file reg_file_1(IN       , REGOUT1, REGOUT2, WRITEREG(RD)      ,READREG1(RT)/OUT1ADDRESS,READREG2(RS)/OUT2ADDRESS, WRITEENABLE, CLK, RESET);


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
    //mux2_1 MUX2(MUX1_result, IMMEDIATE(RS)   , MUX2_result, MUX2_SELECTOR_FOR_IMM);


    ////for alu module
    wire ZERO;

    alu my_alu  (REGOUT1, MUX2_result, ALURESULT, ZERO, ALUOP);
    //module alu(DATA1  , DATA2      , RESULT   , ZERO, SELECT);

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module PC(RESET, CLK, PC, RD_imm, jump_branch_selector);// RD => Offset
    input RESET, CLK, jump_branch_selector;         // 1 bit input ports
    input [7:0] RD_imm;     // 8 bit IMMEDIATE Offset
    output reg [31:0] PC;   //output port

    reg [31:0] PC_reg;      //programme counter register


   
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
        if(RESET == 1) begin        //if reset is high, pc will update to 0
            #1 PC = 32'h00000000;   //after 1 sec delay ,assign zero value to PC
        end else begin
            #1 PC = nextAddress;    //if reset is low ,PC is updated by nextAddress
        end
    end

    //PC+4 adder
    always@(PC) begin               //when PC is changed 
        #1 PC_reg = PC + 4;         //PC_register is updated by PC + 4
    end

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module signextender(unextended, extended);
    input [7:0] unextended; //the msb bit is the sign bit // 8-bit input
    output reg [31:0] extended; // 32-bit output

    //assign extended[7:0]  = unextended[7:0];
    //assign extended[31:8] = unextended[7] ? 24'd1 : 24'd0;
    always @(unextended) begin
        if(unextended[7] == 1'b0) begin
            extended[31:8] = 24'd0;
            extended[7:0]  = unextended[7:0];
        end else if (unextended[7] == 1'b1) begin
            extended[31:8] = 24'd1;
            extended[7:0]  = unextended[7:0];
        end
    end 
endmodule

module shiftleft_2(IN, OUT);
    input [31:0] IN;
    output[31:0] OUT;

    assign OUT = IN << 2;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Control_unit(OPCODE, WRITEENABLE, MUX1_SELECTOR, MUX2_SELECTOR, ALUOP, ISJUMP, ISBRANCH);
    input [7:0] OPCODE;     //geting INSTRUCTION[31:24] and store in OPCODE
    output reg WRITEENABLE, MUX1_SELECTOR, MUX2_SELECTOR, ISJUMP, ISBRANCH;
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
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000001:                    // for mov
                begin                       // mov 4 1
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data in reg4
                ALUOP           = 3'b000;   // select forward function
                MUX1_SELECTOR   = 1'b0;     // ignore
                MUX2_SELECTOR   = 1'b0;     // 0 for select REGOUT2
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000010:                    //for add
                begin                       //add 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data + reg2 data in reg4
                ALUOP           = 3'b001;   // select add function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000011:                    // for sub
                begin                       // sub 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data - reg2 data in reg4
                ALUOP           = 3'b001;   // select add function
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000100:                    // for and
                begin                       // and 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data & reg2 data in reg4
                ALUOP           = 3'b010;   // select and function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000101:                    // for or
                begin                       // or 4 1 2
                WRITEENABLE     = 1'b1;     // 1 for write the  reg1 data | reg2 data in reg4
                ALUOP           = 3'b011;   // select or function
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000110:                    // for jump
                begin                       // j 0x02
                WRITEENABLE     = 1'b0;     // 0 for don't write 
                //ALUOP           = 3'bxxx; // don't needed //
                MUX1_SELECTOR   = 1'b0;     // 0 for select REGOUT2 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 
                ISJUMP          = 1'b1;     // 0 for jump signal
                ISBRANCH        = 1'b0;     // 0 for don't branch signal
                end
            8'b00000111:                    // for branch equal
                begin                       // beq 0xFE
                WRITEENABLE     = 1'b0;     // 0 for don't write
                ALUOP           = 3'b001;   // select add function  //for sub
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
                ISJUMP          = 1'b0;     // 0 for don't jump signal
                ISBRANCH        = 1'b1;     // 0 for branch signal
                end

            8'b00001000:                    // for branch not equal
                begin                       // beq 0xFE
                WRITEENABLE     = 1'b0;     // 0 for don't write
                ALUOP           = 3'b001;   // select add function  //for sub
                MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
                MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
                ISJUMP          = 1'b1;     // 0 for don't jump signal
                ISBRANCH        = 1'b1;     // 0 for branch signal
                end

            // 8'b00000111:                    // for logical left
            //     begin                       // beq 0xFE
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     ALUOP           = 3'b001;   // select add function  //for sub
            //     MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
            //     MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b1;     // 0 for branch signal
            //     end
            
            // 8'b00000111:                    // for logical right
            //     begin                       // beq 0xFE
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     ALUOP           = 3'b001;   // select add function  //for sub
            //     MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
            //     MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b1;     // 0 for branch signal
            //     end
            
            // 8'b00000111:                    // for arithmetic left
            //     begin                       // beq 0xFE
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     ALUOP           = 3'b001;   // select add function  //for sub
            //     MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
            //     MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b1;     // 0 for branch signal
            //     end
            
            // 8'b00000111:                    // for arithmetic right
            //     begin                       // beq 0xFE
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     ALUOP           = 3'b001;   // select add function  //for sub
            //     MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
            //     MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b1;     // 0 for branch signal
            //     end

            // 8'b00000111:                    // for ror
            //     begin                       // beq 0xFE
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     ALUOP           = 3'b001;   // select add function  //for sub
            //     MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
            //     MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b1;     // 0 for branch signal
            //     end

            // 8'b00000111:                    // for branch not equal
            //     begin                       // beq 0xFE
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     ALUOP           = 3'b001;   // select add function  //for sub
            //     MUX1_SELECTOR   = 1'b1;     // 1 for select REGOUT2 2'sCompiliment 
            //     MUX2_SELECTOR   = 1'b0;     // 0 for 0 for select REGOUT2 2'sCompiliment 
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b1;     // 0 for branch signal
            //     end


            // default:
            //     begin                       
            //     WRITEENABLE     = 1'b0;     // 0 for don't write
            //     //ALUOP           = 3'b000;   
            //     //MUX1_SELECTOR   = 1'b1;     
            //     //MUX2_SELECTOR   = 1'b0;     
            //     ISJUMP          = 1'b0;     // 0 for don't jump signal
            //     ISBRANCH        = 1'b0;     // 0 for don't branch signal
            //     end
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

//this is a implementation of a 2 to 1 multiplexer for PC module
module mux2_1_forPC(input0, input1, mux_result, mux_seletor);
    input [31:0] input0;         //input ports
    input [31:0] input1;         
    output[31:0] mux_result;    
    input mux_seletor;          //1 bit selector

    assign mux_result = mux_seletor ? input1 : input0;  //if mux_seletor = 1; select input1
                                                        //if mux_seletor = 0; select input0
endmodule

//this is a implementation of a 4 to 1 multiplexer for jump branch selector module
module mux4_1(input0, input1, input2, input3, mux_result, mux_seletor_branch, mux_seletor_jump);
    input  mux_seletor_branch, mux_seletor_jump;         
    input  input0, input1, input2, input3;         //input ports
    output mux_result;    


    assign mux_result = mux_seletor_branch ? (mux_seletor_jump ? input3 : input2) : (mux_seletor_jump ? input1 : input0);

    //branch  jump   result
    //  0       0    input0    
    //  0       1    input1
    //  1       0    input2
    //  1       1    input3'

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module alu(DATA1, DATA2, RESULT, ZERO, SELECT);

    input [7:0] DATA1;
    input [7:0] DATA2;
    input [2:0] SELECT;
    output reg [7:0] RESULT;

    output reg ZERO = 1'b0; //create 1 bit zero port with initilazaion 0

    //Creating wires for getting the outputs.
    wire [7:0] FORWARD_result, ADD_result, AND_result, OR_result;

    //initiate functions, and assign the results to the wires.
    FORWARD FORWARD_1(DATA2, FORWARD_result);
    ADD     ADD_1(DATA1, DATA2, ADD_result);
    AND     AND_1(DATA1, DATA2, AND_result);
    OR      OR_1(DATA1, DATA2, OR_result);

    always @(ADD_result) begin
        if (ADD_result == 8'b00000000) begin
            ZERO = 1'b1;
        end else begin
            ZERO = 1'b0;
        end
    end

    //This always block is executed whenever values in this sensitivity list change. 
    always @ (SELECT or FORWARD_result or ADD_result or AND_result or OR_result) begin
        case (SELECT)
            3'b000:  RESULT = FORWARD_result;    //FORWARD forward1 (DATA2, RESULT);
                
            3'b001:  RESULT = ADD_result;        //ADD add1(DATA1, DATA2, RESULT);
                
            3'b010:  RESULT = AND_result;        //AND and1(DATA1, DATA2, RESULT);
            
            3'b011:  RESULT = OR_result;         //OR or1(DATA1, DATA2, RESULT);

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

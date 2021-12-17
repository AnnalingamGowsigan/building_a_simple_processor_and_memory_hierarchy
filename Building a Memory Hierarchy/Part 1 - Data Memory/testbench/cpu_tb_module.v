// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: group 35
`include "cpu_module.v"
`include "lab6_modules.v"


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
    // char *op_bne	    = "00010000";

    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem                                                                     //      wA 1A 2A      
                                                                                                                                    //      rd rt rs
        // {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]}        = 32'b00000000_00000000_00000000_00001001;  //loadi 0     #9
        // {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]}        = 32'b00000110_00000001_00000000_00000000;  //j     #1     
        // {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]}      = 32'b00000000_00000001_00000000_00000100;  //loadi 1     #8
        // {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]}    = 32'b00000000_00000001_00000000_00001010;  //loadi 1     #10  
        // {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]}    = 32'b00001000_00000011_00000001_00000000;  //bne   #3  1  0
        // {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]}    = 32'b00000000_00000010_00000000_00001001;  //loadi 2     #9
        // {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]}    = 32'b00000111_00000001_00000010_00000000;  //beq   #1  2  0
        // {instr_mem[10'd31], instr_mem[10'd30], instr_mem[10'd29], instr_mem[10'd28]}    = 32'b00000011_00000011_00000000_00000001;  //sub   3   0  1
        // {instr_mem[10'd35], instr_mem[10'd34], instr_mem[10'd33], instr_mem[10'd32]}    = 32'b00001001_00000011_00000000_00000001;  //mult  3   0  1
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("..\\CPU Programming Tools-20220123\\instr_mem.mem", instr_mem);
        $readmemb("..\\CPU Programming Tools-20220123\\instr_mem.mem", instr_mem,0, 15);
        //$readmemb("instr_mem.mem", instr_mem, 0, 11);//  0 , (instruction * 4)-1

    end
    
    /* 
    -----
     CPU
    -----
    */
    wire WRITE, READ, BUSYWAIT;
    wire [7:0] REGOUT1, ALURESULT, READDATA;

    cpu mycpu(PC, INSTRUCTION, CLK, RESET, WRITE, READ, BUSYWAIT, REGOUT1, ALURESULT, READDATA);
    //cpu mycpu(PC, INSTRUCTION, CLK, RESET);
    data_memory mydata_memory(CLK  , RESET, READ, WRITE, ALURESULT, REGOUT1  , READDATA, BUSYWAIT);
    //data_memory            (clock, reset, read, write, address  , writedata, readdata, busywait);

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

        // finish simulation after some time
        #250
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        
endmodule



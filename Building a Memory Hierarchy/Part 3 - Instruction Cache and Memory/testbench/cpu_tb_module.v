// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: group 35
`include "cpu_module.v"
`include "data_memory.v"
`include "data_memory_cache.v"
`include "InstructionMemory.v"
`include "InstructionMemoryCache.v"



`timescale 1ns/100ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    //reg [31:0] INSTRUCTION;
    wire I_BUSYWAIT_FOR_CPU;


    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory

    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)

    wire i_mem_read, i_mem_busywait; 
    wire [5:0]i_mem_address;
    wire [127:0]i_mem_readdata;

    wire [9:0] PC_FOR_INSTR;        //################################
    assign PC_FOR_INSTR = PC[9:0];  //################################

    mcache mymcache (CLK,RESET,PC_FOR_INSTR  ,INSTRUCTION,INSTR_CACHE_BUSYWAIT_FOR_CPU,i_mem_read,i_mem_address,i_mem_readdata,i_mem_busywait);
    //module mcache (CLK,RESET,I_ADDRESS     ,I_READDATA ,I_BUSYWAIT                  ,i_mem_read,i_mem_address,i_mem_readdata,i_mem_busywait);
    
    instruction_memory myinstruction_memory(CLK  ,i_mem_read,i_mem_address,i_mem_readdata,i_mem_busywait);
    //module instruction_memory            (clock,read      ,address      ,readinst      ,busywait);

    //(clock,reset,C_WRITE,C_READ,C_Address,C_WRITEDATA,C_READDATA,busywait,mem_write,mem_read,mem_address,mem_writedata,mem_readdata,mem_busywait);
    // initial begin
    //     //check the registers
    //     $monitor($time, " REG0: %d  REG1: %d  REG2: %d  REG3: %d  REG4: %d  REG5: %d  REG6: %d  REG7: %d ",mycpu.my_reg_file.register[0], mycpu.my_reg_file.register[1], mycpu.my_reg_file.register[2],mycpu.my_reg_file.register[3], mycpu.my_reg_file.register[4], mycpu.my_reg_file.register[5],mycpu.my_reg_file.register[6], mycpu.my_reg_file.register[7]);
    // end

    /* 
    -----
     CPU
    -----
    */

    wire WRITE, READ, DATA_CACHE_BUSYWAIT;
    wire [7:0] REGOUT1, ALURESULT, READDATA;
    wire mem_write, mem_read, mem_busywait;
    wire [5:0] mem_address;
    wire [31:0] mem_writedata, mem_readdata;

    cpu mycpu(PC, INSTRUCTION, CLK, RESET, WRITE, READ, DATA_CACHE_BUSYWAIT, REGOUT1, ALURESULT, READDATA, INSTR_CACHE_BUSYWAIT_FOR_CPU);
    //cpu mycpu(PC, INSTRUCTION, CLK, RESET);
    
    dcache mydcache (CLK,RESET,WRITE  ,READ  ,ALURESULT,REGOUT1    ,READDATA  ,DATA_CACHE_BUSYWAIT, mem_write,mem_read,mem_address,mem_writedata,mem_readdata,mem_busywait);
    //module dcache (CLK,RESET,C_WRITE,C_READ,C_ADDRESS,C_WRITEDATA,C_READDATA,C_BUSYWAIT         , mem_write,mem_read,mem_address,mem_writedata,mem_readdata,mem_busywait);

    data_memory mydata_memory(CLK  , RESET, mem_read, mem_write, mem_address, mem_writedata  , mem_readdata, mem_busywait);
    //data_memory            (clock, reset, read    , write    , address    , writedata      , readdata     , busywait);

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
        #2000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        
endmodule



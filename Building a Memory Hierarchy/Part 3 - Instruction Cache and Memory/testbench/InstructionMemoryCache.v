/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/
`timescale 1ns/100ps
module mcache (
    CLK,
    RESET,

    I_ADDRESS,
    I_READDATA,
    I_BUSYWAIT,

    i_mem_read,
    i_mem_address,
    i_mem_readdata,
    i_mem_busywait);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    input  CLK, RESET;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    input [9:0] I_ADDRESS;
    output reg I_BUSYWAIT;
    output reg [31:0] I_READDATA; // pc
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    input i_mem_busywait;
    input  [127:0] i_mem_readdata;
    output reg [5:0] i_mem_address;
    output reg i_mem_read;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Declare cache memory
    reg [127:0] instr_cache_data_array [7:0];   // data array 128x8-bits 
    reg instr_cache_vaildbit_array[7:0];        //  store vaild bit values
    reg [2:0] instr_cache_tag_array [7:0];      //  store tag values

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */

    //splitting the CPU given address in to tag,index and offset
    wire [2:0] tag;
    wire [2:0] index;
    wire [3:0] offset;

    assign offset = I_ADDRESS[3:0]; //4 bit for offset
    assign index  = I_ADDRESS[6:4]; //3 bit for offset
    assign tag    = I_ADDRESS[9:7]; //3 bit for tag

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [127:0] instr_cache_datablock;
    reg instr_cache_validbit;
    reg [2:0] instr_cache_tag;

    
    always @(*) begin 
        #1 //one time unit delay for extracting the stored values in cache in given index

        instr_cache_datablock=  instr_cache_data_array[index];
        instr_cache_tag      =  instr_cache_tag_array[index];
        instr_cache_validbit =  instr_cache_vaildbit_array[index];      //valid bit
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //tag comparison and deciding whether its a hit or a miss 
    wire isHit, isTagMatch;

    assign #0.9 isTagMatch = (instr_cache_tag == tag)? 1 : 0;
    assign isHit = isTagMatch && instr_cache_validbit;
    // cache can  detect the Hit status after #1.9 after address is arrived
    
    always @(posedge CLK) begin                                                //###//
        // once hit is detected ,de-assert the busywait signal
        if (isHit == 1) begin
            I_BUSYWAIT = 0; 
        end
    end

    reg [127:0] temp_I_READDATA;
    always @(*) begin  //always @(offset, cache_tag) begin 
        //this delay will overlap with tag comaprison delay of 0.9
        case(offset)
                 //1 time unit for data word selection
            4'b0000 : #1 temp_I_READDATA = instr_cache_datablock[31:0]; 
            4'b0100 : #1 temp_I_READDATA = instr_cache_datablock[63:32];
            4'b1000 : #1 temp_I_READDATA = instr_cache_datablock[95:64];
            4'b1100 : #1 temp_I_READDATA = instr_cache_datablock[127:96];
        endcase 
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //read hit
    always @(*) begin  
        if(isHit == 1) begin
            I_READDATA = temp_I_READDATA;
            //I_BUSYWAIT = 0; 
        end
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, I_MEM_READ = 3'b001, I_CACHE_UPDATE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!isHit)
                    next_state = I_MEM_READ;                 
                else
                    next_state = IDLE;
            
            I_MEM_READ:
                if (!i_mem_busywait)
                    next_state = I_CACHE_UPDATE;
                else    
                    next_state = I_MEM_READ;
            
            I_CACHE_UPDATE: //next state after writing in cache from data received from memory is IDLE	
                next_state = IDLE;
            
        endcase
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                i_mem_read = 0;
                i_mem_address = 6'dx;
                I_BUSYWAIT = 0;
            end
         
            I_MEM_READ: 
            begin
                i_mem_read = 1;
                i_mem_address = {tag, index};
                I_BUSYWAIT = 1;
            end

			I_CACHE_UPDATE: 
            begin
                i_mem_read = 1'd0;
                i_mem_address = 6'dx;
                I_BUSYWAIT = 1'd1;

                //this writing operation happens in the cache block after fetching the memory
                //there is 1 time unit delay for this operation
				#1;
				instr_cache_data_array[index]     = i_mem_readdata;	//write a data block to the cache
				instr_cache_tag_array[index]      = tag;	
				instr_cache_vaildbit_array[index] = 1'd1;	//valid bit
            end
        endcase

    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    integer j;
    // sequential logic for state transitioning 
    always @(posedge CLK, RESET)
    begin
        if(RESET) begin
            state = IDLE;

            //reset the cache after 1 time unit delay
            #1
            for(j=0; j<8; j=j+1) begin
                instr_cache_data_array[j] = 32'd0;
                instr_cache_tag_array[j] = 3'b0;
                instr_cache_vaildbit_array[j] = 1'b0;
            end

        end else begin
            state = next_state;
        end
    end
    /* Cache Controller FSM End */

endmodule
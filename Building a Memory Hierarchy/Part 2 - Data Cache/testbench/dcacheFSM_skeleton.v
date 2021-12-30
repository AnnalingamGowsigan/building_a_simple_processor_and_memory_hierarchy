/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/
`timescale 1ns/100ps
module dcache (
    CLK,
    RESET,

    C_WRITE,
    C_READ,
    C_ADDRESS,
    C_WRITEDATA,
    C_READDATA,
    C_BUSYWAIT,

    mem_write,
    mem_read,
    mem_address,
    mem_writedata,
    mem_readdata,
    mem_busywait);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    input  CLK, RESET;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    input C_WRITE, C_READ;
    input [7:0] C_WRITEDATA, C_ADDRESS;
    output reg C_BUSYWAIT;
    output reg [7:0] C_READDATA;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    input mem_busywait;
    input  [31:0] mem_readdata;
    output reg [31:0] mem_writedata;
    output reg [5:0] mem_address;
    output reg mem_write, mem_read;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Declare cache memory
    reg [31:0] cache_data_array [7:0]; // data array 32x8-bits 
    reg cache_vaildbit_array[7:0];     //  store vaild bit values
    reg cache_dirtybit_array[7:0];     //  store dirty bit values
    reg [2:0] cache_tag_array [7:0];   //  store tag values
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Detecting an incoming cashe memory access
    reg readaccess, writeaccess;
    always @(*)
    begin
        C_BUSYWAIT  = (C_READ || C_WRITE)?  1 : 0;
        readaccess  = (C_READ && !C_WRITE)? 1 : 0;
        writeaccess = (!C_READ && C_WRITE)? 1 : 0;
    end
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
    wire [1:0] offset;

    assign offset = C_ADDRESS[1:0];
    assign index  = C_ADDRESS[4:2];
    assign tag    = C_ADDRESS[7:5];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [31:0] cache_datablock;
    reg cache_dirtybit, cache_validbit;
    reg [2:0] cache_tag;

    
    always @(*) begin 
        if (readaccess == 1 || writeaccess == 1) begin

            #1 //one time unit delay for extracting the stored values in cache in given index
            cache_datablock=  cache_data_array[index];
            cache_tag      =  cache_tag_array[index];
            cache_dirtybit =  cache_dirtybit_array[index];      //dirty bit
            cache_validbit =  cache_vaildbit_array[index];      //valid bit
        end
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //tag comparison and deciding whether its a hit or a miss 
    wire isHit, isTagMatch;

    assign #0.9 isTagMatch = (cache_tag == tag)? 1 : 0;
    assign isHit = isTagMatch && cache_validbit;
    // cache can  detect the Hit status after #1.9 after address is arrived
    
    // always @(isHit) begin                                                //###//
    //     // once hit is detected ,de-assert the busywait signal
    //     if (isHit == 1) begin
    //         C_BUSYWAIT = 0; 
    //     end
    // end

    reg [7:0] temp_C_READDATA;
    always @(*) begin
        //when extracting the stored values in cache in given index, this always block is running
        //this delay will overlap with tag comaprison delay of 0.9
        case(offset)
                 //1 time unit for data word selection
            2'b00 : #1  temp_C_READDATA = cache_datablock[7:0]; 
            2'b01 : #1  temp_C_READDATA = cache_datablock[15:8];
            2'b10 : #1  temp_C_READDATA = cache_datablock[23:16];
            2'b11 : #1  temp_C_READDATA = cache_datablock[31:24];
        endcase 
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //read hit
    always @(*) begin  
        if(isHit == 1 && readaccess == 1) begin
            C_READDATA = temp_C_READDATA;
            //readaccess = 0;
            C_BUSYWAIT = 0; 
        end
        if(isHit == 1 && writeaccess == 1) begin 
            C_BUSYWAIT = 0; 
        end
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //write hit
    always @(posedge CLK)begin 
        if(isHit == 1 && readaccess == 1) begin 
            readaccess = 0;
        end
        
        if(isHit == 1 && writeaccess == 1) begin 
            //C_BUSYWAIT = 0;
            #1
            case(offset)
                //Dataword is written to the cache based on the offset
                2'b00	:   cache_data_array[index][7:0]   = C_WRITEDATA;
                2'b01 	:	cache_data_array[index][15:8]  = C_WRITEDATA;
                2'b10 	:	cache_data_array[index][23:16] = C_WRITEDATA;
                2'b11   :	cache_data_array[index][31:24] = C_WRITEDATA;
            endcase

            cache_dirtybit_array[index] = 1'b1;      //set dirtybit = 1
            cache_vaildbit_array[index] = 1'b1;      //set validbit = 1  
            writeaccess = 1'b0;         //to prevent accessing memory for writing 
        end
    end     
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////











/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, CACHE_UPDATE = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((C_READ || C_WRITE) && !cache_dirtybit && !isHit)     //if the existing block is not dirty ,the missing block should be fetched from memory
                    next_state = MEM_READ;                 //memory read
                else if ((C_READ || C_WRITE) && cache_dirtybit && !isHit) //if the existing block is dirty ,that block must be written back to the memory before fetching the missing block
                    next_state = MEM_WRITE;                //write-back
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = CACHE_UPDATE;
                else    
                    next_state = MEM_READ;
            
            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;  //after memory writing, start the memory reading
                else    
                    next_state = MEM_WRITE; //write back to the memory
            
            CACHE_UPDATE: //next state after writing in cache from data received from memory is IDLE	
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
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                C_BUSYWAIT = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                C_BUSYWAIT = 1;
            end

            MEM_WRITE: 
            begin
                mem_read  = 1'd0;
                mem_write = 1'd1;
                mem_address ={cache_tag, index};	//data block address from the cache
                mem_writedata = cache_datablock;
                C_BUSYWAIT = 1;
            end
			
			CACHE_UPDATE: 
            begin
                mem_read = 1'd0;
                mem_write = 1'd0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                C_BUSYWAIT = 1'd1;

                //this writing operation happens in the cache block after fetching the memory
                //there is 1 time unit delay for this operation
				#1;
				cache_data_array[index]     = mem_readdata;	//write a data block to the cache
				cache_tag_array[index]      = tag;	//tag C_Address[7:5]
				cache_dirtybit_array[index] = 1'd0;	//dirty bit=0 since we are writing a data in cache which is also in memory
				cache_vaildbit_array[index] = 1'd1;	//valid bit
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
                cache_data_array[j] = 32'd0;
                cache_tag_array[j] = 3'b0;
                cache_dirtybit_array[j] = 1'b0;
                cache_vaildbit_array[j] = 1'b0;
            end

        end else begin
            state = next_state;
        end
    end
    /* Cache Controller FSM End */

endmodule
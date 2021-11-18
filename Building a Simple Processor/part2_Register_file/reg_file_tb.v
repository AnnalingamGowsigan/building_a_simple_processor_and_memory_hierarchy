// Computer Architecture (CO224) - Lab 05
// Design: Register File Testbench of Simple Processor
// group 35

module reg_file_tb;
    
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
       
    initial
    begin
        CLK = 1'b1;
        
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("wavedata.vcd");
		$dumpvars(0, reg_file_tb);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #5
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #7
        RESET = 1'b0;
        
        #3
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #9
        WRITEENABLE = 1'b0;
        
        #1
        READREG1 = 3'd2;
        
        #9
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #10
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = 3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #5 CLK = ~CLK;
        

endmodule

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

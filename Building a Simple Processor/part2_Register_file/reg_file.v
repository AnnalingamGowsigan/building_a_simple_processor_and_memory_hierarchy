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

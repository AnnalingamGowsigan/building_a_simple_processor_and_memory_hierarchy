module testbench;
    reg [7:0] OPERAND1, OPERAND2;
    reg [2:0] ALUOP;
    wire[7:0] ALURESULT;

    alu alu1(OPERAND1, OPERAND2, ALURESULT, ALUOP);

    initial 
    begin
        //monitor is used observe the values of OPERAND1,OPERAND2, and ALURESULT. 
        $monitor($time, "  OP = %b  DATA1 = %b  DATA2 = %b RESULT = %b",ALUOP,OPERAND1,OPERAND2,ALURESULT);
        //Changing the inputs according to the selection options.
        
        //Forward the DATA2
        ALUOP=3'b000;
        OPERAND1=8'b00000001;
        OPERAND2=8'b00000010;
        #5

        //Addition
        OPERAND1=15;
        OPERAND2=10;
        ALUOP=3'b001;

        #5
        //Bitwise AND
        OPERAND1=6;
        OPERAND2=5;
        ALUOP=3'b010;

        #5
        //Bitwise OR
        OPERAND1=10;
        OPERAND2=6;
        ALUOP=3'b011;

        #5
        ALUOP=3'b101;

        #15 $finish;  
    end

    initial
	begin
		$dumpfile("wavedata.vcd");
		$dumpvars(0, testbench);
	end

endmodule

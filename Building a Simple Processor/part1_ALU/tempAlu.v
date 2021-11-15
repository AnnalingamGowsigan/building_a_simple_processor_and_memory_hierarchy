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



module alu(DATA1, DATA2, RESULT, SELECT);

    input [7:0] DATA1;
    input [7:0] DATA2;
    input [2:0] SELECT;
    output reg [7:0] RESULT;

    //Creating wires for getting the outputs.
    wire [7:0] FORWARD_result, ADD_result, AND_result, OR_result;

    //initiate functions, and assign the results to the wires.
    FORWARD forward1(DATA2, FORWARD_result);
    ADD     add1(DATA1, DATA2, ADD_result);
    AND     and1(DATA1, DATA2, AND_result);
    OR      or1(DATA1, DATA2, OR_result);

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

    // reg RESULT;          //Store the result in register
    // always @(DATA2) begin
    //     #1 RESULT=DATA2;
    // end

    assign #1 RESULT = DATA2; 

endmodule

module ADD(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;
    output[7:0] RESULT;
    
    //reg RESULT;
    // always @(DATA1, DATA2) begin
    //     #2 RESULT = DATA1 + DATA2;
    // end

    assign #2 RESULT = DATA1 + DATA2;
    
endmodule

module AND(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;    //8 bit input data
    output[7:0] RESULT;         //8 bit output data

    // reg RESULT;             //Store the result in register
    // always @(DATA1,DATA2) begin
    //     #1
    //     RESULT=DATA1&DATA2;
    // end

    assign #1 RESULT = DATA1 & DATA2;

endmodule

module OR(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;
    output[7:0] RESULT;

    // reg RESULT;             //Store the result in register
    // always @(DATA1,DATA2) begin
    //     #1
    //     RESULT=DATA1|DATA2;
    // end

    assign #1 RESULT = DATA1 | DATA2;

endmodule
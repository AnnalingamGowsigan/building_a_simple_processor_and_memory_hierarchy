module alu(DATA1, DATA2, RESULT, ZERO, SELECT);

    input [7:0] DATA1;
    input [7:0] DATA2;
    input [2:0] SELECT;
    output reg [7:0] RESULT;

    output reg ZERO = 1'b0; //create 1 bit zero port with initilazaion 0

    //Creating wires for getting the outputs.
    wire [7:0] FORWARD_result, ADD_result, AND_result, OR_result, MULTIPLY_result;

    //initiate functions, and assign the results to the wires.
    FORWARD     FORWARD_1(DATA2, FORWARD_result);
    ADD         ADD_1(DATA1, DATA2, ADD_result);
    AND         AND_1(DATA1, DATA2, AND_result);
    OR          OR_1(DATA1, DATA2, OR_result);

    MULTIPLY    MULTIPLY_1(DATA1, DATA2, MULTIPLY_result);

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

            3'b100:  RESULT = MULTIPLY_result;   //MULTIPLY MULTIPLY_1(DATA1, DATA2, MULTIPLY_result);


            default: RESULT = 8'bxxxxxxxx;      //Default case
        endcase
    end
   
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module MULTIPLY(DATA1, DATA2, RESULT);//DATA1 = multiplicand
                                      //DATA2 = multiplier
    input [7:0] DATA1, DATA2;
    output reg [7:0] RESULT;

    wire [7:0] temp [7:0];

        assign temp[0] = (DATA2[0] == 1) ? {DATA1      } : 8'd0;
        assign temp[1] = (DATA2[1] == 1) ? {DATA1, 1'd0} : 8'd0;
        assign temp[2] = (DATA2[2] == 1) ? {DATA1, 2'd0} : 8'd0;
        assign temp[3] = (DATA2[3] == 1) ? {DATA1, 3'd0} : 8'd0;
        assign temp[4] = (DATA2[4] == 1) ? {DATA1, 4'd0} : 8'd0;
        assign temp[5] = (DATA2[5] == 1) ? {DATA1, 5'd0} : 8'd0;
        assign temp[6] = (DATA2[6] == 1) ? {DATA1, 6'd0} : 8'd0;
        assign temp[7] = (DATA2[7] == 1) ? {DATA1, 7'd0} : 8'd0;

        always @(temp[0] or temp[1] or temp[2] or temp[3] or temp[4] or temp[5] or temp[6] or temp[7]) begin

            #3 RESULT = temp[0] + temp[1] + temp[2] + temp[3] + temp[4] + temp[5] + temp[6] + temp[7];

        end

endmodule
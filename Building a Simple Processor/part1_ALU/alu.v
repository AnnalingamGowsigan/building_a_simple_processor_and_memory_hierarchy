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

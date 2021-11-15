module FORWARD(DATA2, RESULT);
    input [7:0] DATA2;      //data input port
    output [7:0] RESULT;    //data output port

    // reg RESULT;          //Store the result in register
    // always @(DATA2) begin
    //     #1 RESULT=DATA2;
    // end

    assign #1 RESULT = DATA2; 

endmodule
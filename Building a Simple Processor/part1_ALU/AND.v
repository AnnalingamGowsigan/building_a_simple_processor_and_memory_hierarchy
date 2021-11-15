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

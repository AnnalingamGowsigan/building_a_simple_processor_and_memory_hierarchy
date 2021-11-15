module ADD(DATA1, DATA2, RESULT);
    input[7:0] DATA1, DATA2;
    output[7:0] RESULT;
    
    //reg RESULT;
    // always @(DATA1, DATA2) begin
    //     #2 RESULT = DATA1 + DATA2;
    // end

    assign #2 RESULT = DATA1 + DATA2;
    
endmodule
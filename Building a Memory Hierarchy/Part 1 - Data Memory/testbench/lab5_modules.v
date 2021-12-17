/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module signextender(unextended, extended);
    input [7:0] unextended; //the msb bit is the sign bit // 8-bit input
    output reg [31:0] extended; // 32-bit output

    //assign extended[7:0]  = unextended[7:0];
    //assign extended[31:8] = unextended[7] ? 24'd1 : 24'd0;
    always @(unextended) begin
        if(unextended[7] == 1'b0) begin
            extended[31:8] = 24'd0;
            extended[7:0]  = unextended[7:0];
        end else if (unextended[7] == 1'b1) begin
            extended[31:8] = 24'd1;
            extended[7:0]  = unextended[7:0];
        end
    end 
endmodule

module shiftleft_2(IN, OUT);
    input [31:0] IN;
    output[31:0] OUT;

    assign OUT = IN << 2;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//this is used to convert numbers into minus in two's complement
module twosCompliment(in, result);
    input [7:0] in;
    output [7:0] result;

    assign #1 result = ~in + 1;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//this is a implementation of a 2 to 1 multiplexer
module mux2_1(input0, input1, mux_result, mux_seletor);
    input [7:0] input0;         //input ports
    input [7:0] input1;         
    output [7:0] mux_result;    
    input mux_seletor;          //1 bit selector

    assign mux_result = mux_seletor ? input1 : input0;  //if mux_seletor = 1; select input1
                                                        //if mux_seletor = 0; select input0
endmodule

//this is a implementation of a 2 to 1 multiplexer for PC module
module mux2_1_forPC(input0, input1, mux_result, mux_seletor);
    input [31:0] input0;         //input ports
    input [31:0] input1;         
    output[31:0] mux_result;    
    input mux_seletor;          //1 bit selector

    assign mux_result = mux_seletor ? input1 : input0;  //if mux_seletor = 1; select input1
                                                        //if mux_seletor = 0; select input0
endmodule

//this is a implementation of a 4 to 1 multiplexer for jump branch selector module
module mux4_1(input0, input1, input2, input3, mux_result, mux_seletor_branch, mux_seletor_jump);
    input  mux_seletor_branch, mux_seletor_jump;         
    input  input0, input1, input2, input3;         //input ports
    output mux_result;    


    assign mux_result = mux_seletor_branch ? (mux_seletor_jump ? input3 : input2) : (mux_seletor_jump ? input1 : input0);

    //branch  jump   result
    //  0       0    input0    
    //  0       1    input1
    //  1       0    input2
    //  1       1    input3'

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

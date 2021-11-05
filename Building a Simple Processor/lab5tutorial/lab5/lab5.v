// Define the stimulus module (no ports). This is a non-synthesizable module, only to be used for simulation purposes
module Testbench;

	// Declarations of wire, reg, and other variables
	wire q, qbar;
	reg D, Clk; // Insput signals



	// Instantiate lower-level modules
	// In this case, instantiate D_Flip_Flop
	// Feed D and Clk signals to the D_Flip_Flop

	//D_Flip_Flop_Gate_Level_Modeling D1(q, qbar, D, Clk);
	D_Flip_Flop_Behavioral_Modeling D1(q, qbar, D, Clk);


    initial
    begin
      $dumpfile("data.vcd");
      $dumpvars(0,D1);
    end
	
    // Behavioural block, initial
	initial
	begin
		$monitor($time, " Clk = %b, D = %b, q= %b, qbar= %b",Clk,D,q,qbar);

		Clk = 0;
        D = 0;

        #5 
        Clk = 1;
        D = 0;
        
        #5
        Clk = 0;
        D = 1;

		#5 
        Clk = 1;
        D = 1;

	end

endmodule


// D_Flip_Flop module. This is a synthesizable module
module D_Flip_Flop_Gate_Level_Modeling(Q, Qbar, D, Clk);

	//Port declarations
	output wire Q, Qbar;
	input wire D, Clk;

	// Instantiate lower-level modules
	// In this case, instantiate Verilog primitive nor gates
	// Note, how the wires are connected in a cross-coupled fashion.

    wire t1, t2;//create temp wire
    
    and a1(t1, ~D, Clk);
    and a2(t2, D, Clk);
	nor n1(Q, t1, Qbar);
	nor n2(Qbar, t2, Q);

// endmodule statement
endmodule

// D_Flip_Flop module. This is a synthesizable module
module D_Flip_Flop_Behavioral_Modeling(Q, Qbar, D, Clk);

	//Port declarations
	output reg Q, Qbar;
	input wire D, Clk;

    always @(posedge Clk) begin

        Q = D;
        Qbar = ~D;
        
    end
    
// endmodule statement
endmodule



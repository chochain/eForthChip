///
/// @file
/// @brief ICE40 Single-Port Memory modules 16-bit 16K (from ice40/cell_sim.v)
///
module SP256K (
	input [13:0] AD,
	input [15:0] DI,
	input [3:0]  MASKWE,
	input WE, CS, CK, STDBY, SLEEP, PWROFF_N,
	output reg [15:0] DO
);
	logic [15:0] mem [0:16383];
	logic off = SLEEP || ~PWROFF_N;
   
//	integer i;                          // init randomize (not needed)
//	always @(negedge PWROFF_N) begin
//		for (i = 0; i <= 16383; i++)
//			mem[i] = 16'bx;
//	end

	always @(posedge CK, posedge off) begin
		if (off) begin
			DO <= 0;
		end else
        if (STDBY) begin
			DO <= 16'hfeed;
        end else
        if (CS) begin
			if (WE) begin
				if (MASKWE[0]) mem[AD][ 3: 0] <= DI[ 3: 0];
				if (MASKWE[1]) mem[AD][ 7: 4] <= DI[ 7: 4];
				if (MASKWE[2]) mem[AD][11: 8] <= DI[11: 8];
				if (MASKWE[3]) mem[AD][15:12] <= DI[15:12];
				DO <= 16'hbeef;
			end else begin
				DO <= mem[AD];
			end
		end
//        $display("%m MASKWE=%b, WE=%x,CS=%x, DI=%x, DO=%x", MASKWE, WE, CS, DI, DO);
	end
/*   
	specify
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13169-L13182
		$setup(posedge AD, posedge CK, 268);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13183
		$setup(CS, posedge CK, 404);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13184-L13199
		$setup(DI, posedge CK, 143);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13200-L13203
		$setup(MASKWE, posedge CK, 143);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13167
		//$setup(negedge SLEEP, posedge CK, 41505);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13167
		//$setup(negedge STDBY, posedge CK, 1715);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13206
		$setup(WE, posedge CK, 289);
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13207-L13222
		(posedge CK *> (DO : 16'bx)) = 1821;
		// https://github.com/YosysHQ/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13223-L13238
		(posedge SLEEP *> (DO : 16'b0)) = 1099;
	endspecify
*/ 
endmodule


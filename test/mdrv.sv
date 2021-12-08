///
/// Multi Driver modules
///
interface md_io;
    logic       we;
    logic [7:0] ai;
    modport master(output we, ai);
endinterface: md_io

module drv #(N=0) (md_io.master md_if, input clk, en, output logic bsy);
    logic [7:0] idx = 0;
    
    always_comb begin
         md_if.we = 1'b1;
         md_if.ai = idx + N;
         bsy      = (idx < 'h4);
    end // always_comb
    
    always_ff @(posedge clk) begin
        if (en) idx <= idx + 1'b1;
    end
endmodule: drv

module mdrv(md_io.master md_if, input clk, ok);
    logic en[4], bsy[4];
    logic [1:0] mux;
    
    md_io b0_if();       // TODO: array of interfaces?
    md_io b1_if();
    md_io b2_if();
    md_io b3_if();
    drv #(0)  d0(.md_if(b0_if.master), .clk, .en(en[0]), .bsy(bsy[0]));
    drv #(8)  d1(.md_if(b1_if.master), .clk, .en(en[1]), .bsy(bsy[1]));
    drv #(16) d2(.md_if(b2_if.master), .clk, .en(en[2]), .bsy(bsy[2]));
    drv #(24) d3(.md_if(b3_if.master), .clk, .en(en[3]), .bsy(bsy[3]));
    
    always_comb begin
        case (mux)
        2'b00: {md_if.we, md_if.ai} = {b0_if.we, b0_if.ai};
        2'b01: {md_if.we, md_if.ai} = {b1_if.we, b1_if.ai};
        2'b10: {md_if.we, md_if.ai} = {b2_if.we, b2_if.ai};
        2'b11: {md_if.we, md_if.ai} = {b3_if.we, b3_if.ai};
        endcase
    end

    always_ff @(posedge clk) begin
        if (ok) begin
            foreach (en[i]) begin
                en[i] <= (mux == i);
            end
            mux <= mux + 2'b01;
        end
        else mux <= 2'b00;
    end // always_ff
endmodule: mdrv

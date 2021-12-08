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
    always_ff @(posedge clk) begin
        if (en) begin
            md_if.we <= 1'b1;
            md_if.ai <= idx + N;
            bsy      <= (idx < 'h4);
            idx      <= idx + 1'b1;
        end
    end // always_ff
endmodule: drv

module mdrv(md_io.master md_if, input clk, ok);
    logic i, en[2], bsy[2];
    
    md_io b0_if();
    md_io b1_if();
    drv #(0) d0(.md_if(b0_if.master), .clk, .en(en[0]), .bsy(bsy[0]));
    drv #(8) d1(.md_if(b1_if.master), .clk, .en(en[1]), .bsy(bsy[1]));
    
    always_comb begin
        case (en[0])
        1'b0: {md_if.we, md_if.ai} = {b1_if.we, b1_if.ai};
        1'b1: {md_if.we, md_if.ai} = {b0_if.we, b0_if.ai};
        endcase
    end

    always_ff @(posedge clk) begin
        if (ok) begin
            en[0] <= i;
            en[1] <= ~i;
            i     <= ~i;
        end
        else i <= 1'b0;
    end // always_ff
endmodule: mdrv

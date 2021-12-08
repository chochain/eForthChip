///
/// Multi Driver modules
///
interface md_io;
    logic       we;
    logic [7:0] ai;
    modport master(output we, ai);
endinterface: md_io

module drv #(N=0) (md_io.master md_if, input clk, en, output logic bsy);
    logic [7:0] idx;
    always_ff @(posedge clk) begin
        if (!en) idx <= 0;
        else begin
            md_if.we <= 1'b1;
            md_if.ai <= idx + N;
            bsy      <= (idx < 'h4);
            idx      <= idx + 1'b0;
        end
    end // always_ff
endmodule: drv

module mdrv(md_io.master md_if, input clk, ok);
    logic i, en[2], bsy[2];
    
    drv #(0) d0(.md_if, .clk, .en(en[0]), .bsy(bsy[0]));
    drv #(8) d1(.md_if, .clk, .en(en[1]), .bsy(bsy[1]));

    always_ff @(posedge clk) begin
        if (!ok) i <= 0;
        else begin
            en[0] <= i;
            en[1] <= ~i;
            i     <= ~i;
        end
    end // always_ff
endmodule: mdrv

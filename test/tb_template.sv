`timescale 1ps / 1ps
`include "../source/spram.sv"
class Txn;
    bit        we;
    bit [3:0]  bmsk;
    bit [14:0] ai;
    bit [31:0] vi;
    bit [31:0] vo;
endclass: Txn

class Gen;
    Txn        txn;
    Txn        mbx[$];
    event      done;
    int        ngen;
    
    function new(Txn g2d[$], event e);
        this.mbx  = g2d;
        this.done = e;
    endfunction // new
    
    task main(input clk);
        repeat (ngen) begin
            txn  = new();       // create new transaction
            mbx.push_back(txn);
        end
    endtask
endclass: Gen

class Drv;
    Txn        mbx[$];
    virtual    iBus32 bus;      // support both master and slave
    int        ntxn;
    
    function new(Txn g2d[$], virtual iBus32 bus);
        this.mbx = g2d;
        this.bus = bus;
    endfunction // next

    task reset(input rst);
        wait(rst);  // wait for interface reset
        $display("Drv reset start");
        bus.we   <= 1'b0;
        bus.bmsk <= 4'b1111;
        bus.ai   <= 'h0;
        bus.vi   <= 'h0;
        wait(!rst);
        $display("Drv reset done");
    endtask // reset

    task main(input clk);
        forever begin
            Txn txn = mbx.pop_front();
            bus.we  = 0;
            $display("DRV transfer %d", ntxn);
            @(posedge clk);
            bus.ai   = txn.ai;
            bus.bmsk = txn.bmsk;
            if (txn.we) begin
                bus.we = 1'b1;
                bus.vi = txn.vi;
                @(posedge clk);
                $display("%d[%x]: %x", ntxn, txn.ai, (1 << ntxn) | (ntxn & 3));
            end
            else begin
                bus.we = 1'b0;
                @(posedge clk);
                txn.vo = bus.vo;
                @(posedge clk);
                $display("%d[%x]: %x => %x", ntxn, txn.ai, (1 << ntxn) | (ntxn & 3), txn.vo);
            end // else: !if(txn.we)
            ntxn++;
        end
    endtask // drive
endclass // Drv

class Mon;
    Txn mbx[$];
    virtual iBus32 bus;

    function new(Txn m2s[$], virtual iBus32 bus);
        this.mbx  = m2s;
        this.bus  = bus;
    endfunction // new

    task main(input clk);
        forever begin
            Txn txn = new();
            @(posedge clk);
            txn.ai  = bus.ai;
            txn.we  = bus.we;
            txn.vi  = bus.vi;
            if (!bus.we) begin
                txn.we  = 1'b0;
                @(posedge clk);
                @(posedge clk);
                txn.vo = bus.vo;
            end
        end
    endtask // main
endclass // Mon

class Score;
    Txn        mbx[$];
    int        ntxn;
    bit [31:0] mem[20];
    
    function new(Txn m2s[$]);
        this.mbx = m2s;
    endfunction // new

    task main;
        Txn txn;
        forever begin
            #50;
            txn = mbx.pop_front();
            if (txn.we) begin
                mem[txn.ai]  = txn.vi;
                ntxn++;
            end
            else begin
                $display("A=%0h, %x==%x %s", txn.ai, mem[txn.ai], txn.vo, mem[txn.ai]==txn.vo ? "ok" : "err");
            end
        end
    endtask // main
    
endclass // Score

class Env;
    Gen     gen;
    Drv     drv;
    Mon     mon;
    Score   scb;
    
    Txn     g2d[$];
    Txn     m2s[$];
    
    event   done;
    virtual iBus32 bus;

    function new(virtual iBus32 bus);
        this.bus  = bus;
        gen = new(g2d, done);
        drv = new(g2d, bus);
        mon = new(m2s, bus);
        scb = new(m2s);
    endfunction // new

    task setup(input rst);
        drv.reset(rst);
    endtask // setup

    task test(input clk);
        fork
            gen.main(clk);
            drv.main(clk);
            mon.main(clk);
            scb.main();
        join_any
    endtask // test

    task teardown();
        wait(done.triggered);
        wait(gen.ngen == drv.ntxn);
        wait(gen.ngen == scb.ntxn);
    endtask // teardown

    task run(input clk, rst);
        setup(rst);
        test(clk);
        teardown();
        $finish;
    endtask // run
endclass // Env

module tb_top;
    bit clk, rst;

    iBus32       bus(clk);
    spram32_32k  mem(bus, clk);
    Env          env;
    
    always #10 clk = ~clk;

    initial begin
        rst      = 1;
        #10 rst  = 0;
    end
    
    initial begin
        env           = new(bus);  // create test environment
        env.gen.ngen  = 10;
        env.run(clk, rst);
    end

    initial begin
        $dumpfile("dump.vcd"); $dumpvars;
    end
endmodule // tb_top



`include "Instrmem.sv"

module Instrmem_tb;
    logic rst;
    logic [31:0]addr_i,instruction_o;
    Instrmem DUT
    (
        .addr_i(addr_i),
        .instruction_o(instruction_o)
    );

    initial begin

        addr_i=32'd4;
        #2;
        addr_i=32'd8;
        #2;
        addr_i=32'd1236;
        #2;
        addr_i=32'd136;
        $finish;
    end
    //Monitor values at posedge
    //Value change dump
    initial begin
        $dumpfile("Instrmem_dump.vcd");
        $dumpvars(1, DUT);
    end
    initial begin
        $monitor("addr=%b out=%h",addr_i,instruction_o);
    end
endmodule
`include "RISC_V.sv"

module RISC_V_tb;
  logic rst, clk;
  RISC_V RISC_R_instance (
      .clk(clk),
      .rst(rst)
  );

  //clock generation
  localparam CLK_PERIOD = 2;
  initial begin
    clk = 0;
    forever begin
      #(CLK_PERIOD / 2);
      clk = ~clk;
    end
  end
  //Testbench

  initial begin
    rst = 1;
    @(posedge clk);
    rst = 0;
    repeat (100) @(posedge clk);
    $finish;
  end

  //Monitor values at posedge
  always @(posedge clk) begin
    $display(
        "PC=%d rdata1=%d rdata2=%d Imm=%d wb_sel=%b A_sel=%b bsel=%b\nwdata=%h factorial=%d num=%d aluout=%d aluctrl=%d",
        RISC_R_instance.data_path_instance.PC, RISC_R_instance.data_path_instance.rdata1,
        RISC_R_instance.data_path_instance.rdata2, RISC_R_instance.data_path_instance.imm,
        RISC_R_instance.data_path_instance.wb_sel, RISC_R_instance.data_path_instance.A_sel,
        RISC_R_instance.data_path_instance.B_sel, RISC_R_instance.data_path_instance.wdata,
        RISC_R_instance.data_path_instance.Regfile_instance.mem[10],
        RISC_R_instance.data_path_instance.Regfile_instance.mem[11],
        RISC_R_instance.data_path_instance.ALU_o, RISC_R_instance.data_path_instance.ALUctrl);
  end
  initial begin
    $dumpfile("RISC_R_dump.vcd");
    $dumpvars;
  end
endmodule

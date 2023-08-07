`include "data_path.sv"
`include "Controller.sv"
module RISC_V (
    input logic clk,
    input logic rst
);
  logic [31:0] instruction, wdata_mem, rdata2;
  logic reg_wr, A_sel, PC_sel, B_sel, br_taken, mem_wr;
  logic [2:0] load_ctrl;
  logic [1:0] wb_sel;
  logic [1:0] mem_col;
  logic [3:0] ALUctrl;
  logic [3:0] mask;
  Controller Controller_instance (
      .clk(clk),
      .rst(rst),
      .instruction(instruction),
      .b_taken(br_taken),
      .ALUctrl(ALUctrl),
      .load_ctrl(load_ctrl),
      .mem_wr(mem_wr),
      .A_sel(A_sel),
      .B_sel(B_sel),
      .wb_sel(wb_sel),
      .reg_wr(reg_wr),
      .PC_sel(PC_sel)

  );
  data_path data_path_instance (
      .clk(clk),
      .rst(rst),
      .reg_wr(reg_wr),
      .A_sel(A_sel),
      .B_sel(B_sel),
      .mem_wr(mem_wr),
      .PC_sel(PC_sel),
      .wb_sel(wb_sel),
      .load_ctrl(load_ctrl),
      .ALUctrl(ALUctrl),
      .instruction(instruction),
      .b_taken(br_taken)
  );
endmodule

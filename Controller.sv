`include "LS_controller.sv"
module Controller (
    input clk,
    input rst,
    input logic [31:0] instruction,
    input logic [1:0] mem_col,
    input logic b_taken,
    output logic [31:0] wdata_mem,
    output logic [3:0] ALUctrl,
    output logic [2:0] load_ctrl,
    output logic [3:0] mask,
    output logic mem_wr,
    output logic A_sel,
    B_sel,
    reg_wr,
    PC_sel,
    output logic [1:0] wb_sel,
    input logic [31:0] rdata2
);
  localparam R_type = 5'b01100;
  localparam I_type = 5'b00100;
  localparam Load_type = 5'b00000;
  localparam S_type = 5'b01000;
  localparam B_type = 5'b11000;
  localparam J_type = 5'b11011;
  localparam Jalr_type = 5'b11001;
  localparam lui_type = 5'b01101;
  localparam auipc_type = 5'b00101;
  logic [6:0] opcode;
  logic func7;
  logic [2:0] func3;
  assign func3  = instruction[14:12];
  assign opcode = instruction[6:0];
  assign func7  = instruction[30];
  LS_controller LS_controller_instance (
      .func3(func3),
      .address(mem_col),
      .rdata2(rdata2),
      .wdata_mem(wdata_mem),
      .load_ctrl(load_ctrl),
      .mask(mask)
  );
  always_comb begin
    case (instruction[6:2])
      R_type: begin
        casex ({
          func7, func3
        })
          4'b0000: ALUctrl = 4'd0;  //ADD
          4'b1000: ALUctrl = 4'd1;  //Sub
          4'bX001: ALUctrl = 4'd2;  //SLL
          4'bX010: ALUctrl = 4'd3;  //SLT
          4'bX100: ALUctrl = 4'd4;  //XOR
          4'bX011: ALUctrl = 4'd5;  //SLTU
          4'b0101: ALUctrl = 4'd6;  //SRL
          4'b1101: ALUctrl = 4'd7;  //SRA
          4'bX110: ALUctrl = 4'd8;  //OR
          4'bX111: ALUctrl = 4'd9;  //AND
          default: ALUctrl = 4'bXXXX;
        endcase
        A_sel  = 1;
        PC_sel = 0;
        mem_wr = 0;
        B_sel  = 0;
        wb_sel = 2'b01;
        reg_wr = 1;
      end
      I_type: begin
        casex ({
          func7, func3
        })
          4'bX000: ALUctrl = 4'd0;  //ADD
          4'bX001: ALUctrl = 4'd2;  //SLL
          4'bX010: ALUctrl = 4'd3;  //SLT
          4'bX100: ALUctrl = 4'd4;  //XOR
          4'bX011: ALUctrl = 4'd5;  //SLTU
          4'b0101: ALUctrl = 4'd6;  //SRL
          4'b1101: ALUctrl = 4'd7;  //SRA
          4'bX110: ALUctrl = 4'd8;  //OR
          4'bX111: ALUctrl = 4'd9;  //AND
          default: begin
            ALUctrl = 4'bXXXX;
            $display("run %b%b", func7, func3);
          end
        endcase
        mem_wr = 0;
        A_sel  = 1;
        PC_sel = 0;
        B_sel  = 1;
        wb_sel = 2'b01;
        reg_wr = 1;
      end
      Load_type: begin
        mem_wr  = 0;
        A_sel   = 1;
        PC_sel  = 0;
        B_sel   = 1;
        wb_sel  = 2'b10;
        reg_wr  = 1;
        ALUctrl = 4'd0;
      end
      S_type: begin
        mem_wr  = 1;
        A_sel   = 1;
        PC_sel  = 0;
        B_sel   = 1;
        wb_sel  = 'x;
        reg_wr  = 0;
        ALUctrl = 4'd0;
      end
      B_type: begin
        mem_wr  = 0;
        A_sel   = 0;
        B_sel   = 1;
        wb_sel  = 'x;
        reg_wr  = 0;
        ALUctrl = 4'd0;
        case (b_taken)
          0: PC_sel = 0;
          1: PC_sel = 1;
          default: PC_sel = 'x;
        endcase
      end
      J_type: begin
        mem_wr  = 0;
        A_sel   = 0;
        B_sel   = 1;
        wb_sel  = 2'b00;
        reg_wr  = 1;
        ALUctrl = 4'd0;
        PC_sel  = 1'b1;
      end
      Jalr_type: begin
        mem_wr  = 0;
        A_sel   = 1;
        B_sel   = 1;
        wb_sel  = 2'b00;
        reg_wr  = 1'b1;
        ALUctrl = 4'd0;
        PC_sel  = 1'b1;
      end
      lui_type: begin
        mem_wr  = 0;
        A_sel   = 1'bx;
        B_sel   = 1;
        wb_sel  = 2'b01;
        reg_wr  = 1'b1;
        ALUctrl = 4'd10;
        PC_sel  = 1'b0;
      end
      auipc_type: begin
        mem_wr  = 0;
        A_sel   = 0;
        B_sel   = 1;
        wb_sel  = 2'b01;
        reg_wr  = 1;
        ALUctrl = 4'd0;
        PC_sel  = 1'b0;
      end
      default: begin
        mem_wr = 'x;
        B_sel  = 'x;
        wb_sel = 'x;
        reg_wr = 'x;
      end
    endcase
  end
endmodule

`include "Instrmem.sv"
`include "Regfile.sv"
`include "ALU.sv"
`include "data_mem.sv"
`include "Branch_block.sv"
module data_path (
    input logic clk,
    rst,
    reg_wr,
    A_sel,
    B_sel,
    mem_wr,
    PC_sel,
    input logic [1:0] wb_sel,
    input logic [2:0] load_ctrl,
    input logic [3:0] ALUctrl,
    output logic [31:0] instruction,
    output logic b_taken
);
  localparam I_type = 5'b00100;
  localparam Load_type = 5'b00000;
  localparam B_type = 5'b11000;
  localparam S_type = 5'b01000;
  localparam J_type = 5'b11011;
  localparam Jalr_type = 5'b11001;
  localparam lui_type = 5'b01101;
  localparam auipc_type = 5'b00101;
  logic [31:0] instruction_addr;
  logic [31:0] wdata, ALUresult, ReadData, rdata1, rdata2;
  logic [31:0] PC, PC_mux_o;
  logic [4:0] raddr1, raddr2, waddr;
  logic [31:0] rd2;
  logic RegWrite;
  logic [2:0] func3;
  logic [31:0] ALU_o;
  logic [31:0] mem_data;
  logic [31:0] imm, ALU_op_b, ALU_op_a;
  logic [1:0] mem_col;
  assign mem_col = ALU_o[1:0];
  assign func3   = instruction[14:12];
  assign raddr1  = instruction[19:15];
  assign raddr2  = instruction[24:20];
  assign waddr   = instruction[11:7];
  //PC counter
  initial begin
    $readmemh("instructions.txt", Instrmem_instance.instrmem);
    $readmemh("registervalues.txt", Regfile_instance.mem);
  end
  assign PC_mux_o = PC_sel ? ALU_o : PC + 4;
  always_ff @(posedge clk) begin
    if (rst) PC <= 32'd0;
    else PC <= PC_mux_o;
  end
  assign ALU_op_a = A_sel ? rdata1 : PC;
  assign ALU_op_b = B_sel ? imm : rdata2;
  always_comb begin
    case (wb_sel)
      2'b00:   wdata = PC + 4;
      2'b01:   wdata = ALU_o;
      2'b10:   wdata = mem_data;
      default: wdata = 'bx;
    endcase
  end
  Regfile Regfile_instance (
      .rst(1'b0),
      .clk(clk),
      .write_en(reg_wr),
      .rs1_in(raddr1),
      .rs2_in(raddr2),
      .rd(waddr),
      .write_data(wdata),
      .rs1_out(rdata1),
      .rs2_out(rdata2)
  );
  ALU ALU_instance (
      .a_in(ALU_op_a),
      .b_in(ALU_op_b),
      .ALUctrl(ALUctrl),
      .result_o(ALU_o)
  );
  Instrmem Instrmem_instance (
      .addr_i(PC),
      .instruction_o(instruction)
  );
  data_mem data_mem_instance (
      .clk(clk),
      .rst(rst),
      .mem_wr(mem_wr),
      .addr(ALU_o),
      .data_wr(rdata2),
      .func3(func3),
      .mem_col(mem_col),
      .mem_data(mem_data)
  );
  //Immidiate generation
  always_comb begin
    casex (instruction[6:2])
      Load_type, I_type: imm = {{20{instruction[31]}}, instruction[31:20]};  //load,I
      Jalr_type: imm = {{20{instruction[31]}}, instruction[31:20]};
      S_type: imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  //save
      J_type:
      imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
      B_type:
      imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
      lui_type, auipc_type: imm = {{instruction[31:12]}, {12{1'b0}}};
      default: begin
        imm = 'x;
      end
    endcase
  end
  Branch_block Branch_block_instance (
      .op_a(rdata1),
      .op_b(rdata2),
      .func3(func3),
      .branch_taken(b_taken)
  );
endmodule

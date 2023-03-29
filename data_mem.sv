module data_mem (
    input clk,
    input rst,
    mem_wr,
    input logic [31:0] addr,
    data_wr,
    input logic [3:0] mask,
    input logic [2:0] load_ctrl,
    output logic [31:0] mem_data
);
  logic [31:0] mem_data_read, debug;
  logic [31:0] mem[0:31];
  assign mem_data_read = mem_wr ? '0 : mem[addr[6:2]];
  assign debug = mem[0];
  always_ff @(posedge clk) begin
    if (rst) mem <= '{default: '0};
    else if (mem_wr) begin
      $display("mask=%b datawr=%h", mask, data_wr);
      if (mask[0]) begin
        mem[addr[31:2]][7:0] = data_wr[7:0];
      end
      if (mask[1]) mem[addr[31:2]][15:8] = data_wr[15:8];
      if (mask[2]) begin
        $display("mask2=%b", mask[3]);
        mem[addr[31:2]][23:16] = data_wr[23:16];
      end
      if (mask[3]) mem[addr[31:2]][31:24] = data_wr[31:24];
    end
  end
  always_comb begin
    case (load_ctrl)
      3'b000: begin
        case (addr[1:0])
          2'b00:   mem_data = {{24{mem_data_read[7]}}, mem_data_read[7:0]};
          2'b01:   mem_data = {{24{mem_data_read[15]}}, mem_data_read[15:8]};
          2'b10:   mem_data = {{24{mem_data_read[23]}}, mem_data_read[23:16]};
          2'b11:   mem_data = {{24{mem_data_read[31]}}, mem_data_read[31:24]};
          default: mem_data = 'x;
        endcase
      end
      3'b001: begin
        case (addr[1])
          0: mem_data = {{16{mem_data_read[15]}}, mem_data_read[15:0]};
          1: mem_data = {{16{mem_data_read[31]}}, mem_data_read[31:16]};
          default: mem_data = 'x;
        endcase
      end
      3'b010: begin
        mem_data = mem_data_read;
      end
      3'b011: begin
        case (addr[1:0])
          2'b00:   mem_data = {{24{1'b0}}, mem_data_read[7:0]};
          2'b01:   mem_data = {{24{1'b0}}, mem_data_read[15:8]};
          2'b10:   mem_data = {{24{1'b0}}, mem_data_read[23:16]};
          2'b11:   mem_data = {{24{1'b0}}, mem_data_read[31:24]};
          default: mem_data = 'x;
        endcase
      end
      3'b100: begin
        case (addr[1])
          1'b0: mem_data = {{16{1'b0}}, mem_data_read[15:0]};
          1'b1: mem_data = {{16{1'b0}}, mem_data_read[31:16]};
          default: mem_data = 'x;
        endcase
      end
      default: mem_data = 'x;
    endcase
  end
endmodule

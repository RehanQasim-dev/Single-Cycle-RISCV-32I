module PC (input logic clk, input logic rst,output logic instr_address);
    always_ff @( posedge clk) begin
        if (rst) instr_address='0;
        else instr_address=instr_address+4;
    end
endmodule

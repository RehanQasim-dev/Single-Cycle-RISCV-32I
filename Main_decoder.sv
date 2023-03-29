module MAIN_decoder (
    input logic [6:0] opcode,
    input logic func3,
    zero,
    output logic RegWrite,
    PCsrc,
    ALUSrc,
    ImmSrc,
    ResultSrc,
    output logic [1:0] ALUOp
);
    logic Branch;

    always_comb begin
        case (opcode)
            7'b0000011:begin
                RegWrite=1;
                ImmSrc=0;
                ALUSrc=1;
                ResultSrc=1;
                Branch=0;
                ALUOp=00;
            end

            7'b0110011:begin
                RegWrite=1;
                ImmSrc='x;
                ALUSrc=0;
                ResultSrc=0;
                Branch=0;
                ALUOp=10;
            end
            7'b1100011:begin
                RegWrite=0;
                ImmSrc=1;
                ALUSrc=0;
                ResultSrc=1'bx;
                Branch=1;
                ALUOp=01;
            end
            7'b0010011:begin
                RegWrite=1;
                ImmSrc=0;
                ALUSrc=1;
                ResultSrc=0;
                Branch=0;
                ALUOp=10;
            end
            default:begin
                RegWrite='x;
                ImmSrc='x;
                ALUSrc='x;
                ResultSrc='x;
                Branch='x;
                ALUOp='x;
            end
        endcase
    end
    always_comb begin
        casex ({
        zero, Branch, func3
        })
            3'bX0X: PCsrc = 0;
            3'b010: PCsrc = 0;
            3'b011: PCsrc = 1;
            3'b110: PCsrc = 1;
            3'b111: PCsrc = 0;
            default:PCsrc='x;
        endcase
    end
endmodule

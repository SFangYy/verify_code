module ALU (
    input  [7:0] a,
    input  [7:0] b,              // ALU 数据输入
    input  [3:0] alu_sel,        // 功能选择
    output [7:0] alu_out         // 数据输出
);

    reg [7:0] result;            // 寄存运算结果
    assign alu_out = result;

    always @(*) begin
        case (alu_sel)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a * b;
            4'b0011: result = (b != 0) ? (a / b) : 8'b0; // 避免除零错误

            4'b0100: result = a << 1;
            4'b0101: result = a >> 1;
            4'b0110: result = {a[6:0], a[7]};
            4'b0111: result = {a[0], a[7:1]};

            4'b1000: result = a & b;
            4'b1001: result = a | b;
            4'b1010: result = a ^ b;
            4'b1011: result = ~(a | b);
            4'b1100: result = ~(a & b);
            4'b1101: result = ~(a ^ b);

            4'b1110: result = (a > b) ? 8'd1 : 8'd0;
            4'b1111: result = (a == b) ? 8'd1 : 8'd0;
            default: result = 8'b0;
        endcase
    end
endmodule


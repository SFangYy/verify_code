// ALU interface
interface alu_if;
    logic [7:0] a, b;
    logic [3:0] alu_sel;
    logic [7:0] alu_out;
endinterface

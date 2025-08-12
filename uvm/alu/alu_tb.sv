module alu_tb;
    import uvm_pkg::*;
    `include "alu_if.sv"
    `include "alu_env.sv"
    `include "alu_test.sv"

    // ALU instance
    alu_if alu_vif();
    ALU alu_inst (
        .a(alu_vif.a),
        .b(alu_vif.b),
        .alu_sel(alu_vif.alu_sel),
        .alu_out(alu_vif.alu_out)
    );

    initial begin
        run_test("alu_test");
    end
endmodule


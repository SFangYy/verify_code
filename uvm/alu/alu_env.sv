// ALU driver
`include "uvm_macros.svh"
import uvm_pkg::*;

// ALU transaction
class alu_transaction extends uvm_sequence_item;
    rand logic [7:0] a, b;
    rand logic [3:0] alu_sel;
    logic [7:0] expected_out;
    
    constraint c_alu_sel { alu_sel inside {[4'b0000:4'b1111]}; }

    `uvm_object_utils(alu_transaction)

    function new(string name = "alu_transaction");
        super.new(name);
    endfunction

    virtual function void do_copy(uvm_object rhs);
        alu_transaction rhs_; 
        if (!$cast(rhs_, rhs)) `uvm_fatal("COPY", "Type mismatch")
        this.a = rhs_.a;
        this.b = rhs_.b;
        this.alu_sel = rhs_.alu_sel;
        this.expected_out = rhs_.expected_out;
    endfunction
endclass

class alu_driver extends uvm_driver #(alu_transaction);
    virtual alu_if vif;

    `uvm_component_utils(alu_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            vif.a = req.a;
            vif.b = req.b;
            vif.alu_sel = req.alu_sel;
            @(posedge vif.alu_out);
            seq_item_port.item_done();
        end
    endtask
endclass

// ALU monitor
class alu_monitor extends uvm_monitor;
    virtual alu_if vif;
    uvm_analysis_port #(alu_transaction) ap;

    `uvm_component_utils(alu_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        alu_transaction trans;
        forever begin
            trans = alu_transaction::type_id::create("trans");
            trans.a = vif.a;
            trans.b = vif.b;
            trans.alu_sel = vif.alu_sel;
            trans.expected_out = vif.alu_out;
            ap.write(trans);
        end
    endtask
endclass

// ALU environment
class alu_env extends uvm_env;
    alu_driver driver;
    alu_monitor monitor;
    alu_scoreboard scoreboard;
    uvm_analysis_port #(alu_transaction) analysis_port;

    `uvm_component_utils(alu_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = alu_driver::type_id::create("driver", this);
        monitor = alu_monitor::type_id::create("monitor", this);
        scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
        monitor.ap.connect(scoreboard.exp);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(monitor.ap);
    endfunction
endclass

// ALU scoreboard
class alu_scoreboard extends uvm_scoreboard;
    uvm_analysis_export #(alu_transaction) exp;

    `uvm_component_utils(alu_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function logic [7:0] compute_result(input logic [7:0] a, b, input logic [3:0] alu_sel);
        case (alu_sel)
            4'b0000: compute_result = a + b;
            4'b0001: compute_result = a - b;
            4'b0010: compute_result = a * b;
            4'b0011: compute_result = a / b;
            4'b0100: compute_result = a << 1;
            4'b0101: compute_result = a >> 1;
            4'b0110: compute_result = {a[6:0], a[7]};
            4'b0111: compute_result = {a[0], a[7:1]};
            4'b1000: compute_result = a & b;
            4'b1001: compute_result = a | b;
            4'b1010: compute_result = a ^ b;
            4'b1011: compute_result = ~(a | b);
            4'b1100: compute_result = ~(a & b);
            4'b1101: compute_result = ~(a ^ b);
            4'b1110: compute_result = (a > b) ? 8'd1 : 8'd0;
            4'b1111: compute_result = (a == b) ? 8'd1 : 8'd0;
            default: compute_result = 8'd0;
        endcase
    endfunction

    task write(alu_transaction t);
        if (t.expected_out !== compute_result(t.a, t.b, t.alu_sel))
            `uvm_error("ALU_ERROR", $sformatf("Mismatch: a=%0d, b=%0d, sel=%0d, expected=%0d, actual=%0d", t.a, t.b, t.alu_sel, compute_result(t.a, t.b, t.alu_sel), t.expected_out))
    endtask
endclass

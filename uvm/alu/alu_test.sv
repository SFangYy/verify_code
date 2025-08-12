// ALU test
class alu_test extends uvm_test;
    alu_env env;

    `uvm_component_utils(alu_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alu_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        alu_transaction trans;
        alu_seq seq;
        phase.raise_objection(this);

        seq = alu_seq::type_id::create("seq");
        seq.start(null);

        phase.drop_objection(this);
    endtask
endclass

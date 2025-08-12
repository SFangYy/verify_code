class A extends uvm_component;
	`uvm_component_utils(A)

	uvm_blocking_put_port#(my_transaction) A_port;
endclass 

function void A::build_phase(uvm_phsae phase);
	super.build_phase(phase);
	A_port = new("A_port", this);
endfunction 

task A::main_phase(uvm_phase phase);
endtask 


class B extends uvm_component;
	`uvm_component_utils(B)

	uvm_blocking_put_export#(my_transaction) B_port;
endclass 

function void A::build_phase(uvm_phsae phase);
	super.build_phase(phase);
	B_port = new("B_port", this);
endfunction 

task B::main_phase(uvm_phase phase);
endtask 


class my_env extends uvm_env;
	A A_inst;
	B B_inst;

	virtual function void build_phase(uvm_phse phase);
		A_inst = A::type_id::create("A_inst", this);
		B_inst = B::type_id::create("B_inst", this);
	endfunction 

endclass 

function void my_env::connect_phase(uvm_phase phse);
	super.connect_phase(phase);
	A_inst.A_port.connect(B_inst.B_export);
endfunction 



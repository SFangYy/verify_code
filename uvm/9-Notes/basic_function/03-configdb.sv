class base_test extends uvm_test;
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(int)::set(this,"env.i_agt.drv", pre_num_max, 7);
	endfunction 
endclass 

class case1 extends base_test;
	function void build_phase(uvm_phase phse);
		super.build_phase(phase);
	endfunction 
endclass 

class case100 extends base_test;
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(int)::set(this, "env.i_agt.drv", pre_num_max, 100);
	endfunction 
endclass 

// in connect you can use check_config_usage() function to check which
// configdb is not used 

virtual function connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	check_config_usae();
endfunction 

// the result like this 


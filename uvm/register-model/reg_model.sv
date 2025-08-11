class reg_invert extends uvm_reg;
	rand uvm_reg_filed reg_data;

	virtual function void build();
		reg_data = uvm_reg_filed::type_id::create("reg_data");
		reg_data.configure(this,1, 0, "RW", 1, 0, 1, 1, 0);
	endfunction

	`uvm_objection_utils(reg_invert)

	function new(input string name="reg_invert");
		// name, register width, has coverage
		super.new(name, 16, UVM_NO_COVERAGE);
	endfunction 

endclass 

class reg_model extends uvm_reg_block;
	rand reg_invert invert;

	virtual function void build();
		default_map = create_map("default_map", 0, 2, UVM_BIG_ENDIAN, 0);

		invert = reg_invert::type_id::create("invert",,get_full_name);
		invert.configure(this, null, "");
		invert.build();
		default_map.add_reg(invert, 'h9, "RW");
	endfunction 

	`uvm_objection_utils(reg_model)

	function new(input string name = "reg_model");
		super.new(name,UVM_NO_COVERAGE);
	endfunction 

endclass


class base_test extends uvm_test;
	
	my_env env;
	my_vsqr v_sqr;
	reg_model rm;
	my_adapter reg_sqr_adapter;

endclass 

function void base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = my_env::type_id::create("env",this);
	v_sqr = my_vsqr::type_id::create("v_sqr", this);
	rm = reg_model::type_id::create("rm",this);
	rm.congigure(null, "");
	rm.build();
	rm.lock_model();
	rm.reset();
	reg_sqr_adapter = new("reg_sqr_adapter");
	env.p_rm = this.rm;
endfunction 

function void base_test::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	v_sqr.p_my_sqr = env.i_agt.sqr;
	v_sqr.p_bus_sqr = env.bus_agt.sqr;
	v_sqr.p_rm = this.rm;
	rm.default_map.set_sequenve(env.bus_agt.sqr, reg_sqr_adapter);
	rm.default_map.set_auto_predict(1);
endfunction 

endclass 

class my_model extends uvm_component;
	reg_model p_rm;

	task my_model::main_phase(uvm_phase phse);
		my_transaction tr;
		my_transaction new_tr;
		uvm_status_e status;
		uvm_reg_data_t value;

		super.main_phase(phase);
		p_rm.invert.read(status, value, UVM_FRONTDOOR);

		while(1) begin
			port.get(tr);
			new_tr = new("tr");
			new_tr.copy(tr);
			if(value)
				invert_tr(new_tr);
			ap.write(new_tr);
		end 
	endtask

endclass 
endclass 




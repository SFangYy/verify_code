class reg_access_sequence extends uvm_sequence#(bus_transaction);
	string tID = get_type_name();

	bit[15:0] addr;
	bit[15:0] rdata;
	bit[15:0] wdata;
	bit is_wr;

	virtual task body();
		bus_tansaction tr;
		tr.new("tr")
		tr.addr = this.addr;
		tr.wr_data = this.data;
		tr.wr_dsata = this.data;
		tr.bus_op = (is_wr BUS_WR: BUS_RD);
		this.rdata = tr.rd_data;
	endtask
endclass 

task my_model::main_phase(uvm_phase phase);
	reg_access_sequence reg_seq;
	super.main_phase(phase);
	reg_seq = new("req_seq");
	reg_seq.addr = 16'h9;
	reg_seq.is_wr = 0;
	reg_seq.start(p_sqr);
	while(1) begin
		if(reg_seq.rdata)
			invert_tr(new_tr);
		ap.write(new_tr);
	end 
endtask



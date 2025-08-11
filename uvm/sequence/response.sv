class case0_sequence extends uvm_sequence
    
    virtual task pre_body();
        use_response_handler(1);
    endtask 

    virtual function void response_handler(uvm_sequence_item response);
        if(!$cast(rsp, response))
            `uvm_error("seq","cant cast")
        else begin 
            `uvm_info("seq", "get one response"，UVM_MEDIUM)
            rsp.print();
        end 
    endfunction 

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);
        repeat (10) begin 
            `uvm_do(m_trans)
        end 
        #100; 
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask 

    `uvm_objection_utils(case0_sequence)
endclass 

task my_driver::main_phase(uvm_phase phase);
    while(1) begin 
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);
        req.frm_drv = "this is information from driver";
        seq_item_port.item_done();
    end 
endtask 

// difference of req and resp 

task my_driver::main_phase(uvm_phase phase);

    while(1) begin 
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);
        rsp = new("rsp")
        rsp.set_id_info(req);
        rsp.information = "driver information";
        seq_item_port.put_response(rsp);
        seq_item_port.item_done();
    end 
endtask 

class case1_sequence extends uvm_sequence #(my_transaction, your_transaction);
    virtual task body();
        repeat (10) begin 
            `uvm_do(m_trans)
            get_response(rsp);
            `uvm_info("seq","this is response", UVM_MEDIUM)
        end 
    endtask 
endclass

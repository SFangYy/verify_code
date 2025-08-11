class case0_sequence extends uvm_sequence #(my_transactioin);
    virtual task pre_body();
        `uvm_info("sequence0", "pre_body is called", UVM_LOW)
    endtask 

    virtual task psot_body();
        `uvm_info("sequence0", "psot_body is called", UVM_LOW)
    endtask 

    virtual task body();

        repeat (5) begin 
            `uvm_do(m_trans)
            `uvm_info("sequence0", "body is called", UVM_LOW)
        end 
        #100;

        lock();
        `uvm_info("sequence0", "locked the sequencer", UVM_MEDIUM)

        repeat (4) begin 
            `uvm_do(m_trans)
            `uvm_info("sequence0", "body is called", UVM_LOW)
        end 
        unlock();

        // another send functon 
        int num = 0;
        int p_sz;

        repeat (10) begin 
            num++;
            `uvm_create(m_trans) 
            p_sz = m_trans.pload.size();
            {m_trans.pload[p_sz - 4],
             m_trans.pload[p_sz - 3],
             m_trans.pload[p_sz - 2],
             m_trans.pload[p_sz - 1]}
            = num; 
            `uvm_send(m_trans)
        end 

        // if not use marco 
        // tr = new("tr");
        // start_item(tr)
        // finish_item(tr);
        //
        // use parameter to pri 
        // start_item(tr,100);
        //


    endtask 

    virtual task pre_do(bit is_item);
        #100 
        `uvm_info("sequence0", "this is pre_do", UVM_MEDIUM)
    endtask 

    virtual task void post_do(uvm_sequence_item this_item);
        `uvm_info("sequence0", "this is post_do", UVM_MEDIUM)
    endtask

    `uvm_object_utils(case0_sequence)
endclass



// two ways to start a seq 

my_sequence my_seq;
my_seq = my_sequence::type_id::create("my_seq");
my_seq.start(sequencer);

uvm_config_db#(uvm_object_wrapper):;set(this, "env.i_agt.sqr.main_phase", "default_sequence", case0_sequence::type_id::get());

// arbiter 

class case1_sequence extends uvm_sequence #(my_transactioin);
    virtual task pre_body();
        `uvm_info("sequence1", "pre_body is called", UVM_LOW)
    endtask 

    virtual task psot_body();
        `uvm_info("sequence1", "psot_body is called", UVM_LOW)
    endtask 

    virtual task body();
        
        repeat (5) begin 
            `uvm_do(m_trans)
            `uvm_info("sequence1", "body is called", UVM_LOW)
        end 
        #100;
    endtask 

    `uvm_object_utils(case1_sequence)
endclass


//sequencer start two seq 

task my_case0::main_phase(uvm_phase phase);
    sequence0 seq0;
    sequence1 seq1;

    seq0 = new("seq0");
    seq0.starting_phase = phase;
    seq1 = new("seq1");
    seq1.starting_phase = phase;

    fork 
        seq0.start(env.i_agt.sqr);
        seq1.start(env.i_agt.sqr);
    join 

endtask 

// `uvm_do_pri_with(m_trans, 200, {m_trans.pload.size < 500})
// env.i__agt.sqr.set_arbitration(SEQ_ARN_STRICT_FIFO);



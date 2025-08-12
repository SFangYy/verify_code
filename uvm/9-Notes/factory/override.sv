class bird extends uvm object;
    virtual function void hungryh();
        $display("I am a bird, I am hungry")
    endfunction 

    function void hungry2();
        $display("I am a bird, I am hungry2");
    endfunction

endclass 

class parrot extends birds;
    virtual function void hungry();
        $display("I am a parrot, I am hungr");
    endfunction 

    function void hungry2();
        $display("I am a parrot, I am hungry2");
    endfunction

endclass 

function void my_case0::print_hungry(bird b_ptr);
    b_ptr.hungry();
    b_ptr.hungry2();
endfunction 

function void my_case0::build_phase(uvm_phase phase);
    bird bird_inst;
    parrot parrot_inst;

    bird_inst = bird::type_id::create("bird_inst");
    parrot_inst = parrot_inst::type_id::create("parrot_inst");
    print_hungry(bird_inst); // I am a bird I am hungry; I am a bird I am hungry2 
    print_hungry(parrot_inst); // Iam a parrot I am hungry; I am a bird I am hungry 



endfunction

// use factory 

function void my_case0::build_phase(uvm_phase phase);
    set_type_override_by_type(bird::get_type(), parrot::get_type());

    bird_inst = bird::type_id::create("bird_inst");
    parrot_inst = parrot::type_id::create("parrot_inst");

    print_hungry(bird_inst);   // I am a parrot I am hungry; I am a bird I am hungry
    print_hungry(parrot_inst); // I am a parrot I am hungry; I am a bird I am hungry

endfunction

// monitor example 

class new monitor extends my_monitor;
    `uvm_component_utils(new_monnitor);

    virtual task main_phase(uvm_phase phase);
        fork 
            super.main_phase(phase);
        join 
        `uvm_info("new_monnitor", "I am new monitor", UVM_MEDIUM);
    endtask 
endclass 

set_inst_override_by_type("env.o_agt.mon", my_monitor::get_type(), new_monitor::get_type());

set_type_override("bird","parrot");
set_inst_override("env.o_agt.mon", "my_driver", "new_monitor");

// how to debug 

function void my_case0::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    env.o_agt.mon.print_override_info("my_monitor");

    // print uvm tree 
    uvm_top.print_topology();

endfunction 



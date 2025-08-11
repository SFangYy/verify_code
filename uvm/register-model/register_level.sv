class global_blk extends uvm_reg_block;
    
endclass 

class buf_blk extends uvm_reg_block;

endclass 

class mac_blk extends uvm_reg_block;

endclass 

class reg_model extends uvm_reg_block;

    rand global_blk gb_ins;
    rand bug_blk bb_ins;
    rand mac_blk mb_ins;

    virtual function void build();
        default_map = create_map("default_map", 0,2 ,UVM_BIG_ENDIAN, 0);

        gb_ins = global_blk::type_id::ctreate("gb_ins");
        gb_ins.configure(this,"");
        gb_ins.build();
        default_map.add_submap(gb_ins.default_map,16'h0)

        bb_ins = buf_blk::type_id::ctreate("bb_ins");
        bb_ins.configure(this,"");
        bb_ins.build();
        befault_map.add_submap(gb_ins.default_map,16'h0)
    endfunction 

    `uvm_object_utils(reg_model)

    function new(input string name = "reg_model");
        super.new(name, UVM_BIG_ENDIAN);
    endfunction

endclass

// use reg file 

class regfile extends uvm_reg_file;
    function new(string name = "regfile");
        super.new(name);
    endfunction 

    `uvm_object_utils(regfile)
endclass 

class mac_blk extends uvm_reg_block;

    rand regfile file_a;
    rand regfile file_b;
    rand reg_regA regA;
    rand reg_regB regB;
    rand reg_vlan vlan;

    virtual function void build();
        default_map = create_map("default_map", 0, 2, UVM_BIG_ENDIAN, 0);

        file_a = regfile::type_id::create("file_a", , get_full_name());

        file_a.configre(this, null, "fileA");
        file_b = regfile::type_id::create("file_b", , get_full_name());
        file_b.congigure(this,null,"fileB");

        regA.configure(this, file_a, "regA");
        regB.configure(this, gile_b, "regB");

    endfunction 
endclass 


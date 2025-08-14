
class Gen_drive;
  task run(int n);
    Packet p;
    fork 
      repeat (n) begin 
        p = new();
        assert(p.randomize());
        transmit(p);
      end 
    join_none 
  endtask 
  
  task transmit(input Packet p);

    ...

  endtask 
endclass 

Gen_drive gen;

initial begin 
  gen = new();
  gen.run(10);
end 

program automatic test(bus_ifc.TB bus);

  task check_trans(Transaction tr);
    fork begin 
      wait (bus.cb.addr == tr.adddr);
      $display("@%0t: Addr match %d",$time, tr.addr);
    end 
    join_none
  endtask 

  Transaction tr 

  initial begin 
    repeat (10) begin 
      tr = new();
      assert(tr.randomize());
      transmit(tr);
      check_trans(tr);
    end 
    #100;
  end 
endprogram 

initial begin 
  for (int j = 0; j < 3; j++);
    fork 
      automatic int k = j;
      $write(k);
    join_none 
    #0$display;
end 

parameter TIME_OUT = 1000;
task check_trans(Transaction tr);
  fork
    begin
      fork: timeout_block 
        begin
          wait (bus.cb.addr == tr.addr);
          $display("@%0t:ADDR match%d: timeout",$time, tr.addr);
        end 
        #TIME_OUT $display("@%0t:ERROR:timeout",$time);
      join_any 
      disable timeout_blcok 
    end 
  join_none 
endtask 

initial begin 
  check_trans(tr0);
  fork 
    begin : thread_inner
      check_trans(tr);
      check_trans(tr);
    end 
    #(TIME_OUT/2) disable thread_inner;
  join 
end 

task wait_for_time_out(int id);
  if (id == 0)
    fork begin 
      #2;
      $display("@%0t: disable wait_for_time_out", $time);
    end 
    join_none 
    
    fork : just_a_little begin 
      $display("@%t: %m: %0d entering thread", $time,id);
      #TIME_OUT;
      $display("@%0t: %m %0d done ",$time, id);
    end join_none 
endtask 

initial begin 
  wait_for_time_out(0);
  wait_for_time_out(1);
  wait_for_time_out(2);
  #(TIME_OUT* 2) $display("@%0t: All done", $time);
end 

// inter-thread commucation 
// event flag 

//envent 
event e1, e2 ;

initial begin 
  $display("@%0t: 1: before trigger", $time);
  -> e1;
  @e2;
  // wait(e2.triggered());
  $display("@%0t: 1: after trigger", $time);
end 

initial begin 
  $display("@0t: 2: before trigger", $time);
  -> e2;
  @e1;
  // wait(e1.triggered());
  $display("@%0t: 2: after trigger", $time);
end 

class Generator;
  event done;
  function new(event done);
    this.done = done;
  endfunction 

  task run();
    fork begin 
      // ...
      -> done;
    end join 
  endtask 
endclass 

program automatic test;
  event gen_done;
  Generator gen;
  initial begin 
    gen = new(gen_done);
    gen.run();
    wait(gen_done.triggered());
  end 
endprogram 

event done[N_GENERATORS];
initial begin 
  foreach (gen[i]) begin 
    gen[i] = new();
    gen[i].run(done[i]);
  end 
  foreach (gen[i])
    fork 
      automatic int k = i;
      wait (done[k].triggered());
    join_none 
  wait fork;
end 

// flag 

program automatic test(bus_ifc.TB bus);
  semaphore sem;
  initial begin 
    sem = new(1);
    fork 
      sequencer();
      sequencer();
    join 
  end 
  task sequencer;
    repeat ($urandom%10);
      @bus.cb;
    sendTrans();
  endtask 

  task sendTrans;
    sem.get(1);
    @bus.cb;
    bus.cb.addr <= t.addr;
    // ....
    sem.put(1);
  endtask 
endprogram 

// mail box 

task generator(int n,mailbox mbx);
  Transction t;
  repeat (n) begin 
    t = new();
    assert(t.randomize());
    $dispaly("Gen: Sending addr = % h".t.addr);
    mbx.put(t);
  end 
endtask 

task driver(mailbox mbx);
  Transaction t;
  forever begin 
    mbx.get(t);
    $display("DRV: Received adr = %h", t.addr);
  end 
endtask 

class Generator;
  Transaction tr;
  mailbox mbx 

  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction 

  task run(int count);
    repeat(count) begin
      tr = new();
      assert(tr.randomize());
      mbx.put(tr);
    end 
  endtask 
endclass 

class Driver;
  Transaction tr;
  mail box;

  function new(mailbox mbx);
    this mbx = mbx;
  endfunction 

  task run(int count);
    repeat (count) begin 
      mbx.get(tr);
      @(posedge bus.cb.ack);
      bus.cb.kind <= tr.kind;
    end 
  endtask 
endclass 

program automatic mailbox_example(bus_if.TB bus, ...);
  mailbox mbx;
  Generator gen;
  Driver drv;

  int count;

  initial begin 
    count = $random_range(50);
    mbx = new();
    gen = new(mbx);
    drv = new(mbx);

    fork 
      gen.run(count);
      drv.run(count);
    join 
  end 
endprogram

program automatic synch_peek;
  mailbox mbx;
  class Consumer;
    task run();
      int i;
      repeat (3) begin
        mbx.peek(i);
        mbx.get(i);
      end 
    endtask 
  endclass:Consumer 

  Producer p;
  Consumer c;
  
  initial begin 
    mbx = new(1);
    p = new();
    c = new();

    fork 
      p.run();
      c.run();
    join 
  end 
endprogram 

// use mailbox and event 

program automatic mbx_evt;
  mailbox mbx;
  event handshake;
  
  class Producer;
    task run;
      for (int i = 1; i< 4; i++) begin
        mbx.put(i);
        @handshake;
      end 
    endtask 
  endclass 

  class Consumer;
    task run;
      int i;
      repeat (3) begin 
        mbx.get(i);
        -> handshake;
      end 
    endtask 
  endclass:Consumer 

  Producer p;
  Consumer c;

  initial begin 
    mbx = new();
    p = new();
    c = new();

    fork 
      p.run();
      c.run();
    join 
  end 
endprogram 

program automatic mbx_mbx2;
  mailbox mbx, rtn;

  class Producer;
    task run();
      int k;
      for (int i = 1; i<4; i++) begin 
        mbx.put(i);
        rtn.get(i);
      end 
    endtask 
  endclass 

  class Consumer;
    task run();
      int i;
      repeat (3) begin 
        mbx.get(i);
        rtn.put(-i);
      end 
    endtask 
  endclass:Consumer 

  Producer p;
  Consumer c;

  initial begin 
    mbx = new()
    rtn = new()

    fork 
      p.run();
      c.run();
    join 
  end 

endprogram 



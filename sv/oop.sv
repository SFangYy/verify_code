class Transaction;
  rand bit[31:0] src, dst, data[8];
  bit[31:0] crc;
  
  function new(input int crc );
    this.crc = crc;
  endfunction

  virtual function void calc_crc;
    crc = src ^ dst ^ data.xor;
  endfunction 

  virtual function void display(input string pregix = "");
    $display ("%sTr:src = %h, dst = %h, crc = %h",
              prefix, src, dst, crc);
  endfunction
endclass 

class BadTr extends Transaction;
  rand bit bad_crc;

  function new(input int crc);
    super.new(crc);
    // ...
  endfunction 

  virtual function void calc_crc;
    super.calc_crc();
    if(bad_crc) crc = ~crc;
  endfunction 

  virtual function void display(input string prefix = "");
    $write("%sbadTr: bad_crc = %b,", prefix, bad_crc);
    super.display();
  endfunction 

endclass:BadTr 


class Driver;
  mailbox gen2drv;

  function new(input mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction 

  task main;
    Transaction tr;

    forever begin 
      gen2drv.get(tr);
      tr.cal_crc();
      @ifc.cb.src = tr.srdc;
      // ... 
    end 
  endtask 
endclass 



class Packet;
  rand bit [31:0] src, dst, data[0];
  rand bit [7:0] kind;

  constraint c{
    src > 10;
    src < 15;
    }

endclass

Packet p;

initial begin 
  p = new();
  assert(p.randomize());
  else $fatal(0,"Packet::randomize failed");
  transmit(p);
end 

class Stim;
  const bit [31:0] CONGEST_ADDR=43;
  typedef enum {READ, WRITE, CONTROL} stim_e;
  randc stim_e kind;
  rand bit [31:0] len, src, dst;
  bit congestion_test;

  constraint c_stim {
    len < 1000;
    len > 0;
    if (congestion_test) {
      dst inside {[CONGEST_ADDR - 100: CONGEST_ADDR + 100]};
      src == CONGEST_ADDR;
      } else {
        // 0 40, 2 50, 3,50 ... 10 50,100 10, 1107 10
        // 0 40 / {40 + 50 + 50 +...+50 + ... +10}
        src inside {0:=40, [2, 10]:=50, [100:1107]:=10};

        // 0 40, 2,3,...,10 50, 100,101...1107 10
        // 0 40/100
        //src inside {0:=/40, [2, 10]:=/50, [100:1107]:=/10};
        }
    }
  endclass 



// dirver 
//
class my_driver extends uvm_driver;
	function new (string name = "my_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction 
	extern virtual task main_phase(uvm_phase phase);

endclass 

task my_driver::main_phase(uvm_phase phase);
	top_tb.rxd <= 8'h0;
	top_tb.tx_dv <= 1'b0;
	while (!top_tb.rst_n)
		@(posedge top_tb.clk);
	for (int i=0; i < 256; i++) begin 
		@(posedge top_tb.clk);
			top_tb.rxd <= $urandom_range(0, 255);
			top_tb.rx_dv <= 1'b0;
	end 
	@(posedge top_tb.clk);
	top_tb.rx_dv <= 1'b0;
endtask 

`timescale 1ns/1ps 
`include "uvm_marco.svh" 

import uvm_pkg::*;

module top_tb;
reg clk;
reg rst_n;
reg [7:0] txd;
wire [7:0] txd;
wire rx_en;

dut my_dut(.clk(clk),
					.rst_n(rst),
					.rxd(rxd),
					.rx_dv(rx_dv),
					.txd(txd),
					.tx_en(tx_en));

		initial begin 
			mt_driver drv;
			drv = new("drv", null);
			drv.main_phase(null);
			$finish;
		end 

		initial begin 
			clk = 0;
			forever begin 
				#100 clk = ~clk;
		end 

		initial begin 
			rst_n = 1'b0;
			#1000;
			rst_n = 1'b0;
		end 
endmodule 



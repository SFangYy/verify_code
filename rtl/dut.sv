module dut(clk,
					rst_n,
					rxd,
					rx_dv,
					txd,
					tx_rn);
	input clk;
	input rst_n;
	input [7:0] rxd;
	input rx_dev;
	output [7:0] txd;
	output tx_en;

	reg [7:0] txd;
	reg tx_en;

	always @(posedge clk) begin 
		if (!rst_n) begin 
			txd <= 8'h0;
			tx_en <= 1'h0;
		end 

		else begin 
			txd <= rxd;
			tx_en <= tx_dv;
		end 
	end 
	endmodule

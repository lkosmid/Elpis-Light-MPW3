/*
*
* This file is part of the Elpis processor project.
*
* Copyright © 2020-present. All rights reserved.
* Authors: Aurora Tomas and Rodrigo Huerta.
* Leonidas Kosmidis adapted it from the original ibex register_file_ff which is
* licensed under Apache-2.0
*
* This file is licensed under both the BSD-3 license for individual/non-commercial
* use. Full text of both licenses can be found in LICENSE file.
*/

`default_nettype none

`ifdef TESTS
	`include "elpis/definitions.v"
`else
    `include "/project/openlane/user_proj_example/../../verilog/rtl/elpis/definitions.v"
`endif

module regfile(
	input clk,
	input reset,
	input wrd,				// write permission
	input[31:0] d,			// data
	input[4:0] addr_a,		// source register A
	input[4:0] addr_b,		// source register B
	input[4:0] addr_d,		// destination register
	output[31:0] a,		// read port A
	output[31:0] b,		// read port B	
	input[4:0] dest_read,
	output[31:0] dest_value
);

	parameter int unsigned DataWidth = 32;
	localparam int unsigned ADDR_WIDTH = 5;
	localparam int unsigned NUM_WORDS = 2 ** ADDR_WIDTH;
	wire [DataWidth-1:0] rf_reg [NUM_WORDS-1:0];
	reg [DataWidth-1:0] registers [NUM_WORDS-1:1];
	reg [NUM_WORDS-1:1] we_a_dec;

	always_comb begin : we_a_decoder
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 1; i < NUM_WORDS; i = i + 1)
				we_a_dec[i] = ((addr_d == 5'(i)) ? wrd : 1'b0);
		end
	end
	generate
		genvar i;
		for (i = 1; i < NUM_WORDS; i = i + 1) begin : g_rf_flops
			always_ff @(posedge clk or posedge reset)
				if (reset)
					registers[i] <= {DataWidth {1'sb0}};
				else if (we_a_dec[i])
					registers[i] <= d;
		end
	endgenerate
	generate
			assign rf_reg[0] = {DataWidth {1'sb0}};
	endgenerate

	generate
		genvar i;
		for (i = 1; i < NUM_WORDS; i = i + 1) begin : wire_assignments
			assign rf_reg[i] = registers[i];
		end
	endgenerate

	assign a = rf_reg[addr_a];
	assign b = rf_reg[addr_b];
	assign dest_value = rf_reg[dest_read];
endmodule

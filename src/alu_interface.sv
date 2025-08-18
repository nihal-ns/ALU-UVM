`include "defines.sv"

interface alu_intf(input bit clk, rst);
	// DUT signals
	logic [`WIDTH-1:0] OPA, OPB;
	logic [`CMD_WIDTH:0] CMD;
	logic CIN, CE, MODE;
	logic [1:0] INP_VALID;
	logic [`WIDTH:0] RES;
	logic OFLOW, COUT, E, G, L, ERR;

	clocking mon_cb@(posedge clk);
		default input #1 output #1;
		input INP_VALID,MODE,CMD,CIN,OPA,OPB;
		input RES, OFLOW, COUT, E, G, L, ERR;
	endclocking

	clocking drv_cb@(posedge clk);
		default input #1 output #1;
		input rst;
		output OPA, OPB, CMD, CIN, CE, MODE, INP_VALID;
	endclocking

	/* clocking ref_cb@(posedge clk); */
	/* 	default input #0 output #0; */
	/* 	input rst, CE, CIN, MODE, INP_VALID, OPA, OPB; */
	/* endclocking */

	modport DRIVER(clocking drv_cb);
	modport MONITOR(clocking mon_cb);
	/* modport REF(clocking ref_cb); */
endinterface

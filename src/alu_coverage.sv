`uvm_analysis_imp_decl(_mon_act_cg)

class alu_coverage extends uvm_subscriber#(alu_seq_item);
	`uvm_component_utils(alu_coverage)
  
	uvm_analysis_imp_mon_act_cg#(alu_seq_item, alu_coverage) mon_act_cg_port;
  /* uvm_analysis_imp_drv_cg #(alu_seq_item, alu_coverage) drv_cg_port; */

	alu_seq_item mon_pass_seq, mon_act_seq;
	real mon_act_cov, mon_pass_cov;

//===================//
//// using scr_rst //
//===================//

// Input coverage (directly from driver)
	covergroup alu_in_cvg ;
		RstBit: coverpoint mon_act_seq.SCB_RST {
			bins rst_high = {1};
			bins rst_low = {0};
			}
		ClkEnBit: coverpoint mon_act_seq.CE {
			bins clock_en_high = {1};
			bins clock_en_low = {0};
			}			
		MBit: coverpoint mon_act_seq.MODE iff(!mon_act_seq.SCB_RST && mon_act_seq.CE) {
			bins arithmetic_mode = {1};
			bins logical_mode = {0};
			}
		CinBit: coverpoint mon_act_seq.CIN iff(!mon_act_seq.SCB_RST && mon_act_seq.CE && mon_act_seq.MODE && (mon_act_seq.CMD == 2 || mon_act_seq.CMD == 3)) {
			bins carry_in = {1};
			bins no_carry_in = {0};
			}
		InValVector: coverpoint mon_act_seq.INP_VALID iff(!mon_act_seq.SCB_RST && mon_act_seq.CE) {
			bins invalid = {0};
			bins input_valid_1 = {1};
			bins input_valid_2 = {2};
			bins input_valid_3 = {3};
			}
		CMDVector_Arith: coverpoint mon_act_seq.CMD iff(!mon_act_seq.SCB_RST && mon_act_seq.CE && mon_act_seq.MODE) {
			bins add = {`ADD};
      bins sub = {`SUB};
      bins add_cin = {`ADD_CIN};
      bins sub_cin = {`SUB_CIN};
      bins inc_a = {`INC_A};
      bins dec_a = {`DEC_A};
      bins inc_b = {`INC_B};
      bins dec_b = {`DEC_B};
      bins cmp = {`CMP};
      bins inc_mult = {`INC_MULT};
      bins sh_mult = {`SH_MULT};
			}
		CMDVector_Logic: coverpoint mon_act_seq.CMD iff(!mon_act_seq.SCB_RST && mon_act_seq.CE && (mon_act_seq.MODE == 0)) {
			bins and_op = {`AND};
      bins nand_op = {`NAND};
      bins or_op = {`OR};
      bins nor_op = {`NOR};
      bins xor_op = {`XOR};
      bins xnor_op = {`XNOR};
      bins not_a = {`NOT_A};
      bins not_b = {`NOT_B};
      bins shr1_a = {`SHR1_A};
      bins shl1_a = {`SHL1_A};
      bins shr1_b = {`SHR1_B};
      bins shl1_b = {`SHL1_B};
      bins rol = {`ROL_A_B};
      bins ror = {`ROR_A_B};
			}
		/* CMDVector: coverpoint mon_act_seq.CMD iff(!rst && mon_act_seq.CE) */
		/* 	{ */
		/* 		bins arithmetic_bin[] = {[0:10]} iff (mon_act_seq.MODE == 1);      // using "with" instead of "iff" gives some error/warning */
		/* 		bins logical[] = {[0:13]} iff (mon_act_seq.MODE == 0); */
        /* bins out_of_range_arithetic = {[11:15]} iff (mon_act_seq.MODE == 1'b1); */
        /* bins out_of_range_logical = {14,15} iff (mon_act_seq.MODE == 1'b0); */
		/* 	} */
		Cross_ModexCmdxarith: cross MBit, CMDVector_Arith;
		Cross_ModexCmdxlogic: cross MBit, CMDVector_Logic;
	/* CrossCMDxInValid: cross CMDVector, InValVector; */
	endgroup

// Output coverage from monitor
	covergroup alu_out_cvg ;
		CoutBit: coverpoint mon_pass_seq.COUT iff((mon_act_seq.MODE == 1) && (mon_act_seq.CMD == 0 || mon_act_seq.CMD == 2)) {
			bins carry_out = {1};
			bins no_carry = {0};
			}
		OflowBit: coverpoint mon_pass_seq.OFLOW iff((mon_act_seq.MODE == 1) && (mon_act_seq.CMD == 1 || mon_act_seq.CMD == 2)) {
			bins overflow = {1};
			bins no_overflow = {0};
			}
		ErrBit: coverpoint mon_pass_seq.ERR {
			bins error = {1};
			bins no_error = {0};
			}
		Cmp_E: coverpoint mon_pass_seq.E iff(mon_act_seq.MODE == 1 && mon_act_seq.CMD == 8) {
			bins equal_to = {1};
			/* bins not_equal = {0}; */
			}
		Cmp_G: coverpoint mon_pass_seq.G iff(mon_act_seq.MODE == 1 && mon_act_seq.CMD == 8) {
			bins greater = {1};
			/* bins not_greater = {0}; */
			}
		Cmp_L: coverpoint mon_pass_seq.L iff(mon_act_seq.MODE == 1 && mon_act_seq.CMD == 8) {
			bins less = {1};
			/* bins not_less = {0}; */
			}
	endgroup

	function new(string name = "alu_coverage", uvm_component parent);
		super.new(name, parent);
		alu_in_cvg = new;
		alu_out_cvg = new;
	endfunction
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		/* drv_cg_port = new("drv_cg_port", this); */
		mon_act_cg_port = new("mon_act_cg_port", this);
	endfunction	

	function void write(alu_seq_item t);
		mon_pass_seq = t;
		alu_out_cvg.sample();
		/* `uvm_info(get_type_name, $sformatf("[DRIVER]  ", txn_drv1.), UVM_MEDIUM); */
	endfunction

	function void write_mon_act_cg(alu_seq_item t);
		mon_act_seq = t;
		alu_in_cvg.sample();
		/* `uvm_info(get_type_name, $sformatf("[MONITOR]  ", txn_mon1.), UVM_MEDIUM); */
	endfunction

	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		mon_act_cov = alu_in_cvg.get_coverage();
		mon_pass_cov = alu_out_cvg.get_coverage();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name, $sformatf("Input Coverage ------> %0.2f%%,", mon_act_cov), UVM_MEDIUM);
		`uvm_info(get_type_name, $sformatf("Output Coverage ------> %0.2f%%", mon_pass_cov), UVM_MEDIUM);
	endfunction

endclass


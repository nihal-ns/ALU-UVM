`uvm_analysis_imp_decl(_mon_cg)
/* `uvm_analysis_imp_decl(_drv_cg) */

class alu_coverage extends uvm_subscriber#(alu_seq_item);
	`uvm_component_utils(alu_coverage)
  
	uvm_analysis_imp_mon_cg #(alu_seq_item, alu_coverage) mon_cg_port;
  /* uvm_analysis_imp_drv_cg #(alu_seq_item, alu_coverage) drv_cg_port; */

	alu_seq_item mon_seq, drv_seq;
	real mon1_cov,drv1_cov;
	int rst =1;

// Input coverage (directly from driver)
	covergroup alu_in_cvg ;
		RstBit: coverpoint rst;
		ClkEnBit: coverpoint drv_seq.CE;
		MBit: coverpoint drv_seq.MODE iff(!rst && drv_seq.CE);
		CinBit: coverpoint drv_seq.CIN iff(!rst && drv_seq.CE && drv_seq.MODE && (drv_seq.CMD == 2 || drv_seq.CMD == 3));
		InValVector: coverpoint drv_seq.INP_VALID iff(!rst && drv_seq.CE)
			{
				bins invalid = {0};
				bins input_valid_1 = {1};
				bins input_valid_2 = {2};
				bins input_valid_3 = {3};
			}
		CMDVector: coverpoint drv_seq.CMD iff(!rst && drv_seq.CE)
			{
				bins arithmetic_bin[] = {[0:10]} iff (drv_seq.MODE == 1);      // using "with" instead of "iff" gives some error/warning
				bins logical[] = {[0:13]} iff (drv_seq.MODE == 0);
        bins out_of_range_arithetic = {[11:15]} iff (drv_seq.MODE == 1'b1);
        bins out_of_range_logical = {14,15} iff (drv_seq.MODE == 1'b0);
			}
	Cross_ModexCmd: cross MBit, CMDVector;
	CrossCMDxInValid: cross CMDVector, InValVector;
	endgroup

// Output coverage from monitor
	covergroup alu_out_cvg ;
		CoutBit: coverpoint mon_seq.COUT iff((mon_seq.MODE == 1) && (mon_seq.CMD == 0 || mon_seq.CMD == 2));
		OflowBit: coverpoint mon_seq.OFLOW iff((mon_seq.MODE == 1) && (mon_seq.CMD == 1 || mon_seq.CMD == 2));
		ErrBit: coverpoint mon_seq.ERR;
		Cmp_E: coverpoint mon_seq.E iff(mon_seq.MODE == 1 && mon_seq.CMD == 10);
		Cmp_G: coverpoint mon_seq.G iff(mon_seq.MODE == 1 && mon_seq.CMD == 10);
		Cmp_L: coverpoint mon_seq.L iff(mon_seq.MODE == 1 && mon_seq.CMD == 10);
	endgroup

	function new(string name = "alu_coverage", uvm_component parent);
		super.new(name, parent);
		alu_in_cvg = new;
		alu_out_cvg = new;
	endfunction
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		/* drv_cg_port = new("drv_cg_port", this); */
		mon_cg_port = new("mon_cg_port", this);
	endfunction	

	function void write(alu_seq_item t);
		drv_seq = t;
		alu_in_cvg.sample();
		/* `uvm_info(get_type_name, $sformatf("[DRIVER]  ", txn_drv1.), UVM_MEDIUM); */
	endfunction

	function void write_mon_cg(alu_seq_item t);
		mon_seq = t;
		alu_out_cvg.sample();
		/* `uvm_info(get_type_name, $sformatf("[MONITOR]  ", txn_mon1.), UVM_MEDIUM); */
	endfunction

	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		drv1_cov = alu_in_cvg.get_coverage();
		mon1_cov = alu_out_cvg.get_coverage();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name, $sformatf("[DRIVER] Coverage ------> %0.2f%%,", drv1_cov), UVM_MEDIUM);
		`uvm_info(get_type_name, $sformatf("[MONITOR] Coverage ------> %0.2f%%", mon1_cov), UVM_MEDIUM);
	endfunction

endclass


/* `uvm_analysis_imp_decl(_scb) */
/* `uvm_analysis_imp_decl(_drv) */

/* class alu_scoreboard extends uvm_scoreboard; */
/* 	`uvm_component_utils(alu_scoreboard) */

/* 	alu_seq_item packet_queue[$]; */
/* 	alu_seq_item packet_drv[$]; */
/* 	/1* bit [7:0]smem[4]; *1/ */

/* 	uvm_analysis_imp_scb #(alu_seq_item, alu_scoreboard) item_collected_port; */
/* 	uvm_analysis_imp_drv #(alu_seq_item, alu_scoreboard) item_drv; */

/* 	function new (string name = "alu_scoreboard", uvm_component parent); */
/* 		super.new(name,parent); */	
/* 	endfunction */	

/* 	function void build_phase(uvm_phase phase); */
/* 		super.build_phase(phase); */
/* 		item_collected_port = new("item_collected_port",this); */
/* 		item_drv = new("item_drv",this); */
/* 	endfunction */	

/* 	virtual function void write_scb(alu_seq_item pkt); */
/* 		$display("Scoreboard is recieved:: packet"); */
/* 		packet_queue.push_back(pkt); */
/* 	endfunction */	

/* 	///// trial */ 
/* 	virtual function void write_drv(alu_seq_item pac); */
/* 		$display("Scoreboard is recieved:: packet"); */
/* 		packet_drv.push_back(pac); */
/* 	endfunction */	


/* 	virtual task run_phase(uvm_phase phase); */
/* 	alu_seq_item packet_2; */
/* 	packet_2 = alu_seq_item::type_id::create("packet_2"); */
/* 		forever begin */
				
/* 			wait(packet_queue.size() > 0); */
/*       $display("!!! entered inside"); */
/*        /1* packet_2 = packet_queue.pop_front(); *1/ */
/*        packet_2.copy( packet_queue.pop_front()); */
/* 			`uvm_info(get_type_name(),$sformatf("OPA: %0d",packet_2.OPA),UVM_LOW) */    
/* 			`uvm_info(get_type_name(),$sformatf("OPB: %0d",packet_2.OPB),UVM_LOW) */ 
			
/* 			`uvm_info(get_type_name(),$sformatf("M: %0b",packet_2.MODE),UVM_LOW) */ 
/* 			`uvm_info(get_type_name(),$sformatf("CMD: %0d",packet_2.CMD),UVM_LOW) */ 
/* 			`uvm_info(get_type_name(),$sformatf("RES: %0d",packet_2.RES),UVM_LOW) */ 
/* 			`uvm_info(get_type_name(),$sformatf("ERR: %0d",packet_2.ERR),UVM_LOW) */ 
/* 			`uvm_info(get_type_name(),$sformatf("COUT: %0d",packet_2.COUT),UVM_LOW) */ 
/* 			`uvm_info(get_type_name(),$sformatf("OFLOW: %0d",packet_2.OFLOW),UVM_LOW) */ 
/* 			`uvm_info(get_type_name(),$sformatf("EGL: %0d%0d%0d",packet_2.E,packet_2.G,packet_2.L),UVM_LOW) */ 
/* 		end */
/* 	endtask */	
/* endclass */	

//////////////////////////////////////////////////////////////////////////////
`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class alu_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(alu_scoreboard)

	int no = 1;  // no of transactions 
	int MATCH, MISMATCH;
	int mismatch_file;

	virtual alu_intf vif;
	alu_seq_item mon_packet_q[$];
	alu_seq_item drv_packet_q[$];

	uvm_analysis_imp_mon #(alu_seq_item, alu_scoreboard) item_collected_port;
	uvm_analysis_imp_drv #(alu_seq_item, alu_scoreboard) item_drv_port;
	
	function new (string name = "alu_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		mismatch_file = $fopen("mismatch_report.log", "w");

		if(!uvm_config_db#(virtual alu_intf)::get(this," ","vif",vif)) 
			`uvm_fatal("No_vif in scoreboard","virtual interface get failed from config db"); 

		item_collected_port = new("item_collected_port", this);
		item_drv_port = new("item_drv_port", this);
	endfunction

	virtual function void write_mon(alu_seq_item pkt);
		`uvm_info(get_type_name(), "Received packet from Monitor", UVM_DEBUG)
		mon_packet_q.push_back(pkt);
	endfunction

	virtual function void write_drv(alu_seq_item pkt);
		`uvm_info(get_type_name(), "Received packet from Driver", UVM_DEBUG)
		drv_packet_q.push_back(pkt);
	endfunction


	function alu_seq_item predict_model(alu_seq_item drv_pkt, alu_seq_item previous_val);
    
		alu_seq_item predicted_pkt;
    logic [`POW_2_N - 1:0] SH_AMT;
    predicted_pkt = new();
    predicted_pkt.copy(drv_pkt);
		
		if (get_report_verbosity_level() >= UVM_HIGH)  
			$display("\n---------------------------Before reference execution-----------------------------------");
		`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nRES:   %0d \n------------------------------------------------------------------", predicted_pkt.OPA, predicted_pkt.OPB, predicted_pkt.MODE, predicted_pkt.CMD, predicted_pkt.RES),UVM_HIGH) 

		if (drv_pkt.SCB_RST == 1) begin
        predicted_pkt.RES   = 'bz;
        predicted_pkt.COUT  = 1'bz;
        predicted_pkt.OFLOW = 1'bz;
        predicted_pkt.E     = 1'bz;
        predicted_pkt.G     = 1'bz;
        predicted_pkt.L     = 1'bz;
        predicted_pkt.ERR   = 1'bz;
    end 
		else if(predicted_pkt.CE == 0)
      predicted_pkt = previous_val;
    else begin
      predicted_pkt.RES   = 'bz;
      predicted_pkt.COUT  = 1'bz;
      predicted_pkt.OFLOW = 1'bz;
      predicted_pkt.E     = 1'bz;
			predicted_pkt.G     = 1'bz;
      predicted_pkt.L     = 1'bz;
      predicted_pkt.ERR   = 1'bz;	

		if(predicted_pkt.CE == 1) begin
			if(predicted_pkt.MODE) begin // Arithmetic Mode
				case(predicted_pkt.INP_VALID)
					2'b11: begin
						case(predicted_pkt.CMD)
							`ADD:
								begin
									predicted_pkt.RES = drv_pkt.OPA + drv_pkt.OPB;
									predicted_pkt.COUT = predicted_pkt.RES[`WIDTH];
								end
							`SUB:
								begin
									predicted_pkt.RES = drv_pkt.OPA - drv_pkt.OPB;
									predicted_pkt.OFLOW = drv_pkt.OPA < drv_pkt.OPB;
								end
							`ADD_CIN:
								begin
									predicted_pkt.RES = drv_pkt.OPA + drv_pkt.OPB + drv_pkt.CIN;
									predicted_pkt.COUT = predicted_pkt.RES[`WIDTH];
								end
							`SUB_CIN:
								begin
									predicted_pkt.RES = drv_pkt.OPA - drv_pkt.OPB - drv_pkt.CIN;
									predicted_pkt.OFLOW = (drv_pkt.OPA < drv_pkt.OPB) || ((drv_pkt.OPA == drv_pkt.OPB) && drv_pkt.CIN);
								end
							`CMP:
								begin
									if(drv_pkt.OPA == drv_pkt.OPB)
										predicted_pkt.E = drv_pkt.OPA == drv_pkt.OPB;
									else if(drv_pkt.OPA > drv_pkt.OPB)
										predicted_pkt.G = drv_pkt.OPA > drv_pkt.OPB;
									else
										predicted_pkt.L = drv_pkt.OPA < drv_pkt.OPB;
								end
							`INC_MULT: predicted_pkt.RES = (drv_pkt.OPA + 1) * (drv_pkt.OPB + 1);
							`SH_MULT:   predicted_pkt.RES = (drv_pkt.OPA << 1) * drv_pkt.OPB;
							default:    predicted_pkt.ERR = 1;
						endcase
					end
					// Cases for other INP_VALID values
					2'b01: begin
						if(predicted_pkt.CMD == `INC_A) predicted_pkt.RES = drv_pkt.OPA + 1;
						else if (predicted_pkt.CMD == `DEC_A) predicted_pkt.RES = drv_pkt.OPA - 1;
						else predicted_pkt.ERR = 1;
					end
					2'b10: begin
						if(predicted_pkt.CMD == `INC_B) 
							predicted_pkt.RES = drv_pkt.OPB + 1;
						else if (predicted_pkt.CMD == `DEC_B) 
							predicted_pkt.RES = drv_pkt.OPB - 1;
						else predicted_pkt.ERR = 1;
					end
					default: predicted_pkt.ERR = 1;
				endcase
			end
			else begin // Logical Mode
				case(predicted_pkt.INP_VALID)
					2'b11: begin
						case(predicted_pkt.CMD)
							`AND:   predicted_pkt.RES = {1'b0, drv_pkt.OPA & drv_pkt.OPB};
							`NAND:  predicted_pkt.RES = {1'b0, ~(drv_pkt.OPA & drv_pkt.OPB)};
							`OR:    predicted_pkt.RES = {1'b0, drv_pkt.OPA | drv_pkt.OPB};
							`NOR:   predicted_pkt.RES = {1'b0, ~(drv_pkt.OPA | drv_pkt.OPB)};
							`XOR:   predicted_pkt.RES = {1'b0, drv_pkt.OPA ^ drv_pkt.OPB};
							`XNOR:  predicted_pkt.RES = {1'b0, ~(drv_pkt.OPA ^ drv_pkt.OPB)};
							`ROL_A_B:
								begin
									SH_AMT = drv_pkt.OPB[`POW_2_N - 1:0];
									predicted_pkt.RES = {1'b0, drv_pkt.OPA << SH_AMT | drv_pkt.OPA >> (`WIDTH - SH_AMT)};
									predicted_pkt.ERR = |drv_pkt.OPB[`WIDTH - 1 : `POW_2_N +1];
								end
							`ROR_A_B:
								begin
								  SH_AMT = drv_pkt.OPB[`POW_2_N - 1:0];
								  predicted_pkt.RES = {1'b0, drv_pkt.OPA << (`WIDTH - SH_AMT) | drv_pkt.OPA >> SH_AMT};
								  predicted_pkt.ERR = |drv_pkt.OPB[`WIDTH - 1 : `POW_2_N +1];
								end
							default: predicted_pkt.ERR = 1;
						endcase
					end
					// Cases for other INP_VALID values
					2'b01: begin
						case(predicted_pkt.CMD)
							`NOT_A:  predicted_pkt.RES = {1'b0, ~drv_pkt.OPA};
							`SHR1_A: predicted_pkt.RES = drv_pkt.OPA >> 1;
							`SHL1_A: predicted_pkt.RES = drv_pkt.OPA << 1;
							default: predicted_pkt.ERR = 1;
						endcase
					end
					2'b10: begin
						case(predicted_pkt.CMD)
							`NOT_B:  predicted_pkt.RES = {1'b0, ~drv_pkt.OPB};
							`SHR1_B: predicted_pkt.RES = drv_pkt.OPB >> 1;
							`SHL1_B: predicted_pkt.RES = drv_pkt.OPB << 1; 
							default: predicted_pkt.ERR = 1;
						endcase
					end
					default: predicted_pkt.ERR = 1;
				endcase
			end
		end
		end

		if (get_report_verbosity_level() >= UVM_HIGH)  
			$display("\n---------------------------After reference execution-----------------------------------");
		`uvm_info(get_type_name(),$sformatf("\nRES:	 %0d \nERR:   %0d \nCOUT:  %0d \nOFLOW: %0d \nEGL:   %0b%0b%0b \n------------------------------------------------------------------", predicted_pkt.RES, predicted_pkt.ERR, predicted_pkt.COUT, predicted_pkt.OFLOW, predicted_pkt.E, predicted_pkt.G, predicted_pkt.L),UVM_HIGH) 

		return predicted_pkt;
	endfunction	


	task compare_and_report(alu_seq_item actual, alu_seq_item expected, alu_seq_item drv_input);
		bit mismatch_found = 0;
		string report_message;

		$display("---------------------------------------SCOREBOARD CHECK---------------------------------------");
		
		// Compare RES field
		if (actual.RES !== expected.RES) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: RES Mismatch! | Expected: %0d (%0h) | Actual: %0d (%0h)", 
			           expected.RES, expected.RES, actual.RES, actual.RES))
			mismatch_found = 1;
		end

		// Compare COUT field
		if (actual.COUT !== expected.COUT) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: COUT Mismatch! | Expected: %b | Actual: %b", 
			           expected.COUT, actual.COUT))
			mismatch_found = 1;
		end

		// Compare OFLOW field
		if (actual.OFLOW !== expected.OFLOW) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: OFLOW Mismatch! | Expected: %b | Actual: %b", 
			           expected.OFLOW, actual.OFLOW))
			mismatch_found = 1;
		end

		// Compare ERR field
		if (actual.ERR !== expected.ERR) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: ERR Mismatch! | Expected: %b | Actual: %b", 
			           expected.ERR, actual.ERR))
			mismatch_found = 1;
		end
		
		// Compare E, G, L flags for CMP operation
		if(expected.CMD == `CMP) begin
			if (actual.E !== expected.E) begin `uvm_error(get_type_name(), "FAIL: E Flag Mismatch!") mismatch_found = 1; end
			if (actual.G !== expected.G) begin `uvm_error(get_type_name(), "FAIL: G Flag Mismatch!") mismatch_found = 1; end
			if (actual.L !== expected.L) begin `uvm_error(get_type_name(), "FAIL: L Flag Mismatch!") mismatch_found = 1; end
		end

		/* // Final PASS/FAIL summary */
		/* if (mismatch_found) begin */
		/* 	`uvm_info(get_type_name(), "OVERALL RESULT: TRANSACTION FAILED", UVM_LOW) */
		/* 	// Log the full transaction details upon failure for complete context */
		/* 	/1* $display("DRIVER Transaction (Input):\n%s", drv_input.sprint()); *1/ */
		/* 	/1* $display("PREDICTED Transaction (Expected Output):\n%s", expected.sprint()); *1/ */
		/* 	/1* $display("MONITOR Transaction (Actual Output):\n%s", actual.sprint()); *1/ */
		/* 	MISMATCH ++; */
		/* end else begin */
		/* 	MATCH ++; */
		/* 	/1* report_message = $sformatf("PASS: Transaction Matched!\n%s", actual.sprint()); *1/ */
		/* 	`uvm_info(get_type_name(), report_message, UVM_MEDIUM) */
		/* end */


/////////////////////////
// Final PASS/FAIL summary
	if (mismatch_found) begin
		`uvm_info(get_type_name(), "OVERALL RESULT: TRANSACTION FAILED", UVM_LOW)
		MISMATCH++;

		// ADD THIS BLOCK: Write the detailed report to our file
		$fdisplay(mismatch_file, "------------------- MISMATCH FOUND @ %0t -------------------", $time);
		$fdisplay(mismatch_file, "DRIVER Transaction (Input):\n%s", drv_input.sprint());
		$fdisplay(mismatch_file, "\nPREDICTED Transaction (Expected Output):\n%s", expected.sprint());
		$fdisplay(mismatch_file, "\nMONITOR Transaction (Actual Output):\n%s", actual.sprint());
		$fdisplay(mismatch_file, "------------------------------------------------------------------\n");

	end else begin
		MATCH++;
		`uvm_info(get_type_name(), "PASS: Transaction Matched!", UVM_HIGH)
	end
///////////////////////////

	endtask

	virtual task run_phase(uvm_phase phase);
		alu_seq_item drv_pkt;  // packet coming from driver for refernce model
		alu_seq_item mon_pkt;  // result packet coming for DUT
		alu_seq_item predicted_pkt;  // result packet of reference model
		alu_seq_item previous_val;  // when ce=0, previous values are supposed be retained, this is meant for reference model
		previous_val = new();	

		forever begin
			wait(drv_packet_q.size() > 0 && mon_packet_q.size() > 0);
			
			drv_pkt = drv_packet_q.pop_front();
			mon_pkt = mon_packet_q.pop_front();
			
			if (get_report_verbosity_level() >= UVM_HIGH) 
				$display("\n-------------------------------From driver side -----------------------------------");
			`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nCE:   %0b \nValid:    %0b \nCIN:    %0b",drv_pkt.OPA, drv_pkt.OPB, drv_pkt.MODE, drv_pkt.CMD,drv_pkt.CE,drv_pkt.INP_VALID, drv_pkt.CIN),UVM_HIGH) 

			if (get_report_verbosity_level() >= UVM_HIGH)
				$display("\n------------------------------From monitor side -------------------------------------");
			`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nCE:    %0b \nValid:    %0b \nCIN:    %0b \nRES:   %0d \nERR:    %0b",mon_pkt.OPA, mon_pkt.OPB, mon_pkt.MODE, mon_pkt.CMD,mon_pkt.CE,mon_pkt.INP_VALID,mon_pkt.CIN, mon_pkt.RES, mon_pkt.ERR),UVM_HIGH)
			
			predicted_pkt = predict_model(drv_pkt,previous_val);
			previous_val = predicted_pkt;

			compare_and_report(mon_pkt, predicted_pkt, drv_pkt);
			$display("======================================Total no of transaction========================================",);
			$display("============================================== %0d ====================================================",no++);
			$display("======================================Match of %0d out of %0d==========================================\n",MATCH,(MISMATCH + MATCH));
		end
	endtask

	// this part is used to put errors in a separate file
	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		$fclose(mismatch_file);
	endfunction

endclass

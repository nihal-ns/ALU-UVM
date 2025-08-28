`uvm_analysis_imp_decl(_mon_pass)
`uvm_analysis_imp_decl(_mon_act)

class alu_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(alu_scoreboard)

	int no = 1;  // no of transactions 
	int MATCH, MISMATCH;
	int mismatch_file;

	virtual alu_intf vif;
	alu_seq_item mon_act_packet_q[$];
	alu_seq_item mon_pass_packet_q[$];

	uvm_analysis_imp_mon_act #(alu_seq_item, alu_scoreboard) item_act_port;
	uvm_analysis_imp_mon_pass #(alu_seq_item, alu_scoreboard) item_pass_port;
	
	function new (string name = "alu_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		mismatch_file = $fopen("mismatch_report.log", "w");

		if(!uvm_config_db#(virtual alu_intf)::get(this," ","vif",vif)) 
			`uvm_fatal("No_vif in scoreboard","virtual interface get failed from config db"); 

		item_act_port = new("item_act_port", this);
		item_pass_port = new("item_pass_port", this);
	endfunction

	virtual function void write_mon_act(alu_seq_item pkt);
		`uvm_info(get_type_name(), "Received input packet ", UVM_DEBUG)
		mon_act_packet_q.push_back(pkt);
	endfunction

	virtual function void write_mon_pass(alu_seq_item pkt);
		`uvm_info(get_type_name(), "Received output packet ", UVM_DEBUG)
		mon_pass_packet_q.push_back(pkt);
	endfunction


	function alu_seq_item predict_model(alu_seq_item input_pkt, alu_seq_item previous_val);
    
		alu_seq_item predicted_pkt;
    logic [`POW_2_N - 1:0] SH_AMT;
    predicted_pkt = new();
    predicted_pkt.copy(input_pkt);
		
		if (get_report_verbosity_level() >= UVM_HIGH)  
			$display("\n---------------------------Before reference execution-----------------------------------");
		`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nRES:   %0d \n------------------------------------------------------------------", predicted_pkt.OPA, predicted_pkt.OPB, predicted_pkt.MODE, predicted_pkt.CMD, predicted_pkt.RES),UVM_HIGH) 

		if (input_pkt.SCB_RST == 1) begin
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
										predicted_pkt.RES = input_pkt.OPA + input_pkt.OPB;
										predicted_pkt.COUT = predicted_pkt.RES[`WIDTH];
									end
								`SUB:
									begin
										predicted_pkt.RES = input_pkt.OPA - input_pkt.OPB;
										predicted_pkt.OFLOW = input_pkt.OPA < input_pkt.OPB;
									end
								`ADD_CIN:
									begin
										predicted_pkt.RES = input_pkt.OPA + input_pkt.OPB + input_pkt.CIN;
										predicted_pkt.COUT = predicted_pkt.RES[`WIDTH];
									end
								`SUB_CIN:
									begin
										predicted_pkt.RES = input_pkt.OPA - input_pkt.OPB - input_pkt.CIN;
										predicted_pkt.OFLOW = (input_pkt.OPA < input_pkt.OPB) || ((input_pkt.OPA == input_pkt.OPB) && input_pkt.CIN);
									end
								`CMP:
									begin
										if(input_pkt.OPA == input_pkt.OPB)
											predicted_pkt.E = input_pkt.OPA == input_pkt.OPB;
										else if(input_pkt.OPA > input_pkt.OPB)
											predicted_pkt.G = input_pkt.OPA > input_pkt.OPB;
										else
											predicted_pkt.L = input_pkt.OPA < input_pkt.OPB;
									end
								`INC_MULT: predicted_pkt.RES = (input_pkt.OPA + 1) * (input_pkt.OPB + 1);
								`SH_MULT:   predicted_pkt.RES = (input_pkt.OPA << 1) * input_pkt.OPB;
								default:    predicted_pkt.ERR = 1;
							endcase
						end
						// Cases for other INP_VALID values
						2'b01: begin
							if(predicted_pkt.CMD == `INC_A) predicted_pkt.RES = input_pkt.OPA + 1;
							else if (predicted_pkt.CMD == `DEC_A) predicted_pkt.RES = input_pkt.OPA - 1;
							else predicted_pkt.ERR = 1;
						end
						2'b10: begin
							if(predicted_pkt.CMD == `INC_B)
								predicted_pkt.RES = input_pkt.OPB + 1;
							else if (predicted_pkt.CMD == `DEC_B)
								predicted_pkt.RES = input_pkt.OPB - 1;
							else predicted_pkt.ERR = 1;
						end
						default: predicted_pkt.ERR = 1;
					endcase
				end
				else begin // Logical Mode
					case(predicted_pkt.INP_VALID)
						2'b11: begin
							case(predicted_pkt.CMD)
								`AND:   predicted_pkt.RES = {1'b0, input_pkt.OPA & input_pkt.OPB};
								`NAND:  predicted_pkt.RES = {1'b0, ~(input_pkt.OPA & input_pkt.OPB)};
								`OR:    predicted_pkt.RES = {1'b0, input_pkt.OPA | input_pkt.OPB};
								`NOR:   predicted_pkt.RES = {1'b0, ~(input_pkt.OPA | input_pkt.OPB)};
								`XOR:   predicted_pkt.RES = {1'b0, input_pkt.OPA ^ input_pkt.OPB};
								`XNOR:  predicted_pkt.RES = {1'b0, ~(input_pkt.OPA ^ input_pkt.OPB)};
								`ROL_A_B:
									begin
										SH_AMT = input_pkt.OPB[`POW_2_N - 1:0];
										predicted_pkt.RES = {1'b0, input_pkt.OPA << SH_AMT | input_pkt.OPA >> (`WIDTH - SH_AMT)};
										predicted_pkt.ERR = |input_pkt.OPB[`WIDTH - 1 : `POW_2_N +1];
									end
								`ROR_A_B:
									begin
										SH_AMT = input_pkt.OPB[`POW_2_N - 1:0];
										predicted_pkt.RES = {1'b0, input_pkt.OPA << (`WIDTH - SH_AMT) | input_pkt.OPA >> SH_AMT};
										predicted_pkt.ERR = |input_pkt.OPB[`WIDTH - 1 : `POW_2_N +1];
									end
								default: predicted_pkt.ERR = 1;
							endcase
						end
						// Cases for other INP_VALID values
						2'b01: begin
							case(predicted_pkt.CMD)
								`NOT_A:  predicted_pkt.RES = {1'b0, ~input_pkt.OPA};
								`SHR1_A: predicted_pkt.RES = input_pkt.OPA >> 1;
								`SHL1_A: predicted_pkt.RES = input_pkt.OPA << 1;
								default: predicted_pkt.ERR = 1;
							endcase
						end
						2'b10: begin
							case(predicted_pkt.CMD)
								`NOT_B:  predicted_pkt.RES = {1'b0, ~input_pkt.OPB};
								`SHR1_B: predicted_pkt.RES = input_pkt.OPB >> 1;
								`SHL1_B: predicted_pkt.RES = input_pkt.OPB << 1;
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


	task compare_and_report(alu_seq_item actual, alu_seq_item expected);
	bit mismatch_found = 0;
	string report_message;

	$display("---------------------------------------SCOREBOARD---------------------------------------");

	if (actual.RES !== expected.RES) begin
		`uvm_error(get_type_name(), $sformatf("FAIL: RES Mismatch! | Expected: %0d | Actual: %0d ",expected.RES, actual.RES))
		mismatch_found = 1;
	end

	if (actual.COUT !== expected.COUT) begin
		`uvm_error(get_type_name(), $sformatf("FAIL: COUT Mismatch! | Expected: %b | Actual: %b",expected.COUT, actual.COUT))
		mismatch_found = 1;
	end

	if (actual.OFLOW !== expected.OFLOW) begin
		`uvm_error(get_type_name(), $sformatf("FAIL: OFLOW Mismatch! | Expected: %b | Actual: %b",expected.OFLOW, actual.OFLOW))
		mismatch_found = 1;
	end

	if (actual.ERR !== expected.ERR) begin
		`uvm_error(get_type_name(), $sformatf("FAIL: ERR Mismatch! | Expected: %b | Actual: %b", 	expected.ERR, actual.ERR))
		mismatch_found = 1;
	end

	if (actual.E !== expected.E || actual.G !== expected.G || actual.L !== expected.L) begin 
		`uvm_error(get_type_name(), $sformatf("FAIL: EGL Flag Mismatch! | Expected(EGL): %0b%0b%0b | Actual(EGL): %0b%0b%0b",  expected.E, expected.G,expected.L, actual.E, actual.G, actual.L)) 
		mismatch_found = 1; 
	end

	if (mismatch_found) begin
		`uvm_info(get_type_name(), "OVERALL RESULT: TRANSACTION FAILED", UVM_LOW)
		MISMATCH ++;
	end else begin
		MATCH ++;
		$display("OUTPUT MATCHES\n \tEXPECTED\tRECEIVED\nRES:   %0d\t\t%0d\nOFLOW: %1b\t\t%1b\nCOUT:  %1b\t\t%1b\nE:     %1b\t\t%1b\nG:     %1b\t\t%1b\nL:     %1b\t\t%1b \nERR:   %1b\t\t%1b\n", expected.RES, actual.RES, expected.OFLOW, actual.OFLOW, expected.COUT, actual.COUT, expected.E, actual.E, expected.G, actual.G, expected.L, actual.L, expected.ERR, actual.ERR);
		/* `uvm_info(get_type_name(), $sformatf("PASS: Transaction Matched!\n%s", actual.sprint()), UVM_MEDIUM) */
	end

	/* if (mismatch_found) begin */
	/* 	`uvm_info(get_type_name(), "OVERALL RESULT: TRANSACTION FAILED", UVM_LOW) */
	/* 	MISMATCH++; */

	/* 	$fdisplay(mismatch_file, "------------------- MISMATCH FOUND @ %0t -------------------", $time); */
	/* 	$fdisplay(mismatch_file, "------------------------------------------------------------------\n"); */

	/* end else begin */
	/* 	MATCH++; */
	/* 	`uvm_info(get_type_name(), "PASS: Transaction Matched!", UVM_HIGH) */
	/* end */
	endtask

	virtual task run_phase(uvm_phase phase);
		alu_seq_item mon_act_pkt;  
		alu_seq_item mon_pass_pkt;  
		alu_seq_item predicted_pkt; 
		alu_seq_item previous_val;  // when ce=0, previous values are supposed be retained, this is meant for reference model
		previous_val = new();	

		forever begin
			wait(mon_act_packet_q.size() > 0 && mon_pass_packet_q.size() > 0);
			
			mon_act_pkt = mon_act_packet_q.pop_front();
			mon_pass_pkt = mon_pass_packet_q.pop_front();

			if (get_report_verbosity_level() >= UVM_HIGH) 
				$display("\n-------------------------------inputs -----------------------------------");
			`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nCE:   %0b \nValid:    %0b \nCIN:    %0b",mon_act_pkt.OPA, mon_act_pkt.OPB, mon_act_pkt.MODE, mon_act_pkt.CMD, mon_act_pkt.CE, mon_act_pkt.INP_VALID, mon_act_pkt.CIN),UVM_HIGH) 

			if (get_report_verbosity_level() >= UVM_HIGH)
				$display("\n------------------------------outputs-------------------------------------");
			`uvm_info(get_type_name(),$sformatf("\nRES:   %0d \nERR:    %0b\nCOUT:    %0b\nOFLOW:    %0b\nEGL:    %0b%0b%0b\n",mon_pass_pkt.RES, mon_pass_pkt.ERR, mon_pass_pkt.COUT, mon_pass_pkt.OFLOW, mon_pass_pkt.E, mon_pass_pkt.G, mon_pass_pkt.L),UVM_HIGH)
		
			predicted_pkt = predict_model(mon_act_pkt, previous_val);
			previous_val = predicted_pkt;

			compare_and_report(mon_pass_pkt, predicted_pkt);
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

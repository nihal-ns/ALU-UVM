class alu_sequence extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(alu_sequence)

	function new(string name = "alu_sequence");
		super.new(name);
	endfunction

	virtual task body();
		req = alu_seq_item::type_id::create("req");
		wait_for_grant();
		assert(req.randomize());
		send_request(req); 
		wait_for_item_done(); 
		//get_reponse(req);
	endtask	
endclass	

////////////////////////////////////////////////////////////////////////
// custom mode
class custom extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(custom)

	function new(string name = "custom");
		super.new(name);
	endfunction

	virtual task body();
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {[0:3]};req.INP_VALID == 3;}) */
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {[0:3],8,9,10};req.INP_VALID == 3;}) */
	`uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {9,10};req.INP_VALID == 3;req.op_delivery == SINGLE_CYCLE;})
	`uvm_do_with(req,{req.MODE == 1;req.CE == 0;req.CMD inside {9,10};req.INP_VALID == 3;req.op_delivery == SINGLE_CYCLE;})
  endtask 
endclass
/////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////
// arithmetic sequence
class arith extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(arith)

	function new(string name = "arith");
		super.new(name);
	endfunction

	virtual task body();
	`uvm_do_with(req, {
		req.MODE == 1;
		req.CE == 1;
		req.CMD inside {[0:10]};

		if(req.CMD == 4 || req.CMD == 5) 
			req.INP_VALID == 2'b01; 
		else if(req.CMD == 6 || req.CMD ==7) 
			req.INP_VALID == 2; 
		else req.INP_VALID == 3;

		req.op_delivery == SINGLE_CYCLE; 
		})
  endtask 

endclass	

///////////////////////////////////////////////////////////////
// logical sequence
class logical extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(logical)

	function new(string name = "logical");
		super.new(name);
	endfunction

	virtual task body();
	`uvm_do_with(req, {
		req.MODE == 0;
		req.CE == 1;
		req.CMD inside {[0:13]};

		if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
			req.INP_VALID == 2'b01; 
		else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
			req.INP_VALID == 2; 
		else req.INP_VALID == 3;

		req.op_delivery == SINGLE_CYCLE;
		})
  endtask 

endclass	

///////////////////////////////////////////////////////////////
// error flag
class error extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(error)

	function new(string name = "error");
		super.new(name);
	endfunction

	virtual task body();
		// cmd out of range and invalid input valid 
		`uvm_do_with(req, {
			if(req.MODE) 
				req.CMD inside {[4:7],[11:15]}; 
			else 
				req.CMD inside {[6:11],[14:15]};
			
			if(req.MODE) 
			{     // to check if {} works here !!!! (status: )
				if(req.CMD == 4 || req.CMD == 5) 
					req.INP_VALID == 2'b10; 
				else if(req.CMD == 6 || req.CMD == 7) 
					req.INP_VALID == 2'b01; 
				else 
					req.INP_VALID == 2'b00;
			
			} else {
			
				if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
					req.INP_VALID == 2'b10; 
				else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
					req.INP_VALID == 2'b01; 
				else 
					req.INP_VALID == 2'b00; 
			}

			req.CE == 1;
			req.op_delivery == SINGLE_CYCLE;
		})
	endtask	

endclass	

///////////////////////////////////////////////////////////////
// flag check
class flag extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(flag)
	
	function new(string name = "flag");
		super.new(name);
	endfunction

	virtual task body();
		// checking for cout, oflow , E , G and L flags
		`uvm_do_with(req, {
			req.MODE dist {0:=2,1:=8};
			
			if(req.MODE) 
				req.CMD inside {[0:3],8};     // add, add_cin, sub, sub_cin, cmp
			else
				req.CMD inside {12,13};       // ROR, ROL (error flags in this case)
			
			if(req.MODE)
				if(req.CMD == 4 || req.CMD == 5) 
					req.INP_VALID == 2'b01; 
				else if(req.CMD == 6 || req.CMD == 7) 
					req.INP_VALID == 2'b10; 
				else 
					req.INP_VALID == 2'b11;

			else
				
				if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
					req.INP_VALID == 2'b01; 
				else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
					req.INP_VALID == 2'b10; 
				else 
					req.INP_VALID == 2'b11; 

			if(req.MODE) {
				if(req.CMD == 0 || req.CMD == 2)
					req.OPA + req.OPB >= 9'b100000000;
				else if(req.CMD == 1 || req.CMD == 3)
					{
						if(req.CIN)
							req.OPA == req.OPB;
						else
							req.OPA < req.OPB;
					}
				else
					req.OPB > 4'b1111;}

		req.CE == 1;
		req.op_delivery == SINGLE_CYCLE;
			})

	endtask	
endclass	

///////////////////////////////////////////////////////////////
// Sequence to test split-operand and timeout features
class split_transaction_seq extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(split_transaction_seq)

	function new(string name = "split_transaction_seq");
		super.new(name);
	endfunction

	virtual task body();

			`uvm_do_with(req, {
				req.CE == 1;
				req.op_delivery == SPLIT_OPA_FIRST;  //SINGLE_CYCLE;
				req.CMD inside {[0:3]};
				req.INP_VALID inside {1,2,3};
				/* if(CMD == 4 || CMD == 5) INP_VALID == 2'b01; else if(CMD == 6 || CMD ==7) INP_VALID ==     2;else INP_VALID == 3; */
				req.MODE == 1;
			})
			
			`uvm_do_with(req, {
				req.CE == 1;
				req.op_delivery == SPLIT_OPB_FIRST;  //SINGLE_CYCLE;
				req.CMD inside {[0:3]};
				req.INP_VALID inside {1,2,3};
				req.MODE == 1;
			})
			
			`uvm_do_with(req, {
				req.CE == 1;
				req.op_delivery == SPLIT_TIMEOUT;
				req.CMD inside {[0:3]};
				req.INP_VALID inside {1,2,3};
				req.MODE == 1;
			})
	endtask

endclass

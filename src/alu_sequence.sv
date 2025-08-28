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
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {9,10};req.INP_VALID == 3;}) */
	/* `uvm_do_with(req,{req.MODE == 0;req.CE == 1;req.CMD inside {6,8,9}; */
	/* 	if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) */
	/* 		req.INP_VALID == 1; */
	/* 	else */
	/* 		req.INP_VALID == 2;}) */

	/* `uvm_do_with(req,{req.MODE == 0;req.CE == 1;req.CMD inside {7,10,11}; */
	/* 	if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) */
	/* 		req.INP_VALID == 1; */
	/* 	else */
	/* 		req.INP_VALID == 2;}) */

	`uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {4,5};
		if(req.CMD == 4 || req.CMD == 5)
			req.INP_VALID == 1;
		else
			req.INP_VALID == 2;})

	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {6,7}; */
	/* 	if(req.CMD == 4 || req.CMD == 5) */
	/* 		req.INP_VALID == 1; */
	/* 	else */
	/* 		req.INP_VALID == 2;}) */
  endtask 

endclass
/////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////
// arithmetic sequence
class arith extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(arith)

	int cmp_op;
	function int pick_cmp_relation();
	  return $urandom_range(1, 5); 
	endfunction

	function new(string name = "arith");
		super.new(name);
	endfunction

	virtual task body();
	cmp_op = pick_cmp_relation();
	`uvm_do_with(req, {
		req.MODE == 1;
		req.CE == 1;
		req.CMD inside {[0:10]};

		if(req.CMD == 4 || req.CMD == 5) 
			req.INP_VALID == 1; 
		else if(req.CMD == 6 || req.CMD ==7) 
			req.INP_VALID == 2; 
		else req.INP_VALID == 3;
		
		if(cmp_op == 1 && req.CMD == 8) // just to increase the probability for opa == opb 
			req.OPA == req.OPB;
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
		else 
			req.INP_VALID == 3;
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
			req.MODE == 1;
			req.CMD inside {[4:7],[11:15]}; 
			
			if(req.CMD == 4 || req.CMD == 5) 
				req.INP_VALID == 2'b10; 
			else if(req.CMD == 6 || req.CMD == 7) 
				req.INP_VALID == 2'b01; 
			else 
				req.INP_VALID == 2'b00;

			req.CE == 1;
		})
		`uvm_do_with(req, {
		req.CE == 1;
		req.MODE == 0;
		req.CMD inside {[6:11],[14:15]};

		if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
			req.INP_VALID == 2'b10; 
		else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
			req.INP_VALID == 2'b01; 
		else 
			req.INP_VALID == 2'b00; 
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

		/* req.CE == 1; */
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
				req.INP_VALID inside {1,2,3};
				if(req.MODE)
					req.CMD inside {[0:3],[8:10]};
				else
					req.CMD inside {[0:5],12,13};
			})
	endtask

endclass

///////////////////////////////////////////
// regress test
class regress extends uvm_sequence#(alu_seq_item);
	
	`uvm_object_utils(regress)
	
	arith test1;
	logical test2;
	error test3;
	flag test4;
	split_transaction_seq test5;

	function new(string name = "regress");
		super.new(name);
		test1 = arith::type_id::create("test1");
		test2 = logical::type_id::create("test1");
		test3 = error::type_id::create("test1");
		test4 = flag::type_id::create("test1");
		test5 = split_transaction_seq::type_id::create("test1");
	endfunction

	virtual task body();
		`uvm_do(test1)
		`uvm_do(test2)
		`uvm_do(test3)
		`uvm_do(test4)
		`uvm_do(test5)
	endtask	
endclass	

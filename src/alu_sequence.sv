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

class arith extends uvm_sequence#(alu_seq_item);
	`uvm_object_utils(arith)

	function new(string name = "arith");
		super.new(name);
	endfunction

	virtual task body();
	`uvm_do_with(req,{req.MODE == 1;req.CE == 1;})
  endtask 

endclass	

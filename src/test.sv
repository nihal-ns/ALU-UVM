class test extends uvm_test;
	`uvm_component_utils(test)

	alu_env env;
	alu_sequence seq;

	function new(string name = "test",uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = alu_env::type_id::create("env",this);
		set_config_int("env.agt", "is_active", UVM_ACTIVE);
		seq = alu_sequence::type_id::create("seq");
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(2)
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
	endtask

	virtual function void end_of_elaboration();
		print();
	endfunction
endclass

//////////////////////////////////////////////////////////////////
// custom test case
class custom_test extends test;
	`uvm_component_utils(custom_test)

	custom seq;
	int no = 5;

	function new(string name = "custom_test",uvm_component parent = null);
		super.new(name,parent);
		seq = custom::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(no)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	

////////////////////////////////////////////////////////////////////////
// arithmetic test case
class arith_test extends test;
	`uvm_component_utils(arith_test)

	arith seq;

	function new(string name = "arith_test",uvm_component parent = null);
		super.new(name,parent);
		seq = arith::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(10)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	

//////////////////////////////////////////////
// logical test case
class logical_test extends test;
	`uvm_component_utils(logical_test)

	logical seq;

	function new(string name = "logical_test",uvm_component parent = null);
		super.new(name,parent);
		seq = logical::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(10)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	

/////////////////////////////////////////////////
// error flag test
class error_test extends test;
	`uvm_component_utils(error_test)

	error seq;

	function new(string name = "error_test",uvm_component parent = null);
		super.new(name,parent);
		seq = error::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(10)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	

/////////////////////////////////////////////////
// flag test
class flag_test extends test;
	`uvm_component_utils(flag_test)

	flag seq;

	function new(string name = "flag_test",uvm_component parent = null);
		super.new(name,parent);
		seq = flag::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(10)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	

/////////////////////////////////////////////////
// 16 clock cycle
class split_test extends test;
	`uvm_component_utils(split_test)

	split_transaction_seq seq;

	function new(string name = "split_test",uvm_component parent = null);
		super.new(name,parent);
		seq = split_transaction_seq::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(5)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	
////////////////////////////////////////////////////////////////////////
// regress

class regress_test extends test;
	`uvm_component_utils(regress_test)

	regress seq;

	function new(string name = "regress_test",uvm_component parent = null);
		super.new(name,parent);
		seq = regress::type_id::create("seq");
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(2)
			/* seq = arith::type_id::create("seq"); */
			seq.start(env.agt.seqr);
		phase.drop_objection(this);
  endtask
endclass	

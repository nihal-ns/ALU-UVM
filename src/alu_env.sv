class alu_env extends uvm_env;
	`uvm_component_utils(alu_env);

	alu_agent agt;
	alu_scoreboard scb;
	alu_coverage cov;

	function new(string name = "alu_env", uvm_component parent);
		super.new(name,parent);
	endfunction	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt = alu_agent::type_id::create("agt",this);
		/* set_config_int("agt", "is_active", UVM_ACTIVE); */
		scb = alu_scoreboard::type_id::create("scb",this);
		cov = alu_coverage::type_id::create("cov",this);
	endfunction	

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agt.mon.item_collected_port.connect(scb.item_collected_port);
		/* agt.drv.item_collected_port.connect(scb.item_drv); */
		agt.drv.item_collected_port.connect(scb.item_drv_port);
		
		agt.drv.item_collected_port.connect(cov.analysis_export);
		agt.mon.item_collected_port.connect(cov.mon_cg_port);
	endfunction	
endclass	

class alu_driver extends uvm_driver#(alu_seq_item);
	`uvm_component_utils(alu_driver)

	virtual alu_intf  vif;
	uvm_analysis_port #(alu_seq_item) item_collected_port;

	function new(string name = "alu_driver", uvm_component parent);
		super.new(name,parent);
		item_collected_port = new("item_collected_port",this);
	endfunction	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual alu_intf)::get(this," ","vif",vif))
			`uvm_fatal("No_vif in driver","virtual interface get failed from config db"); 
	endfunction	

	task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			drive();
			seq_item_port.item_done();
		end
	endtask	

	virtual task drive();
		/* if(vif.DRIVER.drv_cb.rst == 1) */
		/* 	/1* repeat(1) @(vif.DRIVER.drv_cb) *1/ */
		/* 	begin */
		/* 		vif.DRIVER.drv_cb.OPA <= '0; */
		/* 		vif.DRIVER.drv_cb.OPB <= '0; */
		/* 		vif.DRIVER.drv_cb.MODE <= 0; */
		/* 		vif.DRIVER.drv_cb.CMD <= '0; */
		/* 		vif.DRIVER.drv_cb.CIN <= 0; */
		/* 		vif.DRIVER.drv_cb.CE <= 0; */
		/* 		vif.DRIVER.drv_cb.INP_VALID <= 2'b0; */

		/* 		repeat(1) @(vif.DRIVER.drv_cb); */
		/* 		/1* $display("%0t || Driver reset: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d",$time,req.MODE, req.CMD, req.INP_VALID, req.OPA, req.OPB); *1/ */
		/* 	end */
		/* else */
		/* 	repeat(1) @(vif.DRIVER.drv_cb) */
		/* 	begin */
		/* 		vif.DRIVER.drv_cb.OPA <= req.OPA; */
		/* 		vif.DRIVER.drv_cb.OPB <= req.OPB; */
		/* 		vif.DRIVER.drv_cb.MODE <= req.MODE; */
				/* vif.DRIVER.drv_cb.CMD <= req.CMD; */
				/* vif.DRIVER.drv_cb.CIN <= req.CIN; */
				/* vif.DRIVER.drv_cb.CE <= req.CE; */
				/* vif.DRIVER.drv_cb.INP_VALID <= req.INP_VALID; */
				/* $display("%0t || Driver: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d",$time,req.MODE, req.CMD, req.INP_VALID, req.OPA, req.OPB); */
				/* repeat(1) @(vif.DRIVER.drv_cb); */ 
			/* end */
		/* item_collected_port.write(req); */


				vif.drv_cb.OPA <= req.OPA;
				vif.drv_cb.OPB <= req.OPB;
				vif.drv_cb.MODE <= req.MODE;
				vif.drv_cb.CMD <= req.CMD;
				vif.drv_cb.CIN <= req.CIN;
				vif.drv_cb.CE <= req.CE;
				vif.drv_cb.INP_VALID <= req.INP_VALID;
				$display("%0t || Driver: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d",$time,req.MODE, req.CMD, req.INP_VALID, req.OPA, req.OPB);
				/* repeat(1) @(vif.drv_cb); */
		item_collected_port.write(req);
			repeat(3)@(vif.drv_cb);
	endtask	
	
endclass	

class alu_driver extends uvm_driver#(alu_seq_item);
	`uvm_component_utils(alu_driver)

	virtual alu_intf  vif;
	uvm_analysis_port #(alu_seq_item) item_collected_port;
	int count = 0;

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
		if(vif.rst == 1)
			begin
				vif.drv_cb.OPA				<= '0;
				vif.drv_cb.OPB				<= '0;
				vif.drv_cb.MODE				<= 0;
				vif.drv_cb.CMD				<= '0;
				vif.drv_cb.CIN				<= 0;
				vif.drv_cb.CE					<= 0;
				vif.drv_cb.INP_VALID	<= 2'b0;

				req.OPA				<= 0;
				req.OPB				<= 0;
				req.MODE			<= 0;
				req.CMD				<= 0;
				req.CIN				<= 0;
				req.CE				<= 0;
				req.INP_VALID <= 0;
				req.SCB_RST		<= 1;
				
				
				repeat(1)@(vif.drv_cb);  // remove this (not yet)
				`uvm_info(get_type_name(),$sformatf("\nDriver Reset: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d \n",req.MODE, req.CMD, req.INP_VALID, req.OPA, req.OPB),UVM_LOW)
				item_collected_port.write(req);
				repeat(3)@(vif.drv_cb);  // remove this (not yet)
			end

		else begin

			req.SCB_RST <= 0;
			if(req.op_delivery == SINGLE_CYCLE) begin
				vif.drv_cb.OPA				<= req.OPA;
				vif.drv_cb.OPB				<= req.OPB;
				vif.drv_cb.MODE				<= req.MODE;
				vif.drv_cb.CMD				<= req.CMD;
				vif.drv_cb.CIN				<= req.CIN;
				vif.drv_cb.CE					<= req.CE;
				vif.drv_cb.INP_VALID	<= req.INP_VALID;	

				`uvm_info(get_type_name(),$sformatf("\nDriver: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d |CE:%0b\n",req.MODE, req.CMD, req.INP_VALID, req.OPA,   req.OPB, req.CE),UVM_LOW)
				
				item_collected_port.write(req);
				repeat(5)@(vif.drv_cb);  // 3(previous)
			end

			else if(req.op_delivery == SPLIT_OPA_FIRST || req.op_delivery == SPLIT_OPB_FIRST) begin
				vif.drv_cb.MODE     <= req.MODE;
				vif.drv_cb.CMD      <= req.CMD;
				vif.drv_cb.CIN      <= req.CIN;
				vif.drv_cb.CE       <= req.CE;

				if (req.op_delivery == SPLIT_OPA_FIRST) begin
					vif.drv_cb.OPA				<= req.OPA;
					vif.drv_cb.INP_VALID	<= 2'b01;
				end
				else begin
					vif.drv_cb.OPB				<= req.OPB;
					vif.drv_cb.INP_VALID	<= 2'b10;
				end

				count = $urandom_range(1, 15);
				$display("%0t ||First operand sent. Waiting %0d cycles...",$time, count);
				/* `uvm_info(get_type_name(), $sformatf("First operand sent. Waiting %0d cycles...", count), UVM_LOW) */
				for (int i = count; i > 0; i--) begin
					/* `uvm_info(get_type_name(), $sformatf("...%0d cycles remaining...", i), UVM_LOW) */
					$display("...%0d cycles remaining...",i);
					@(vif.drv_cb);
				end

				`uvm_info(get_type_name(), "Second operand sent.", UVM_LOW)
				if (req.op_delivery == SPLIT_OPA_FIRST) begin
					vif.drv_cb.OPB      <= req.OPB;
				end else begin
					vif.drv_cb.OPA      <= req.OPA;
				end				

				vif.drv_cb.INP_VALID <= 2'b11; 
				req.INP_VALID <= 2'b11;	

				`uvm_info(get_type_name(),$sformatf("\nDriver: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d |CE:%0b |CIN:%0b\n",req.MODE, req.CMD, req.INP_VALID, req.OPA,  req.OPB, req.CE, req.CIN),UVM_LOW)
				item_collected_port.write(req);
				repeat(4)@(vif.drv_cb);
			end

			else if(req.op_delivery == SPLIT_TIMEOUT) begin
				
				vif.drv_cb.MODE     <= req.MODE;
				vif.drv_cb.CMD      <= req.CMD;
				vif.drv_cb.CIN      <= req.CIN;
				vif.drv_cb.CE       <= req.CE;

				vif.drv_cb.OPA			<= req.OPA;
				req.OPB	<= 0;							
				/* req.ERR <= 1; */
				vif.drv_cb.INP_VALID <= 2'b01;
				req.INP_VALID <= 2'b01;

				`uvm_info(get_type_name(), "Driver: Intentionally causing a timeout", UVM_LOW)
				repeat(20) @(vif.drv_cb);

				/* vif.drv_cb.INP_VALID <= 2'b00; */
				`uvm_info(get_type_name(),$sformatf("\nDriver: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d |CE:%0b\n",req.MODE, req.CMD, req.INP_VALID, req.OPA,  req.OPB, req.CE),UVM_LOW)
				item_collected_port.write(req);
				repeat(1)@(vif.drv_cb); // previous 2
			end
		end
	endtask
endclass	



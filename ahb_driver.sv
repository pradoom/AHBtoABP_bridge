class ahb_driver extends uvm_driver #(ahb_seq_item);
`uvm_component_utils(ahb_driver)
virtual ahb2apb_interface vin;
ahb_seq_item item;
function new(string name="ahb_driver",uvm_component parent);
	super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual ahb2apb_interface)::get(this,"","ahb2apb_interface",vin))
	`uvm_fatal(get_type_name(),$sformatf("[AHB_DRIVER]: VIN not form"));
	
	item = ahb_seq_item::type_id::create("item", this);
endfunction:build_phase


task run_phase(uvm_phase phase);

		forever begin
			seq_item_port.get_next_item(item);
			@(posedge vin.HCLK);
            wait(vin.HREADYOUT);
            vin.HWRITE = item.HWRITE;
         	vin.HSEL=1'b1;				//Slave select define as 1(slave is connected)
          	vin.HSIZE=3'b001;			//8 bit data transfer
            vin.HTRANS=2'b10;			//NONSEQUENTIAL
            vin.HADDR<=item.HADDR;
			vin.HREADYIN=1'b1;			//ready to take inputs
				

			


		  @(posedge vin.HCLK);
          if(vin.HWRITE)begin		//if HWRITE HIGH
		  	vin.HWDATA<=item.HWDATA;//write opration
		  end
		  else begin
          @(posedge vin.HCLK)
          wait(vin.HREADYOUT);
		  	item.HRDATA<=vin.HRDATA;//read opration
		  end
			seq_item_port.item_done();
			
		end
          
endtask:run_phase
endclass:ahb_driver
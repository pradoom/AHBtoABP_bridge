class apb_driver extends uvm_driver #(apb_seq_item);
`uvm_component_utils(apb_driver)
virtual ahb2apb_interface vin;
apb_seq_item item;
  function new(string name="apb_driver",uvm_component parent=null);
	super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual ahb2apb_interface)::get(this,"","ahb2apb_interface",vin))
	`uvm_fatal(get_type_name(),$sformatf("[APB_DRIVER]: VIN not form"));
  item = apb_seq_item::type_id::create("item",this);
	
endfunction:build_phase


virtual task run_phase(uvm_phase phase);
 
		forever begin
			seq_item_port.get_next_item(item);
		    vin.PSLVERR = 1'b0;
          	vin.PREADY  = 1;
          
		  @(posedge vin.PCLK);
          wait(vin.PSEL);
                if (vin.PWRITE) begin
                          item.PWDATA = vin.PWDATA;
                  @(posedge vin.PCLK);
                  wait(vin.PENABLE);
               end
              else begin
              @(posedge vin.PCLK)
                wait(vin.PENABLE)
                vin.PRDATA  = item.PRDATA;
                end 
                seq_item_port.item_done();
              end
			
endtask:run_phase
endclass:apb_driver
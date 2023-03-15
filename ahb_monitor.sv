class ahb_monitor extends uvm_monitor;
`uvm_component_utils(ahb_monitor)
virtual ahb2apb_interface vin;
uvm_analysis_port #(ahb_seq_item) ahb_mport;

ahb_seq_item item;

function new(string name="ahb_monitor",uvm_component parent);
super.new(name,parent);
ahb_mport=new("ahb_mport",this);
endfunction:new

function void build_phase(uvm_phase phase);
	
	if(!uvm_config_db#(virtual ahb2apb_interface)::get(this,"","ahb2apb_interface",vin))
	`uvm_fatal(get_type_name(),$sformatf("[AHB_MONITOR]: VIN not form"));
	super.build_phase(phase);
endfunction:build_phase
  
    function void connect_phase(uvm_phase phase);
   		super.connect_phase(phase);
  	endfunction

task run_phase(uvm_phase phase);
			phase.raise_objection(this);
                    repeat(`COUNT)begin
				
					item=ahb_seq_item::type_id::create("item");
	
					@(posedge vin.HCLK);
					wait(vin.HREADYOUT);
					item.HADDR=vin.HADDR;
			
					@(posedge vin.HCLK);
					item.HWRITE=vin.HWRITE;
					
					@(posedge vin.HCLK);
					if(vin.HWRITE)begin
						item.HWDATA=vin.HWDATA;
					end
					else begin
                        @(posedge vin.HCLK);
						wait(vin.HREADYOUT);
						item.HRDATA=vin.HRDATA;
					end
					
// 					@(posedge vin.HCLK);
// 					item.HSEL<=vin.HSEL;
// 					item.HSIZE<=vin.HSIZE;
// 					item.HRESP<=vin.HRESP;
					
					ahb_mport.write(item);
					
				end
			phase.drop_objection(this);
			
endtask:run_phase

endclass:ahb_monitor
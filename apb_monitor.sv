class apb_monitor extends uvm_monitor;
`uvm_component_utils(apb_monitor)
virtual ahb2apb_interface vin;
uvm_analysis_port #(apb_seq_item) apb_mport;

apb_seq_item item;

function new(string name="apb_monitor",uvm_component parent);
super.new(name,parent);
apb_mport=new("apb_mport",this);
endfunction:new

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual ahb2apb_interface)::get(this,"","ahb2apb_interface",vin))
	`uvm_fatal(get_type_name(),$sformatf("[APB_MONITOR]: VIN not form"));
	
endfunction:build_phase
  
function void connect_phase(uvm_phase phase);
   		super.connect_phase(phase);
endfunction

virtual task run_phase(uvm_phase phase);
			phase.raise_objection(this);
				repeat(`COUNT)begin
				
					item=apb_seq_item::type_id::create("item");
					@(posedge vin.PCLK);
                    @(posedge vin.PCLK);
                    wait(vin.PSEL);
                    @(posedge vin.PCLK);
					item.PADDR = vin.PADDR;
					item.PWRITE = vin.PWRITE;
                    if (vin.PWRITE) begin
                     wait(vin.PSEL);
                        item.PWDATA  = vin.PWDATA;
                        @(posedge vin.PCLK);
                        wait(vin.PENABLE);
                    end
                    else begin
                        @(posedge vin.PCLK);
                        wait(vin.PENABLE);
                        item.PRDATA  = vin.PRDATA;
                    end			        

					apb_mport.write(item);
					
				end
			phase.drop_objection(this);
			
endtask:run_phase

endclass
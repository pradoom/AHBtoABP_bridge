class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard)
uvm_tlm_analysis_fifo #(ahb_seq_item)ahb;
uvm_tlm_analysis_fifo #(apb_seq_item)apb;

//QUEUE to store recived data
ahb_seq_item ahb_q[$];
apb_seq_item apb_q[$];

ahb_seq_item ahb_o;
apb_seq_item apb_o;

function new(string name="scoreboard",uvm_component parent);
	super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb=new("ahb",this);
apb=new("apb",this);
endfunction:build_phase


task run_phase(uvm_phase phase);
	fork
		begin
			repeat(`COUNT)begin
			ahb.get(ahb_o);
			ahb_q.push_back(ahb_o);

			end
		end
		
		begin
			repeat(`COUNT)begin
			apb.get(apb_o);
			apb_q.push_back(apb_o);
			
			end
		end
		
		join
					repeat(`COUNT)begin
					ahb_o=ahb_q.pop_front();
					apb_o=apb_q.pop_front();
					comp(ahb_o,apb_o);
					end
endtask
			
//`uvm_info(get_type_name(),$sformatf("[SCOREBOARD]:AHB_DATA and APB_DATA RECIVED"),UVM_LOW)

function void comp(ahb_seq_item ahb_o,apb_seq_item apb_o);
  if(ahb_o.HWRITE)begin
	

    if(ahb_o.HWDATA==apb_o.PWDATA)
     
      `uvm_info("[SCOREBOARD]:",$sformatf("WRITE_DATA_MATCH  HWDATA:%0d === PWDATA:%0d",ahb_o.HWDATA,apb_o.PWDATA),UVM_NONE)
	
	  else 
      	`uvm_error("[SCOREBOARD]:",$sformatf("DATA_NOT_MATCH  HWDATA:%0d =X= PWDATA:%0d",ahb_o.HWDATA,apb_o.PWDATA))
	  end

	  else begin
      if(ahb_o.HRDATA==apb_o.PRDATA)
     	 `uvm_info("[SCOREBOARD]:",$sformatf("[SCOREBOARD]:READ_DATA_MATCH  HWDATA:%0d === PWDATA:%0d",ahb_o.HRDATA,apb_o.PRDATA),UVM_NONE)
	
	  else
     	`uvm_error("[SCOREBOARD]:",$sformatf("[SCOREBOARD]:READ_DATA_NOT_MATCH  HWDATA:%0d =X= PWDATA:%0d",ahb_o.HRDATA,apb_o.PRDATA))
      end
                  
				
				
      if(ahb_o.HADDR==apb_o.PADDR)
      	`uvm_info("[SCOREBOARD]:",$sformatf("[SCOREBOARD]:ADDRESS_MATCH  HWDATA:%0d =X= PWDATA:%0d",ahb_o.HADDR,apb_o.PADDR),UVM_NONE)
	  else
      	`uvm_error("[SCOREBOARD]:",$sformatf("[SCOREBOARD]:ADDRESS_NOT_MATCH  HWDATA:%0d =X= PWDATA:%0d",ahb_o.HADDR,apb_o.PADDR))
	 
		
		
endfunction:comp
endclass:scoreboard
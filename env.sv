`include "ahb_agent.sv"
`include "apb_agent.sv"
`include "scoreboard.sv"
class env extends uvm_env;
`uvm_component_utils(env)
ahb_agent ahb_ag;
apb_agent apb_ag;
scoreboard scor;
  
  
function new(string name="env",uvm_component parent);
	super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  
ahb_ag=ahb_agent::type_id::create("ahb_ag",this);
apb_ag=apb_agent::type_id::create("apb_ag",this);
scor=scoreboard::type_id::create("scor",this);
endfunction:build_phase

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	
	ahb_ag.ahb_mo.ahb_mport.connect(scor.ahb.analysis_export);
	apb_ag.apb_mo.apb_mport.connect(scor.apb.analysis_export);
endfunction

endclass:env
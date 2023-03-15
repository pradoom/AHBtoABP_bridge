`include "ahb_seq_item.sv"
`include "ahb_sequence.sv"
`include "ahb_driver.sv"
`include "ahb_sequencer.sv"
`include "ahb_monitor.sv"
class ahb_agent extends uvm_agent;
  `uvm_component_utils(ahb_agent)
   ahb_driver ahb_dr;
   ahb_sequencer ahb_seqr;
   ahb_monitor ahb_mo;



function new(string name="ahb_agent",uvm_component parent);
	super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	ahb_dr=ahb_driver::type_id::create("ahb_dr",this);
	ahb_seqr=ahb_sequencer::type_id::create("ahb_seqr",this);
	ahb_mo=ahb_monitor::type_id::create("ahb_mo",this);
endfunction:build_phase

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	ahb_dr.seq_item_port.connect(ahb_seqr.seq_item_export);
endfunction:connect_phase

endclass:ahb_agent
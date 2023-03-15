
`include "apb_seq_item.sv"
`include "apb_sequence.sv"
`include "apb_driver.sv"
`include "apb_sequencer.sv"
`include "apb_monitor.sv"

class apb_agent extends uvm_agent;

`uvm_component_utils(apb_agent)

function new(string name="apb_agent",uvm_component parent=null);
	super.new(name,parent);
endfunction:new

apb_driver apb_dr;
apb_sequencer apb_seqr;
apb_monitor apb_mo;

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	apb_dr=apb_driver::type_id::create("apb_dr",this);
	apb_seqr=apb_sequencer::type_id::create("apb_seqr",this);
	apb_mo=apb_monitor::type_id::create("apb_mo",this);
endfunction:build_phase

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	apb_dr.seq_item_port.connect(apb_seqr.seq_item_export);
endfunction:connect_phase

endclass
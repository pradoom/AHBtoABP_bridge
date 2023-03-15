
`include "env.sv"
class test extends uvm_test;
`uvm_component_utils(test)
env enver;
ahb_sequence ahb_seq;
apb_sequence apb_seq;

function new(string name="test",uvm_component parent);
	super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
  enver=env::type_id::create("enver",this);

endfunction:build_phase

virtual task run_phase(uvm_phase phase);
  	phase.raise_objection(this);
  
 	 ahb_seq=ahb_sequence::type_id::create("ahb_seq",this);
 	 apb_seq=apb_sequence::type_id::create("apb_seq",this);
  
 	 fork
		ahb_seq.start(enver.ahb_ag.ahb_seqr);
		apb_seq.start(enver.apb_ag.apb_seqr);
  	 join
  	phase.drop_objection(this);
  
`uvm_info(get_type_name, "End of testcase", UVM_LOW);
endtask:run_phase
  
  function void end_of_elaboration();
    print();
  endfunction:end_of_elaboration
endclass:test


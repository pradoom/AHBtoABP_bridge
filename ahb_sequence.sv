class ahb_sequence extends uvm_sequence#(ahb_seq_item);
ahb_seq_item item;
`uvm_object_utils(ahb_sequence)

function new(string name="ahb_sequence");
	super.new(name);
endfunction:new

  task body;
    repeat (`COUNT)begin
	item=ahb_seq_item::type_id::create("item");
 	//start_item(item);
 	//item.randomize();
 	//finish_item(item);
      `uvm_do(item)
	end
	`uvm_info(get_type_name,"Item generated!!",UVM_LOW)
endtask:body

endclass:ahb_sequence

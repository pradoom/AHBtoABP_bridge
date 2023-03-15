class apb_sequence extends uvm_sequence#(apb_seq_item);
apb_seq_item item;
`uvm_object_utils(apb_sequence)

function new(string name="apb_sequence");
	super.new(name);
endfunction:new

 task body;
    repeat (`COUNT)begin
	item=apb_seq_item::type_id::create("item");
 	//start_item(item);
 	//item.randomize();
 	//finish_item(item);
     `uvm_do(item)
	end
// 	`uvm_info(get_type_name,"Item generated!!",UVM_LOW)
 endtask:body

endclass:apb_sequence

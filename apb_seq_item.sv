class apb_seq_item extends uvm_sequence_item;
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;


  rand    bit [DATA_WIDTH-1:0]PRDATA;
	 bit PSEL;
	 bit PENABLE;
	 bit PWRITE;
	 bit [(DATA_WIDTH/8)-1:0] PSTRB;
	 bit [ADDR_WIDTH-1:0]PADDR;
	 bit [DATA_WIDTH-1:0]PWDATA;
	 bit PREADY;
	 bit PSLVERR;

	   `uvm_object_utils_begin(apb_seq_item)
			`uvm_field_int(PRDATA,UVM_ALL_ON)
			`uvm_field_int(PSEL,UVM_ALL_ON)
			`uvm_field_int(PENABLE,UVM_ALL_ON)
			`uvm_field_int(PWRITE,UVM_ALL_ON)
			`uvm_field_int(PSTRB,UVM_ALL_ON)
			`uvm_field_int(PADDR,UVM_ALL_ON)
			`uvm_field_int(PWDATA,UVM_ALL_ON)
			`uvm_field_int(PREADY,UVM_ALL_ON)
			`uvm_field_int(PSLVERR,UVM_ALL_ON)
	   `uvm_object_utils_end
	   
	   function new(string name="apb_seq_item");
			super.new(name);
	   endfunction:new

  constraint data_range { PRDATA inside { [1:10]}; }
endclass:apb_seq_item
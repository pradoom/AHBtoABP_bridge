class ahb_seq_item extends uvm_sequence_item;
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  
  rand bit [ADDR_WIDTH-1:0]HADDR;  // input Address port(randomize)(32 bit)
  rand bit [DATA_WIDTH-1:0]HWDATA; // input datain(randomize)(32 bit)
       bit [DATA_WIDTH-1:0]HRDATA; // output Data Read (32 bit)
	   bit HSEL;                   //Slave select (1 bit)
  rand bit HWRITE;                 // 1 for write 0 for read (1 bit)
	   bit [2:0]HSIZE;             // indicate the size of data transfer (3 bit)
	   bit [1:0]HTRANS;			   // indicate the type-of data transfer NONSEQ, SEQ, or IDLE.(2 bit)
	   bit HREADYIN;			   //indicate ready to transfer (1 bit)
	   bit HREADYOUT;              //indicate ready to give output(1 bit)
	   bit HRESP;                  //give responce (1bit)
	   
	  
	   `uvm_object_utils_begin(ahb_seq_item)
			`uvm_field_int(HADDR,UVM_ALL_ON)
			`uvm_field_int(HWDATA,UVM_ALL_ON)
  			`uvm_field_int(HRDATA,UVM_ALL_ON)
            `uvm_field_int(HSEL,UVM_ALL_ON)
			`uvm_field_int(HWRITE,UVM_ALL_ON)
			`uvm_field_int(HSIZE,UVM_ALL_ON)
			`uvm_field_int(HTRANS,UVM_ALL_ON)
			`uvm_field_int(HREADYIN,UVM_ALL_ON)
			`uvm_field_int(HREADYOUT,UVM_ALL_ON)
			`uvm_field_int(HRESP,UVM_ALL_ON)
	   `uvm_object_utils_end
	   
  constraint data_range { HWDATA inside { [1:20]}; }
  constraint addr_range { HADDR inside { [1:20]}; }
	   function new(string name="ahb_seq_item");
			super.new(name);
	   endfunction:new
	   
	     
endclass
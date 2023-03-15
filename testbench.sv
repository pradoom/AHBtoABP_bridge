`include "uvm_macros.svh"
`define COUNT 10
import uvm_pkg::*;
//`include "design.sv"
`include "ahb2apb_interface.sv"
`include "test.sv"

module tb();
    logic HCLK, PCLK;
  ahb2apb_interface vin (PCLK,HCLK);
    
    
AHBLite_APB_Bridge DUT (.HRESETn(vin.HRESETn),.HCLK(HCLK),.HSEL(vin.HSEL),.HADDR(vin.HADDR),.HWDATA(vin.HWDATA),.HWRITE(vin.HWRITE),.HSIZE(vin.HSIZE),.HTRANS(vin.HTRANS),.HREADYIN(vin.HREADYIN),.HREADYOUT(vin.HREADYOUT),.HRDATA(vin.HRDATA),.HRESP(vin.HRESP),.PRESETn(vin.PRESETn),.PCLK(vin.PCLK),.PSEL(vin.PSEL),.PENABLE(vin.PENABLE),.PWRITE(vin.PWRITE),.PSTRB(vin.PSTRB),.PADDR(vin.PADDR),.PWDATA(vin.PWDATA),.PRDATA(vin.PRDATA),.PREADY(vin.PREADY),.PSLVERR(vin.PSLVERR));

//HCLK 
  	initial begin 
     	HCLK = 0;
     	forever begin
      		#5 HCLK = ~HCLK;
    	end 
	end
//PCLK
 	initial begin 
    	PCLK = 0;
    	forever begin
    		#5 PCLK = ~PCLK;
    	end 
	end
// APB RESET
    initial begin 
        vin.PRESETn = 1'b0;
        #20 vin.PRESETn = 1'b1;
    end 
// AHB RESET
    initial begin 
        vin.HRESETn = 1'b0;
        #20 vin.HRESETn = 1'b1;
    end 
  
//START TEST
	initial begin
      run_test("test");
	end

	initial begin
        uvm_config_db#(virtual ahb2apb_interface)::set(uvm_root::get(),"*","ahb2apb_interface",vin);
    end

  
    initial begin
        $dumpfile("dump.vcd");
      	$dumpvars();
    end
  
endmodule

interface ahb2apb_interface(input logic PCLK, HCLK);
    parameter ADDR_WIDTH =32;
    parameter DATA_WIDTH =32;
    
    // AHB Signals
    logic HRESETn, HSEL, HWRITE;
    logic [1:0] HTRANS;
    logic [ADDR_WIDTH-1:0] HADDR;
    logic [DATA_WIDTH-1:0] HWDATA, HRDATA;
    logic [2:0] HSIZE;
    logic HREADYIN, HREADYOUT, HRESP;

    // APB Signals
    logic PRESETn, PSEL, PENABLE, PWRITE, PREADY, PSLVERR;
    logic [ADDR_WIDTH-1:0] PADDR;
    logic [DATA_WIDTH-1:0] PWDATA, PRDATA;
    logic [(DATA_WIDTH/8)-1:0] PSTRB;
  
 endinterface

// Code your design here
 module AHBLite_APB_Bridge #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)
(
//AHB Slave INTERFACE PIN
  input                           HRESETn,//reset the AHB SLAVE
  input                           HCLK,//Main clock
  input                           HSEL,// SLAVE select
  input      [ADDR_WIDTH-1:0]     HADDR,  // 32-bit address input (randomize)
  input      [DATA_WIDTH-1:0]     HWDATA, // 32-bit data input (randomize)
  input                           HWRITE,//1 for write 0 for read
  input      [2:0]                HSIZE,//indicate the size of data transfer
  input      [2:0]                HBURST,//Not used
  input      [3:0]                HPROT,//Not used
  input      [1:0]                HTRANS,//NONSEQUENTIAL, SEQUENTIAL, or IDLE.
  input                           HMASTERLOCK,//Not used
  input                           HREADYIN,//
  output reg                      HREADYOUT,
  output reg [DATA_WIDTH-1:0]     HRDATA,//32 bit data out-put to apb
  output reg                      HRESP,//responce 
//APB INTERFACE PIN
  input                           PRESETn,
  input                           PCLK,
  output reg                      PSEL,
  output reg                      PENABLE,
  output     [2:0]                PPROT,//not used
  output reg                      PWRITE,//1 for write 0 for read
  output reg [(DATA_WIDTH/8)-1:0] PSTRB,//?
  output reg [ADDR_WIDTH-1:0]     PADDR,//address
  output reg [DATA_WIDTH-1:0]     PWDATA,//data travels from the bridge to the peripherals
  input      [DATA_WIDTH-1:0]     PRDATA,//data travels from the peripherals to the bridge
  input                           PREADY,
  input                           PSLVERR//?
);

parameter ST_AHB_IDLE     = 2'b00,
          ST_AHB_TRANSFER = 2'b01,
          ST_AHB_ERROR    = 2'b10;

reg  [1:0]            ahb_state;
wire                  ahb_transfer;
reg                   apb_treq;
reg                   apb_treq_toggle;
reg  [2:0]            apb_treq_sync;
wire                  apb_treq_pulse;

reg                   apb_tack;
reg                   apb_tack_toggle;
reg  [2:0]            apb_tack_sync;
wire                  apb_tack_pulse;
reg                   apb_tack_pulse_Q1;
reg  [ADDR_WIDTH-1:0] ahb_HADDR;
reg                   ahb_HWRITE;
reg  [2:0]            ahb_HSIZE;
reg  [DATA_WIDTH-1:0] ahb_HWDATA;
reg                   latch_HWDATA;
reg  [DATA_WIDTH-1:0] apb_PRDATA;
reg                   apb_PSLVERR;
reg  [DATA_WIDTH-1:0] apb_PRDATA_HCLK;
reg                   apb_PSLVERR_HCLK;

assign ahb_transfer = (HSEL & HREADYIN & (HTRANS == 2'b10 || HTRANS == 2'b11)) ? 1'b1 : 1'b0;

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin     //reseting the Ahb siginals
    HREADYOUT  <= 1'b1;  //output signal to 1;
    HRESP      <= 1'b0;  //--            to 0;
    HRDATA     <=  'd0;  //--            to 0;
    ahb_HADDR  <=  'd0;   // internal reg to 0; 
    ahb_HWRITE <= 1'b0;   // --
    ahb_HSIZE  <=  'd0;   // --
    ahb_state  <= ST_AHB_IDLE;  // making ahb_state ==00;
    apb_treq   <= 1'b0; // --
  end else begin
    apb_treq   <= 1'b0; //internal register of apb to 0;
    case (ahb_state)
      ST_AHB_IDLE : begin    // ahb_state==00
        HREADYOUT  <= 1'b1;  
        HRESP      <= 1'b0;
        ahb_HADDR  <= HADDR;  // 32-bit input HADDR is assigning to internal register 32-bit ahb_HADDr
        ahb_HWRITE <= HWRITE;  // 1-bit input to internal register
        ahb_HSIZE  <= HSIZE;   // 3-bit input to internal register
        if(ahb_transfer)begin    // ahb_transfer depends up on the HSEL,HREADYIN,HTRANS which all are input signals;
          ahb_state <= ST_AHB_TRANSFER;  // making ahb_state to 01;
          HREADYOUT <= 1'b0;   // output signal to 0;
          apb_treq  <= 1'b1;   // internal reg to 1;
        end
      end
      ST_AHB_TRANSFER : begin   // ahb_state==01;
        HREADYOUT <= 1'b0;      // output signal to 0;
        if(apb_tack_pulse_Q1)begin  // internal apb reg 
          HRDATA <= apb_PRDATA_HCLK;  //32-bit internal apb reg is assigned to 32-bit output signal;
          if(apb_PSLVERR_HCLK)begin  // apb slave error register
            HRESP     <= 1'b1;       // output signal to make 1;
            ahb_state <= ST_AHB_ERROR; // making ahb state to 10;
          end else begin
            HREADYOUT <= 1'b1;  // out-put signal to 1;
            HRESP     <= 1'b0;  // out-put signal to 0;
            ahb_state <= ST_AHB_IDLE; // making ahb state to 00;
          end
        end
      end
      ST_AHB_ERROR : begin  // ahb_state==10
        HREADYOUT <= 1'b1;  // output signal to 1;
        ahb_state <= ST_AHB_IDLE; //making ahb_state to 00;
      end
      default: begin
        ahb_state <= ST_AHB_IDLE; // by default ahb_state==00;
      end
    endcase
  end
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin  
    ahb_HWDATA   <=  'd0;  // internal 32-bit register to 0;
    latch_HWDATA <= 1'b0;  // internal reg to 0;
  end else begin
    if(ahb_transfer && HWRITE) latch_HWDATA <= 1'b1;  //internal ahb_transfer reg and input Hwrite are 1, latch=1;
    else                       latch_HWDATA <= 1'b0;  // else 0;
    if(latch_HWDATA)begin 
      ahb_HWDATA <= HWDATA;// assigning 32-bit input signal to internal register;
    end 
  end
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    apb_treq_toggle <= 1'b0;
  end else begin
    if(apb_treq) apb_treq_toggle <= ~apb_treq_toggle; // always toggling the internal apb register when apb_trq==1
  end
end

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
     apb_treq_sync  <=  'd0; // apb internal 3-bit reg to 1 when active low preset is applied
  end else begin
    apb_treq_sync <= {apb_treq_sync[1:0], apb_treq_toggle}; // shifting and adding lsb of toggle reg to apb sync;
  end
end

  assign apb_treq_pulse = apb_treq_sync[2] ^ apb_treq_sync[1]; // xor operation of treq_sync[2]and[1] to trq_pulse


reg                   apb_treq_pulse_Q1;
reg  [ADDR_WIDTH-1:0] ahb_HADDR_PCLK;
reg                   ahb_HWRITE_PCLK;
reg  [2:0]            ahb_HSIZE_PCLK;
reg  [DATA_WIDTH-1:0] ahb_HWDATA_PCLK;

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
    apb_treq_pulse_Q1 <= 0;
    ahb_HADDR_PCLK    <= 0;
    ahb_HWRITE_PCLK   <= 0;
    ahb_HSIZE_PCLK    <= 0;
    ahb_HWDATA_PCLK   <= 0;
  end else begin
    apb_treq_pulse_Q1 <= apb_treq_pulse;
    if(apb_treq_pulse)begin
      ahb_HADDR_PCLK  <= ahb_HADDR;
      ahb_HWRITE_PCLK <= ahb_HWRITE;
      ahb_HSIZE_PCLK  <= ahb_HSIZE;
      ahb_HWDATA_PCLK <= ahb_HWDATA;
    end
  end
end


reg [(DATA_WIDTH/8)-1:0] lcl_PSTRB;

reg [1:0] apb_state;
parameter ST_APB_IDLE   = 2'b00,
          ST_APB_START  = 2'b01,
          ST_APB_ACCESS = 2'b10;

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
    apb_state   <= ST_APB_IDLE;
    PADDR       <=  'd0;
    PSEL        <=  'b0;
    PENABLE     <=  'b0;
    PWRITE      <=  'b0;
    PWDATA      <=  'b0;
    PSTRB       <=  'd0;
    apb_PSLVERR <= 1'b0;
    apb_tack    <= 1'b0;
    apb_PRDATA  <=  'd0;
  end else begin
    apb_tack    <= 1'b0;
    case (apb_state)
      ST_APB_IDLE: begin
        PSEL    <= 'b0;
        PENABLE <= 'b0;
        PWRITE  <= 'b0;
        if(apb_treq_pulse_Q1)begin
          apb_state <= ST_APB_START;
          PADDR     <= {ahb_HADDR_PCLK[ADDR_WIDTH-1:DATA_WIDTH/8], {{(DATA_WIDTH/8)}{1'b0}}};
          PSTRB     <= lcl_PSTRB;
          PSEL      <= 'b1;
          PWRITE    <= ahb_HWRITE_PCLK;
          PWDATA    <= ahb_HWDATA_PCLK;
        end
      end

      ST_APB_START: begin
        apb_state <= ST_APB_ACCESS;
        PSEL      <= 'b1;
        PENABLE   <= 'b1;
      end

      ST_APB_ACCESS: begin
        PENABLE <= PENABLE;
        PWRITE  <= PWRITE;
        if(PREADY)begin
          apb_state   <= ST_APB_IDLE;
          apb_tack    <= 1'b1;
          apb_PRDATA  <= PRDATA;
          PSEL        <= 'b0;
          PENABLE     <= 'b0;
          apb_PSLVERR <= PSLVERR;
        end
      end
    endcase
  end
end

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
    apb_tack_toggle <= 1'b0;
  end else begin
    if(apb_tack) apb_tack_toggle <= ~apb_tack_toggle;
  end
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    apb_tack_sync <= 'd0;
  end else begin
    apb_tack_sync <= {apb_tack_sync[1:0], apb_tack_toggle};
  end
end

assign apb_tack_pulse = apb_tack_sync[2] ^ apb_tack_sync[1];


always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    apb_tack_pulse_Q1 <= 0;
    apb_PRDATA_HCLK   <= 0;
    apb_PSLVERR_HCLK  <= 0;
  end else begin
    apb_tack_pulse_Q1 <= apb_tack_pulse;
    if(apb_tack_pulse)begin
      apb_PRDATA_HCLK  <= apb_PRDATA;
      apb_PSLVERR_HCLK <= apb_PSLVERR;
    end
  end
end

reg [127:0] pstrb;
reg [6:0]   addr_mask;
always@(*)begin
  case(DATA_WIDTH/8)
    'd0: addr_mask <= 'h00;
    'd1: addr_mask <= 'h01;
    'd2: addr_mask <= 'h03;
    'd3: addr_mask <= 'h07;
    'd4: addr_mask <= 'h0f;
    'd5: addr_mask <= 'h1f;
    'd6: addr_mask <= 'h3f;
    'd7: addr_mask <= 'h7f;
  endcase

  case(ahb_HSIZE)
    'd1:     pstrb <= 'h3;
    'd2:     pstrb <= 'hf;
    'd3:     pstrb <= 'hff;
    'd4:     pstrb <= 'hffff;
    'd5:     pstrb <= 'hffff_ffff;
    'd6:     pstrb <= 'hffff_ffff_ffff_ffff;
    'd7:     pstrb <= 'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
    default: pstrb <= 'h1;
  endcase
end


always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    lcl_PSTRB <= 0;
  end else begin
    lcl_PSTRB <= pstrb[DATA_WIDTH/8-1:0] << (ahb_HADDR & addr_mask);
  end
end

endmodule



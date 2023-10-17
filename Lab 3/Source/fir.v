module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
    // AXI4-Lite 
    // Synchronous write tap parameters

    output  wire                     awready,   // aw_ready : Fir is ready for accepting "WRITE" address. (write address request)
    input   wire                     awvalid,   // aw_valid : The "WRITE" address is valid. (input of fir)
    input   wire [(pADDR_WIDTH-1):0] awaddr,    // aw_addr  : Address to be "WRITTEN".
    output  wire                     wready,    // w_ready  : Fir is ready for accepting "WRITE" data. (write data request)
    input   wire                     wvalid,    // w_valid  : The "WRITE" data is valid.
    input   wire  [(pDATA_WIDTH-1):0] wdata,     // w_data   : Data to be "WRITTEN".
    
    // AXI4-Lite 
    // Synchronous read tap parameters
    
    output  wire                     arready,   // ar_ready : Fir is ready for accepting "READ" address. (write address request)
    input   wire                     arvalid,   // ar_valid : The "READ" address is valid. (input of fir)
    input   wire [(pADDR_WIDTH-1):0] araddr,    // ar_addr  : Address to be "READ".
    input   wire                     rready,    // r_ready  : Testbench is ready to accept "READ" data. (read data request)
    output  wire                     rvalid,    // r_valid  : The "READ" data is valid.
    output  wire  [(pDATA_WIDTH-1):0] rdata,     // r_data   : Data to be "READ".
    
    // AXI4-Stream
    // Stream Slave : Send data to FIR
    
    output  wire                     ss_tready,  // ss_tready : Fir is ready for accepting input data.
    input   wire                     ss_tvalid,  // ss_tvalid : Data from testbench is valid.
    input   wire [(pDATA_WIDTH-1):0] ss_tdata,   // ss_tdata  : Data input.
    input   wire                     ss_tlast,   // ss_tlast  : Signal of last input data.
    
    // AXI4-Stream
    // Stream Master : Send data back to Testbench
    
    input   wire                     sm_tready,  // sm_tready : Testbench is ready for accepting output data.
    output  wire                     sm_tvalid,  // sm_tvalid : Data from fir is valid.
    output  wire [(pDATA_WIDTH-1):0] sm_tdata,   // sm_tdata  : Data output.
    output  wire                     sm_tlast,   // sm_tlast  : Signal of last output data.
    
    // Bram for tap RAM
    
    output  wire [3:0]               tap_WE,     // tap_WE : Write data command of Tap RAM.
    output  wire                     tap_EN,     // tap_EN : Enable of write / read function of Tap RAM.
    output  wire [(pDATA_WIDTH-1):0] tap_Di,     // tap_Di : Input of Tap RAM. (Tap parameter)
    output  wire [(pADDR_WIDTH-1):0] tap_A,      // tap_A  : Command address of Tap RAM.
    input   wire [(pDATA_WIDTH-1):0] tap_Do,     // tap_Do : Output of Tap RAM. (Tap parameter)

    // Bram for data RAM
    
    output  wire [3:0]               data_WE,    // data_WE : Write data command of Data RAM.
    output  wire                     data_EN,    // data_EN : Enable of write / read function of Data RAM.
    output  wire [(pDATA_WIDTH-1):0] data_Di,    // data_Di : Input of Data RAM. (Input Data)
    output  wire [(pADDR_WIDTH-1):0] data_A,     // data_A  : Command address of Data RAM.
    input   wire [(pDATA_WIDTH-1):0] data_Do,    // data_Do : Output of Data RAM. (Input Data)

    input   wire                     axis_clk,   // Clock source.
    input   wire                     axis_rst_n  // Global reset source, active low.
);
    
    axilite AXILITE(
        .awready(awready),
        .wready(wready),
        .awvalid(awvalid),
        .awaddr(awaddr),
        .wvalid(wvalid),
        .wdata(wdata),
        .arready(arready),
        .rready(rready),
        .arvalid(arvalid),
        .araddr(araddr),
        .rvalid(rvalid),
        .rdata(rdata),
        .tap_WE(tap_WE),
        .tap_EN(tap_EN),
        .tap_Di(tap_Di),
        .tap_A(tap_A),
        .tap_Do(tap_Do),
        .axis_clk(axis_clk),
        .axis_rst_n(axis_rst_n));

    
	
endmodule
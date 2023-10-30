`timescale 1ns / 1ps
module fir // 剩tap Ram address
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
    input   wire                     axis_rst_n,  // Global reset source, active low.

    // /*
    output reg [2:0] state,
    output reg [3:0] Tap_addr,
    output reg [3:0] Data_addr,
    output reg [3:0] Write_addr,
    output reg [3:0] counter
    // */
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
        .ap_start(ap_start),
        .ap_idle(ap_idle),
        .ap_done(ap_done),
        .data_length(data_length),
        .fir_raddr(Tap_addr),
        .axis_clk(axis_clk),
        .axis_rst_n(axis_rst_n),
        .sm_tlast(sm_tlast));

        calc_pipeline calculate(
            .data_Do(data_Do),
            .tap_Do(tap_Do),
            .Data_control(DD_output_control),
            .Tape_control(TD_output_control),
            .adder_rst_control(adder_rst_control),
            .output_control(output_control),
            .axis_clk(axis_clk),
            .axis_rst_n(axis_rst_n),
            .sm_tdata(sm_tdata),
            .cal_rst_n(cal_rst_n));

    localparam  RESET = 3'd0, INIT = 3'd1, IDLE = 3'd2, WAIT = 3'd3, 
                CALC = 3'd4, LAST = 3'd5, DONE = 3'd6;
    /*
    reg [2:0] state, next_state;
    reg [3:0] Tap_addr, next_Tap_addr;
    reg [3:0] Data_addr, next_Data_addr;
    reg [3:0] Write_addr, next_Write_addr;
    reg [3:0] counter, next_counter;
    */

    // /*
    reg [2:0] next_state;
    reg [3:0] next_Tap_addr;
    reg [3:0] next_Data_addr;
    reg [3:0] next_Write_addr;
    reg [3:0] next_counter;
    // */

    reg [(pDATA_WIDTH-1):0] data_Di_reg;
    reg [3:0]               addr_reg;

    wire                    TD_output_control;
    wire                    DD_output_control;
    wire                    adder_rst_control;
    wire                    output_control;

    wire                     ap_start;
    wire                     ap_idle;
    wire                     ap_done;
    wire [3:0]               addr;
    wire [(pDATA_WIDTH-1):0] data_length;
    wire                     cal_rst;

    assign ap_idle = (state==WAIT | state==CALC | state==LAST) ? 0 : 1;
    assign ap_done = (state==DONE) ? 1 : 0;
    assign ss_tready = (state==WAIT) ? 1 : 0;
    assign sm_tvalid = (counter==14) ? 1 : 0; // 15
    assign sm_tlast = (state==LAST & counter==14) ? 1 : 0; // 15
    assign data_WE = (state==WAIT | state==INIT) ? 4'b1111 : 4'b0;
    assign data_EN = 1;
    assign data_Di = data_Di_reg;
    assign cal_rst_n = (state==IDLE) ? 0 : 1;

    assign TD_output_control = (counter==11) ? 1 : 0; // 12
    assign DD_output_control = (counter==11) ? 1 : 0; // 12
    assign adder_rst_control = (state==INIT | counter==14) ? 1 : 0;
    assign output_control = (counter==14) ? 1 : 0;
    
    assign addr = addr_reg;
    assign data_A = {6'b0, addr, 2'b0};

    always @(posedge axis_clk or negedge axis_rst_n) begin
		if (!axis_rst_n) begin
			state <= RESET;
		end
		else begin
			state <= next_state;
		end
	end
	
    always @(*) begin 
        case (state)
            RESET: begin 
                next_state = INIT;
            end
            INIT: begin 
                if(Write_addr == 10) begin 
                    next_state = IDLE;
                end
                else begin 
                    next_state = INIT;
                end
            end
            IDLE: begin 
                if (ap_start) begin 
                    next_state = WAIT;
                end
                else begin 
                    next_state = IDLE;
                end
            end
            WAIT: begin 
                if (ss_tlast) begin 
                    next_state = LAST;
                end
                else begin 
                    next_state = CALC;
                end
            end
            CALC: begin 
                if (Tap_addr == 10) begin 
                    next_state = WAIT;
                end
                else begin 
                    next_state = CALC;
                end
            end
            LAST: begin 
                if (sm_tlast) begin 
                    next_state = DONE;
                end
                else begin 
                    next_state = LAST;
                end
            end
            DONE: begin 
                next_state = INIT;
            end
            default: begin 
                next_state = RESET;
            end
        endcase
    end

    always @(posedge axis_clk or negedge axis_rst_n) begin 
        if(!axis_rst_n) begin 
            Tap_addr   <= 0;
            Data_addr  <= 0;
            Write_addr <= 0;
            counter <= 0;
        end
        else begin 
            Tap_addr   <= next_Tap_addr;
            Data_addr  <= next_Data_addr;
            Write_addr <= next_Write_addr;
            counter    <= next_counter;
        end
    end

    always @(*) begin 
        case (state)
            RESET: begin 
                next_Tap_addr = 0;
            end
            INIT: begin 
                next_Tap_addr = 0;
            end
            IDLE: begin 
                next_Tap_addr = 0;
            end
            WAIT: begin 
                next_Tap_addr = 0;
            end
            CALC: begin 
                if (Tap_addr == 10) begin 
                    next_Tap_addr = 0;
                end
                else begin 
                    next_Tap_addr = Tap_addr + 1;
                end
            end
            LAST: begin 
                if (Tap_addr == 10) begin 
                    next_Tap_addr = 0;
                end
                else begin 
                    next_Tap_addr = Tap_addr + 1;
                end
            end
            DONE: begin 
                next_Tap_addr = 0;
            end
        endcase
    end

    always @(*) begin 
        case (state)
            RESET: begin 
                next_Data_addr = 0;
            end
            INIT: begin 
                next_Data_addr = 0;
            end
            IDLE: begin 
                next_Data_addr = 0;
            end
            WAIT: begin 
                next_Data_addr = Write_addr;
            end
            CALC: begin 
                if (Data_addr == 0) begin 
                    next_Data_addr = 10;
                end
                else begin 
                    next_Data_addr = Data_addr -1;
                end
            end
            LAST: begin 
                if (Data_addr == 0) begin 
                    next_Data_addr = 10;
                end
                else begin 
                    next_Data_addr = Data_addr -1;
                end
            end
            DONE: begin 
                next_Data_addr = 0;
            end
        endcase
    end

    always @(*) begin 
        case (state)
            RESET: begin 
                next_Write_addr = 0;
            end
            INIT: begin 
                if (Write_addr == 10) begin 
                    next_Write_addr = 0;
                end
                else begin
                    next_Write_addr = Write_addr + 1;
                end
            end
            IDLE: begin 
                next_Write_addr = 0;
            end
            WAIT: begin 
                if (Write_addr == 10) begin 
                    next_Write_addr = 0;
                end
                else begin
                    next_Write_addr = Write_addr + 1;
                end
            end
            CALC: begin 
                next_Write_addr = Write_addr;
            end
            LAST: begin 
                next_Write_addr = Write_addr;
            end
            DONE: begin 
                next_Write_addr = 0;
            end
        endcase
    end

    always @(*) begin 
        case (state)
            RESET: begin 
                next_counter = 0;
            end
            INIT: begin 
                next_counter = 0;
            end
            IDLE: begin 
                next_counter = 0;
            end
            WAIT: begin 
                if (counter == 11) begin
                    next_counter = counter + 1;
                end
                else begin 
                    next_counter = 0;
                end
            end
            CALC: begin 
                if (counter == 14) begin 
                    next_counter = Tap_addr + 1;
                end
                else begin 
                    next_counter = counter + 1;
                end
            end
            LAST: begin 
                if (counter == 14) begin 
                    next_counter = Tap_addr + 1;
                end
                else begin 
                    next_counter = counter + 1;
                end
            end
            DONE: begin 
                next_counter = 0;
            end
        endcase
    end

    always @(*) begin 
        case (state)
            RESET: begin 
                data_Di_reg = 0;
            end
            INIT: begin 
                data_Di_reg = 0;
            end
            IDLE: begin 
                data_Di_reg = 0;
            end
            WAIT: begin 
                data_Di_reg = ss_tdata;
            end
            CALC: begin 
                data_Di_reg = 0;
            end
            LAST: begin 
                data_Di_reg = 0;
            end
            DONE: begin 
                data_Di_reg = 0;
            end
        endcase
    end

    always @(*) begin 
        case (state)
            RESET: begin 
                addr_reg = 0;
            end
            INIT: begin 
                addr_reg = Write_addr;
            end
            IDLE: begin 
                addr_reg = 0;
            end
            WAIT: begin 
                addr_reg = Write_addr;
            end
            CALC: begin 
                addr_reg = Data_addr;
            end
            LAST: begin 
                addr_reg = Data_addr;
            end
            DONE: begin 
                addr_reg = 0;
            end
        endcase
    end

endmodule

// data address hangs
// ans : wire [3:0]              addr; bits didn't give right

// sm_tdata problem
// que : weird data
// ans : give wrong control signal
/*
    always @(*) begin 
        sm_tdata_reg = (output_control) ? Add_reg : 0;
    end
*/

// que : always 0
// timing control

// sm_tlast also get 1 when sm_tdata is output
// A: assign sm_tlast = (state==LAST | counter==15) ? 1 : 0;
// should be and not or

// initialize fail
// addr should include every state's behavior

// tap_a sometimes get 0 while reading
// 
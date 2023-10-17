module axistream
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11,
    parameter RAM_bit = log2(Tape_Num)
)
(
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  wire                     ss_tready,

    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     en,
    output  wire                     shift,
    output  wire                     wait_ram,

    input   wire                     ap_start,
    input   wire                     ap_done,
    input   wire     [(RAM_bit-1):0] FIR_addr,
    output  wire [(pDATA_WIDTH-1):0] FIR_data,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);

    localparam IDLE  = 2'b00;  // idle state
    localparam FIRST = 2'b01;  // the fisrt few data
    localparam WAIT  = 2'b10;  // Other data

    reg               [1:0] state, next_state;
    reg                     shift_reg;
    reg                     wait_ram_reg;

    reg     [(RAM_bit-1):0] write_ptr;
    reg     [(RAM_bit-1):0] next_write_ptr;

    reg               [3:0] data_WE_reg;
    reg                     data_EN_reg;
    reg [(pADDR_WIDTH-1):0] data_A_reg;
    reg [(pDATA_WIDTH-1):0] data_Di_reg;

    assign ssw_hs = ss_tready & ss_tvalid;

    assign data_EN = data_EN_reg;
    assign data_WE = data_WE_reg;
    assign data_Di = data_Di_reg;
    assign data_A  = data_A_reg;
    assign FIR_data  = data_Do;

    assign ss_tready = (ss_tvalid & en);
    assign ssw_hs = ss_tready & ss_tvalid;

    assign shift = shift_reg;
    assign wait_ram = wait_ram_reg;

    // sequential state transition
	always @(posedge axis_clk or negedge axis_rst_n) begin
		if (!axis_rst_n) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end

    // next state logic
    always @(*) begin
        case(state)
            IDLE: begin
                if (ap_start) // Start the axistream 
                    next_state = FIRST;
                else 
                    next_state = IDLE;
            end
            FIRST: begin 
                if (write_ptr == (Tape_Num-1)) // when reach the end of non-overlap data
                    next_state = WAIT;
                else 
                    next_state = FIRST;
            end
            WAIT: begin
                if (ssw_hs) 
                    next_state = WAIT;
                else if (ap_done) // when all data has been calculate
                    next_state = IDLE;
                else 
                    next_state = WAIT;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Data RAM pointer state transition (sequential)
    always @(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            write_ptr <= 0;
        end
        else begin
            write_ptr <= next_write_ptr;
        end
    end

    // Data RAM pointer behavior (combinational)
    always@* begin
        case(state)
            IDLE: begin
                next_write_ptr = 0;
            end
            FIRST: begin
                if (write_ptr == (Tape_Num-1)) 
                    next_write_ptr = 0;
                else 
                    next_write_ptr = write_ptr + 1;
            end

            WAIT: begin
                if (ssw_hs) begin
                    if (write_ptr == (Tape_Num-1)) 
                        next_write_ptr = 0;
                    else 
                        next_write_ptr = write_ptr + 1;                    
                end
                else if (ap_done) 
                    next_write_ptr = 0;
                else 
                    next_write_ptr = write_ptr;
            end

            default: begin
                next_write_ptr = 0;
            end
        endcase
    end

    // Data RAM behavior
    always @(*) begin
        case(state)
            IDLE: begin
                wait_ram_reg = 0;
                data_Di_reg = 0;
                data_A_reg  = 0;
            end

            FIRST: begin
                data_Di_reg = 0;
                data_A_reg  = {6'b0, write_ptr, 2'b00};
                wait_ram_reg = 0;
            end

            WAIT: begin
                wait_ram_reg = 1;
                if (ssw_hs) begin   // when ss ready & valid handshake, data will send to Data RAM
                    data_Di_reg = ss_tdata;
                    data_A_reg  = {6'b0, write_ptr, 2'b00};
                end
                else begin          // else will do the compute
                    data_Di_reg = 0;
                    data_A_reg  = {6'b0, FIR_addr, 2'b00};
                end
            end

            default: begin
                wait_ram_reg = 0;
                data_Di_reg = 0;
                data_A_reg  = 0;
            end
        endcase
    end

    // Data RAM enable behavior
    always @(*) begin
        case(state)
            IDLE: begin
                data_EN_reg = 0;
                data_WE_reg = 4'b0000;
            end

            FIRST: begin
                data_EN_reg = 1;
                data_WE_reg = 4'b1111;
            end

            WAIT: begin
                data_EN_reg = 1;
                if (ssw_hs) 
                    data_WE_reg  = {4{ssw_hs}};
                else 
                    data_WE_reg = 4'b0000;
            end
            default: begin
                data_EN_reg = 0;
                data_WE_reg = 4'b0000;
            end
        endcase
    end

    // shift behavior
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(~axis_rst_n) begin
            shift_reg <= 0;
        end
        else if (ssw_hs) begin
            shift_reg <= 1;
        end
        else begin
            shift_reg <= 0;
        end
    end

    function integer log2;
        input integer x;
        begin 
            for(log2=0; x>0; log2=log2+1)
                x = x >> 1;
        end
    endfunction
endmodule
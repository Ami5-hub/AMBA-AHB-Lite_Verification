`timescale 1ns / 1ps
module ahb_lite_master (
    input wire clk,
    input wire resetn,

    // Request interface for the verification driver
    input wire        req_valid,
    output wire       req_ready,
    input wire        req_write,
    input wire [31:0] req_addr,
    input wire [31:0] req_wdata,

    // Response interface for the verification driver
    output reg        rsp_valid,
    output reg [31:0] rsp_rdata,
    output reg        rsp_error,

    // AHB-Lite bus
    output reg [31:0] HADDR,
    output reg        HWRITE,
    output reg [1:0]  HTRANS,
    output reg [2:0]  HSIZE,
    output reg        HSEL,
    output reg [31:0] HWDATA,

    input wire [31:0] HRDATA,
    input wire        HREADY,
    input wire        HRESP
);

    localparam IDLE = 1'b0;
    localparam DATA = 1'b1;

    reg state;

    reg [31:0] addr_reg;
    reg [31:0] wdata_reg;
    reg        write_reg;

    assign req_ready = (state == IDLE);

    // Address/control phase is presented while a request
    // is available and the master is idle.
    always @(*) begin
        HADDR  = 32'b0;
        HWRITE = 1'b0;
        HTRANS = 2'b00;
        HSIZE  = 3'b010;
        HSEL   = 1'b0;
        HWDATA = 32'b0;

        if (state == IDLE && req_valid) begin
            HADDR  = req_addr;
            HWRITE = req_write;
            HTRANS = 2'b10; // NONSEQ
            HSEL   = 1'b1;
        end

        if (state == DATA && write_reg)
            HWDATA = wdata_reg;
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state     <= IDLE;
            addr_reg  <= 0;
            wdata_reg <= 0;
            write_reg <= 0;
            rsp_valid <= 0;
            rsp_rdata <= 0;
            rsp_error <= 0;
        end else begin
            // Response is a one-cycle pulse.
            rsp_valid <= 0;

            case (state)
                IDLE: begin
                    if (req_valid && req_ready && HREADY) begin
                        addr_reg  <= req_addr;
                        wdata_reg <= req_wdata;
                        write_reg <= req_write;
                        state     <= DATA;
                    end
                end

                DATA: begin
                    if (HREADY) begin
                        rsp_valid <= 1;
                        rsp_error <= HRESP;

                        if (!write_reg)
                            rsp_rdata <= HRDATA;

                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

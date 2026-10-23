`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2026 17:40:57
// Design Name: 
// Module Name: ahb_lite_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ahb_lite_slave (
    input wire clk,
    input wire resetn,

    input wire [31:0] HADDR,
    input wire        HWRITE,
    input wire [1:0]  HTRANS,
    input wire [2:0]  HSIZE,
    input wire        HSEL,
    input wire [31:0] HWDATA,

    output reg [31:0] HRDATA,
    output wire       HREADYOUT,
    output wire       HRESP
);

    reg [31:0] mem [0:15];

    reg [31:0] addr_reg;
    reg        write_reg;
    reg        valid_reg;

    integer i;

    // Starter implementation: no wait states, no errors.
    assign HREADYOUT = 1'b1;
    assign HRESP = 1'b0;

    // Combinational read from the captured address.
    always @(*) begin
        HRDATA = mem[addr_reg[5:2]];
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            addr_reg  <= 0;
            write_reg <= 0;
            valid_reg <= 0;

            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 0;

        end else begin

            // Complete the previous address phase's data phase.
            if (valid_reg && write_reg)
                mem[addr_reg[5:2]] <= HWDATA;

            // Capture the next address phase.
            if (HREADYOUT) begin
                valid_reg <= HSEL && HTRANS[1];

                if (HSEL && HTRANS[1]) begin
                    addr_reg  <= HADDR;
                    write_reg <= HWRITE;
                end
            end
        end
    end

endmodule



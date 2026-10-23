`timescale 1ns / 1ps
interface ahb_if(input logic HCLK);

    logic HRESETn;

    // Driver-to-master request interface
    logic req_valid;
    logic req_ready;
    logic req_write;
    logic [31:0] req_addr;
    logic [31:0] req_wdata;

    // Master-to-driver response interface
    logic rsp_valid;
    logic [31:0] rsp_rdata;
    logic rsp_error;

    // AHB-Lite bus
    logic [31:0] HADDR;
    logic HWRITE;
    logic [1:0] HTRANS;
    logic [2:0] HSIZE;
    logic HSEL;
    logic [31:0] HWDATA;

    logic [31:0] HRDATA;
    logic HREADY;
    logic HREADYOUT;
    logic HRESP;

endinterface

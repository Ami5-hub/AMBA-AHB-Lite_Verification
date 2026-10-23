`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2026 17:43:10
// Design Name: 
// Module Name: ahb_driver
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



class ahb_driver;

    virtual ahb_if vif;
    mailbox #(ahb_transaction) gen2drv;

    function new(
        virtual ahb_if vif,
        mailbox #(ahb_transaction) mbx
    );
        this.vif = vif;
        gen2drv = mbx;
    endfunction

    task run();
        ahb_transaction tr;

        forever begin
            gen2drv.get(tr);

            if (tr == null)
                break;

            tr.display("DRIVER");

            // Wait until the master can accept a request.
            @(negedge vif.HCLK);

            while (vif.req_ready !== 1'b1)
                @(negedge vif.HCLK);

            vif.req_addr  = tr.addr;
            vif.req_write = tr.is_write;
            vif.req_wdata = tr.data;
            vif.req_valid = 1'b1;

            // Master accepts the request on the rising edge.
            @(posedge vif.HCLK);
            @(negedge vif.HCLK);
            vif.req_valid = 1'b0;

            // Wait for the master to complete the transfer.
            do begin
                @(posedge vif.HCLK);
            end while (vif.rsp_valid !== 1'b1);

            tr.read_data = vif.rsp_rdata;
            tr.error = vif.rsp_error;

            if (!tr.is_write) begin
                $display(
                    "[%0t] DRIVER: READ RESULT addr=%08h data=%08h",
                    $time, tr.addr, tr.read_data
                );
            end

            if (tr.error)
                $error("DRIVER: AHB response error at address %08h",
                       tr.addr);
        end

        $display("DRIVER: All transactions submitted");
    endtask

endclass

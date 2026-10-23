`timescale 1ns / 1ps
class ahb_monitor;

    virtual ahb_if vif;
    mailbox #(ahb_transaction) mon2scb;

    bit prev_valid;
    bit prev_write;
    bit [31:0] prev_addr;

    function new(
        virtual ahb_if vif,
        mailbox #(ahb_transaction) mbx
    );
        this.vif = vif;
        mon2scb = mbx;
        prev_valid = 0;
    endfunction

    task run();
        ahb_transaction tr;

        forever begin
            @(posedge vif.HCLK);

            if (!vif.HRESETn) begin
                prev_valid = 0;
            end else if (vif.HREADY) begin

                // Observe the data phase of the previous address.
                if (prev_valid) begin
                    tr = new();
                    tr.addr = prev_addr;
                    tr.is_write = prev_write;
                    tr.error = (vif.HRESP !== 1'b0);

                    if (prev_write)
                        tr.data = vif.HWDATA;
                    else
                        tr.read_data = vif.HRDATA;

                    tr.display("MONITOR");
                    mon2scb.put(tr);
                end

                // Capture the current address phase.
                prev_valid =
                    vif.HSEL && vif.HTRANS[1];

                if (prev_valid) begin
                    prev_addr = vif.HADDR;
                    prev_write = vif.HWRITE;
                end
            end
        end
    endtask

endclass

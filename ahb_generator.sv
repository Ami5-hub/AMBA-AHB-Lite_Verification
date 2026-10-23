`timescale 1ns / 1ps
class ahb_generator;

    mailbox #(ahb_transaction) gen2drv;

    function new(mailbox #(ahb_transaction) mbx);
        gen2drv = mbx;
    endfunction

    task run();
        ahb_transaction tr;

        // Deterministic write/read pair to verify known data.
        tr = new();
        tr.is_write = 1;
        tr.addr = 32'h00000008;
        tr.data = 32'hA5A55A5A;
        gen2drv.put(tr);

        tr = new();
        tr.is_write = 0;
        tr.addr = 32'h00000008;
        tr.data = 0;
        gen2drv.put(tr);

        // Additional randomized transactions.
        repeat (18) begin
            tr = new();

            if (!tr.randomize())
                $fatal(1, "Randomization failed");

            gen2drv.put(tr);
        end

        // Null marks the end of generation.
        gen2drv.put(null);
    endtask

endclass

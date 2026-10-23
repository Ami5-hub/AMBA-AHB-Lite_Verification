`timescale 1ns / 1ps
class ahb_test;

    ahb_generator gen;
    ahb_driver drv;

    mailbox #(ahb_transaction) gen2drv;

    function new(virtual ahb_if vif);
        gen2drv = new();

        gen = new(gen2drv);
        drv = new(vif, gen2drv);
    endfunction

    task run();
        $display("==================================");
        $display("AHB-LITE MASTER-SLAVE TEST START");
        $display("==================================");

        fork
            gen.run();
            drv.run();
        join

        $display("AHB-LITE TEST DRIVER COMPLETED");
    endtask

endclass

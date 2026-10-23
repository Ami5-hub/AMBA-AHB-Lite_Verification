
`timescale 1ns/1ps

module tb_top;

    import ahb_pkg::*;

    logic HCLK = 0;
    always #5 HCLK = ~HCLK;

    ahb_if bus(HCLK);

    // Verilog AHB-Lite Master
    ahb_lite_master master (
        .clk       (HCLK),
        .resetn    (bus.HRESETn),

        .req_valid (bus.req_valid),
        .req_ready (bus.req_ready),
        .req_write (bus.req_write),
        .req_addr  (bus.req_addr),
        .req_wdata (bus.req_wdata),

        .rsp_valid (bus.rsp_valid),
        .rsp_rdata (bus.rsp_rdata),
        .rsp_error (bus.rsp_error),

        .HADDR     (bus.HADDR),
        .HWRITE    (bus.HWRITE),
        .HTRANS    (bus.HTRANS),
        .HSIZE     (bus.HSIZE),
        .HSEL      (bus.HSEL),
        .HWDATA    (bus.HWDATA),

        .HRDATA    (bus.HRDATA),
        .HREADY    (bus.HREADY),
        .HRESP     (bus.HRESP)
    );

    // Verilog AHB-Lite Slave
    ahb_lite_slave slave (
        .clk       (HCLK),
        .resetn    (bus.HRESETn),

        .HADDR     (bus.HADDR),
        .HWRITE    (bus.HWRITE),
        .HTRANS    (bus.HTRANS),
        .HSIZE     (bus.HSIZE),
        .HSEL      (bus.HSEL),
        .HWDATA    (bus.HWDATA),

        .HRDATA    (bus.HRDATA),
        .HREADYOUT (bus.HREADYOUT),
        .HRESP     (bus.HRESP)
    );

    // Single-slave AHB-Lite connection.
    assign bus.HREADY = bus.HREADYOUT;

    mailbox #(ahb_transaction) mon2scb;

    ahb_monitor    mon;
    ahb_scoreboard scb;
    ahb_test       test;

    initial begin
        bus.HRESETn  = 0;
        bus.req_valid = 0;
        bus.req_write = 0;
        bus.req_addr  = 0;
        bus.req_wdata = 0;

        mon2scb = new();

        mon = new(bus, mon2scb);
        scb = new(mon2scb);
        test = new(bus);

        // Hold reset for five clock cycles.
        repeat (5) @(negedge HCLK);
        bus.HRESETn = 1;

        // Run monitor and scoreboard continuously.
        fork
            mon.run();
            scb.run();
        join_none

        // Generate and execute all transactions.
        test.run();

        // Allow the final monitored transaction to be checked.
        repeat (5) @(negedge HCLK);

        $display("==================================");
        $display("FINAL AHB-LITE VERIFICATION REPORT");
        $display("READ CHECKS PASSED = %0d", scb.pass_count);
        $display("CHECKS FAILED      = %0d", scb.fail_count);
        $display("==================================");

        if (scb.fail_count == 0 && scb.pass_count > 0)
            $display("TEST RESULT: PASS");
        else
            $display("TEST RESULT: FAIL");

        $finish;
    end

endmodule

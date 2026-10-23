`timescale 1ns / 1ps
class ahb_scoreboard;

    mailbox #(ahb_transaction) mon2scb;

    bit [31:0] expected_mem [0:15];

    int pass_count;
    int fail_count;

    function new(mailbox #(ahb_transaction) mbx);
        mon2scb = mbx;
        pass_count = 0;
        fail_count = 0;

        foreach (expected_mem[i])
            expected_mem[i] = 0;
    endfunction

    task run();
        ahb_transaction tr;
        int index;

        forever begin
            mon2scb.get(tr);

            index = tr.addr[5:2];

            if (tr.error) begin
                fail_count++;
                $error("SCOREBOARD: Unexpected AHB error at %08h",
                       tr.addr);
            end else if (tr.is_write) begin
                expected_mem[index] = tr.data;

                $display(
                    "[%0t] SCOREBOARD: WRITE addr=%08h data=%08h",
                    $time, tr.addr, tr.data
                );
            end else begin
                if (tr.read_data === expected_mem[index]) begin
                    pass_count++;

                    $display(
                        "[%0t] PASS addr=%08h expected=%08h actual=%08h",
                        $time,
                        tr.addr,
                        expected_mem[index],
                        tr.read_data
                    );
                end else begin
                    fail_count++;

                    $error(
                        "[%0t] FAIL addr=%08h expected=%08h actual=%08h",
                        $time,
                        tr.addr,
                        expected_mem[index],
                        tr.read_data
                    );
                end
            end
        end
    endtask

endclass

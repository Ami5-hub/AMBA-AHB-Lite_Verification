`timescale 1ns / 1ps
class ahb_transaction;

    rand bit is_write;
    rand bit [31:0] addr;
    rand bit [31:0] data;

    bit [31:0] read_data;
    bit error;

    constraint valid_addr {
        addr inside {[32'h00000000:32'h0000003C]};
        addr[1:0] == 2'b00;
    }

    function void display(string tag);
        $display(
            "[%0t] %s: %s addr=%08h data=%08h",
            $time, tag,
            is_write ? "WRITE" : "READ",
            addr, data
        );
    endfunction

endclass

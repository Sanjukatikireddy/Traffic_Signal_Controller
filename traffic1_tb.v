`timescale 1ns/1ps
module traffic1_tb;

reg clk, rst, ped_req, emergency_NS, emergency_EW;
wire [2:0] NS, EW;

traffic1 DUT (
    .clk(clk), .rst(rst), .ped_req(ped_req),
    .emergency_NS(emergency_NS), .emergency_EW(emergency_EW),
    .NS(NS), .EW(EW)
);

always #5 clk = ~clk;

initial
begin
    $dumpfile("traffic1.vcd");
    $dumpvars(0, traffic1_tb);
end

initial
begin
    $display("Time\tRST\tPED\tEM_NS\tEM_EW\tNS\tEW");
    $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b", $time, rst, ped_req, emergency_NS, emergency_EW, NS, EW);
end

// Watch for pedestrian state being serviced
always @(DUT.state)
    if (DUT.state == DUT.S_PED)
        $display(">>> [%0t] Pedestrian crossing state ENTERED <<<", $time);

initial
begin
    clk = 0; rst = 1; ped_req = 0; emergency_NS = 0; emergency_EW = 0;
    #20; rst = 0;

    #50;
    ped_req = 1;     // pulse during NS_GREEN, well before yellow
    #10;
    ped_req = 0;
    #150;            // should see S_PED entered during this window

    #150;
    emergency_NS = 1;
    #60;
    emergency_NS = 0;
    #100;

    emergency_EW = 1;
    #60;
    emergency_EW = 0;
    #100;

    ped_req = 1;     // pulse during EW_GREEN
    #10;
    ped_req = 0;
    #150;

    $display("Simulation completed.");
    $finish;
end

endmodule
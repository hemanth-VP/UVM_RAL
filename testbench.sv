`include "uvm_macros.svh"
import uvm_pkg::*;

`include "interface.sv"
`include "base_test.sv"

//top module
module tb_top;
  bit clk;    //clock and reset signals are generated in testbench class
  bit rst;
  always #2 clk = ~clk;   //clock generation
  
  initial begin
    rst = 0;
    #5; 
    rst = 1;
  end
  
  //passing clock and reset signals to the interface
  sfr_if vif(clk, rst);
  
  //instantiate DUT
  switch DUT(
    .clk(vif.clk),
    .rst(vif.rst),
    .data_in(vif.data_in),
    .valid_in(vif.valid_in),
    .paddr(vif.paddr),
    .psel(vif.psel),
    .pen(vif.pen),
    .p_write(vif.p_write),
    .p_wdata(vif.p_wdata),
    .out_port1(vif.out_port1),
    .out_port2(vif.out_port2),
    .out_port3(vif.out_port3),
    .out_port4(vif.out_port4),
    .valid_out(vif.valid_out),
    .prdata(vif.prdata)
  );
  
  initial begin
    // set interface in config_db
    uvm_config_db#(virtual sfr_if)::set(null, "*", "vif", vif);
    

    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(); 
  end
  
  //star the test class
  initial begin
    run_test("base_test");

  end
endmodule
//interface where all the signals are declared as logic
interface sfr_if(input clk, rst);
 logic data_in;
 logic valid_in;
 logic [31:0]paddr;
 logic [31:0]p_wdata; 
 logic psel;
 logic pen;
 logic p_write;
 logic out_port1;
 logic out_port2;
 logic out_port3;
 logic out_port4;
 logic valid_out;
 logic [31:0]prdata;
  
endinterface

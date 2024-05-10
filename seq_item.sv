//register sequence item class

class seq_item extends uvm_sequence_item;
  
  //declaration of signals
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit rd_or_wr; // rd_or_wr = 0 (Write)
                     // rd_or_wr = 1 (Read)
 rand bit data_in;
  bit valid_in=1;
  


 bit out_port1;
 bit out_port2;
 bit out_port3;
 bit out_port4;
 bit valid_out;
  
 
  rand bit[63:0]packet;   
  bit [63:0]data_in_q[$];   //holds the packet which will be driven to DUT which comes from active monitor
  
  bit [63:0]data_out_q[$];  //holds the packet which is coming from passive monitor
  
    function new(string name = "seq_item");
    super.new(name);
  endfunction

  //factory registration of all the signals
  `uvm_object_utils_begin(seq_item)
    `uvm_field_int(addr,     UVM_ALL_ON)
    `uvm_field_int(data,     UVM_ALL_ON)
    `uvm_field_int(rd_or_wr, UVM_ALL_ON)
  `uvm_object_utils_end
 
  //constraint to get the address of the 3 registers
  constraint addr_c {addr inside {'h0, 'h4, 'h8};}
endclass




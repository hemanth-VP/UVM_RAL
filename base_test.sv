`include "package.sv"

//declare a base test class which is the base class for all the testcases
class base_test extends uvm_test;
  environment env_o;

  //handle of write sequence and register sequences
  write_seq w_h;
  reg_seq r_h;
  
  
  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  //crate the environment, write and register sequences in build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_o = environment::type_id::create("env_o", this);
   
    //create write and read sequence
    w_h = write_seq::type_id::create ("w_h", this);
    r_h = reg_seq::type_id::create ("r_h", this);
    
    
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
     fork
       //start the reg and write sequences on appropriate sequencers
       r_h.start (env_o.agt.seqr);//reg seq
       w_h.start (env_o.wr_agt.wseqr); //write seq
     join
     #1000;
    phase.drop_objection(this);
    
    
    `uvm_info(get_type_name, "End of testcase", UVM_LOW);
  endtask
  
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass



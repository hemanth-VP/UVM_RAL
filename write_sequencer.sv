//write sequencer class for the registers
class write_sequencer extends uvm_sequencer#(seq_item);
  `uvm_component_utils(write_sequencer)

  //class constructor new
  function new(string name = "write_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
 
  //call the build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass
//sequencer class for register
class sequencer extends uvm_sequencer#(seq_item);
  `uvm_component_utils(sequencer)
 
//class constructor new
  function new(string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //call the build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass
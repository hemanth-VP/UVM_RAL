//agent class for registers

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  driver drv;    //driver handle
  sequencer seqr; //sequencer handle
  monitor mon;    //monitor handle

  //class constructor new
  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
  //create driver,sequencer and monitor
      drv = driver::type_id::create("drv", this);
      seqr = sequencer::type_id::create("seqr", this);
    
    mon = monitor::type_id::create("mon", this);
  endfunction

  //connect the driver and sequencer
  function void connect_phase(uvm_phase phase);

      
        drv.seq_item_port.connect(seqr.seq_item_export);
       
  endfunction
endclass
`include "write_agent.sv"
`include "read_agent.sv"
`include "scoreboard.sv"
//environment class

class environment extends uvm_env;
  `uvm_component_utils(environment)
  agent agt;   //register agent class handle
  write_agent wr_agt;  //write agent class handle
  read_agent rd_agt;  //read agent class handle
  scoreboard sc;  //scoreboard handle
  reg_apb_adapter adapter; //adapter class handle
  RegModel_SFR rg; //register model class handle
  uvm_reg_predictor #(seq_item) ral_predictor; //call the reg predictor
  
 
  
   function new(string name = "environment", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //create all the components
    agt = agent::type_id::create("agt", this);
    wr_agt = write_agent::type_id::create("wr_agt", this);
    
    rd_agt = read_agent::type_id::create("rd_agt", this);
    sc = scoreboard::type_id::create("sc",this);
    adapter = reg_apb_adapter::type_id::create("adapter");
    ral_predictor = uvm_reg_predictor #(seq_item) :: type_id:: create("ral_predictor", this);
    
    
      // Create and build the RegModel_SFR instance only if it hasn't been created yet
      rg = RegModel_SFR::type_id::create("rg");
      rg.build();
      rg.lock_model();
     

    
    uvm_config_db#(RegModel_SFR)::set(uvm_root::get(), "*", "rg", rg);
  
  endfunction
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
 
    
    rg.default_map.set_sequencer( .sequencer(agt.seqr), .adapter(adapter) );
    rg.default_map.set_base_addr('h0);   //pass the base address
   ral_predictor.map = rg.default_map; //Assigning map handle
    ral_predictor.adapter = adapter;
    
    
   //connect monitor analysis port to scoreboard implementation port of both read and write agent 
    rd_agt.r_mon.item_collect_port_read.connect(sc.rd_mon_port);
    wr_agt.w_mon.item_collect_port_write.connect(sc.wr_mon_port);
    
    agt.mon.item_collect_port.connect(ral_predictor.bus_in); 
   rg.default_map.set_sequencer(agt.seqr,adapter);
  endfunction
endclass
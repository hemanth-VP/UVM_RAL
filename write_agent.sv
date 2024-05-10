//write sequencer class
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

//.......................................................................................................................................

//write driver class to drive the inputs to DUT
class write_driver extends uvm_driver #(seq_item);
  `uvm_component_utils (write_driver)
 
   seq_item  tr;  //sequence item handle
   virtual sfr_if  vif;  //virtual interface handle
  
  function new (string name = "write_driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     
     //get the virtual interface
     if (!uvm_config_db#(virtual sfr_if)::get(this,"", "vif", vif))
         `uvm_error ("DRIVER", "Did not get bus if handle")
   endfunction
 
   virtual task run_phase (uvm_phase phase);
     seq_item tr = seq_item::type_id::create ("tr");  //create sequence item
      @(posedge vif.clk)
     if(vif.rst==0) 
      vif.valid_in=0;      //if reset=0, valid in should be low.
      forever begin
         @(posedge vif.clk)
        
        //driver handshake
         seq_item_port.get_next_item (tr);
        write(tr.packet,tr.data_in,tr.valid_in);
         seq_item_port.item_done ();
      end
   endtask
 
  //write task
 
     virtual task write ( input bit [63:0] packet,
                         input bit data_in,input bit valid_in);
       foreach(packet[i]) begin
     //drive inputs 
       vif.valid_in <= valid_in;
       vif.data_in <= packet[i];
         
         
      @(posedge vif.clk)
         `uvm_info(get_type_name, $sformatf("[DRIVER WRITE TASK] packet = %0b  data_in = %0b valid_in = %0b rst = %0b", packet[i], vif.data_in,valid_in,vif.rst), UVM_LOW);
       end
       #5;
       vif.valid_in=0;
       
       `uvm_info(get_type_name, $sformatf ("[DRIVER WRITE TASK] Driving to DUT completed"), UVM_LOW);
   endtask
endclass
     
 //..................................................................................................    

 //monitor class
 class write_monitor extends uvm_monitor;
  `uvm_component_utils (write_monitor)
  function new (string name="write_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction

   //analysis port declaration
  uvm_analysis_port #(seq_item)  item_collect_port_write;
  
  virtual sfr_if  vif;
 // bit [63:0] data_in_q[$];
   bit data_in;
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     item_collect_port_write = new ("item_collect_port_write", this);

     if (!uvm_config_db#(virtual sfr_if)::get(this,"", "vif", vif))
        `uvm_error ("BUS MONITOR", "Did not get bus if handle")


   endfunction
 
   virtual task run_phase (uvm_phase phase);
     seq_item tr;
       tr = seq_item::type_id::create("tr");
    // #10;
     forever begin
     @(posedge vif.clk)
       repeat(66) begin
         @(posedge vif.clk)
         if(vif.valid_in==1)  //if valid_in asserted high, push the data_in from virtual interface to data_in_q of sequence item
         tr.data_in_q.push_back(vif.data_in); 
      end
    
       //call the monitor write method
        item_collect_port_write.write(tr);
    
        `uvm_info(get_type_name(), $sformatf("[MONITOR WRITE TASK] @ %0t valid_in = %b data_in = %0b data_in_q = %p size of q = %0d", $time, vif.valid_in, vif.data_in, tr.data_in_q,tr.data_in_q.size()), UVM_LOW);
       #5;
       repeat(65) 
         tr.data_in_q.pop_front();  //pop the data from data_in_q
     
     end
  endtask
endclass
     
//------------------------------------------------------------------------

//write agent class
class write_agent extends uvm_agent;
  `uvm_component_utils(write_agent)
  
  write_monitor w_mon;   //write monitor handle
  write_driver wdrv;     //write driiver handle
  write_sequencer wseqr; //write sequencer handle
  
  
  //class constructor new
  function new(string name = "write_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
   //create driver, sequencer and monitor
    wdrv = write_driver::type_id::create("wdrv", this);
    wseqr = write_sequencer::type_id::create("wseqr", this);
   
    
    w_mon = write_monitor::type_id::create("w_mon", this);
  endfunction
  
   function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
     //connect write driver to the write sequencer
     wdrv.seq_item_port.connect(wseqr.seq_item_export);
    
  endfunction
  
  
endclass
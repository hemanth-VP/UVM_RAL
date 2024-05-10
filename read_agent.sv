//read monitor class which is passive in nature that monitors the output of DUT
class read_monitor extends uvm_monitor;
  `uvm_component_utils (read_monitor)
  function new (string name="read_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction

  //analysis port declaration
  uvm_analysis_port #(seq_item)  item_collect_port_read;
  
  virtual sfr_if  vif;
 // bit [63:0] data_out_q[$];
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     
     //create the memory for analysis port
     item_collect_port_read = new ("item_collect_port_read", this);
     
     //get the virtual interface
     if (!uvm_config_db#(virtual sfr_if)::get(this,"", "vif", vif))
        `uvm_error ("BUS MONITOR", "Did not get bus if handle")


   endfunction
 
     virtual task run_phase (uvm_phase phase);
     
        seq_item tr;
    
     `uvm_info(get_type_name(), $sformatf("[MONITOR READ TASK] @ %0t inside read monitor run phase", $time), UVM_LOW);
    
        forever begin
         
            @(posedge vif.clk);
           // $display("[%0d] valid out = %0b  pr_data = %b", $time, vif.valid_out,vif.prdata[3:0]);
          
          //check if the valid out signal is high to sample the outputs
            if (vif.valid_out) begin
              
                tr = seq_item::type_id::create ("tr");
              
//the output ports depends on the out_port_en register which is assigned to the last 4 bits of prdata
                case (vif.prdata[3:0])
                    4'b0001: begin  //if the register value is 4'b0001 push the out_port1 to data_out_q of sequence item
                      repeat (64) begin
                            @(posedge vif.clk);
                          tr.data_out_q.push_back(vif.out_port1);
                        @(posedge vif.clk);
                        end
                      $display("[%0d] valid out = %0h, data out = %p", $time, vif.valid_out,tr.data_out_q);
                    end
                  4'b0010: begin   //if the register value is 4'b0010 push the out_port2 to data_out_q of sequence item
                    repeat (64) begin
                            @(posedge vif.clk);
                      tr.data_out_q.push_back(vif.out_port2);
                      //@(posedge vif.clk);
                        end
                    $display("[%0d] valid out = %0h, data out = %p", $time, vif.valid_out, tr.data_out_q);
                    end
                  4'b0100: begin  //if the register value is 4'b0100 push the out_port3 to data_out_q of sequence item
                    repeat (64) begin
                            @(posedge vif.clk);
                      tr.data_out_q.push_back(vif.out_port3);
                     // @(posedge vif.clk);
                        end
                    $display("[%0d] valid out = %0h, data out = %p", $time, vif.valid_out, tr.data_out_q);
                    end
                  4'b1000: begin  //if the register value is 4'b1000 push the out_port4 to data_out_q of sequence item
                    repeat (64) begin
                            @(posedge vif.clk);
                      tr.data_out_q.push_back(vif.out_port4);
                     // @(posedge vif.clk);
                        end
                    $display("[%0d] valid out = %0h, data out = %p size = %d", $time, vif.valid_out, tr.data_out_q,tr.data_out_q.size());
                    end
                 
                endcase
              
              //call the monitor write method
                item_collect_port_read.write(tr);
            end
        end
    endtask
endclass
     
//------------------------------------------------------------------------
 
//read agent class
class read_agent extends uvm_agent;
  `uvm_component_utils(read_agent)
 
  //read monitor handle
  read_monitor r_mon;
  
  //class constructor
  function new(string name = "read_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
 
  //create the monitor
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    r_mon = read_monitor::type_id::create("mon", this);
  endfunction
  

  
endclass
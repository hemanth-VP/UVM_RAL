//register monitor class

class monitor extends uvm_monitor;
   `uvm_component_utils (monitor)
   function new (string name="monitor", uvm_component parent);
      super.new (name, parent);
   endfunction
 
  //analysis port to collect the data from interface
  uvm_analysis_port #(seq_item)  item_collect_port;
   virtual sfr_if  vif;
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     
     //create the memory for analysis port
      item_collect_port = new ("item_collect_port", this);

     //get the virtual interfae
     if (!uvm_config_db#(virtual sfr_if  )::get(this,"", "vif", vif))
        `uvm_error ("BUS MONITOR", "Did not get bus if handle")


   endfunction
 
   //monitoring the signals from interface    
   virtual task run_phase (uvm_phase phase);
      fork
         @(posedge vif.rst);
         forever begin
            @(posedge vif.clk);
           if (vif.psel & vif.pen & vif.rst) begin
               seq_item tr = seq_item::type_id::create ("tr");
               tr.addr = vif.paddr;
             if (vif.p_write)begin
                  tr.data = vif.p_wdata;
               $display("[%0d][MONITOR WRITE] Write_addr = %0h, Write_data = %0h", $time,tr.addr, tr.data);

             end
               else begin
                  tr.data = vif.prdata;
               tr. rd_or_wr = vif.p_write;

                 $display("[%0d][MONITOR READ]read_addr = %0h, read_data = %0h", $time,tr.addr, tr.data);
               end
               item_collect_port.write (tr);
            end 
         end
        
      join_none
   endtask
endclass
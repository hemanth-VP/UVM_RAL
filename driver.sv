//drivver class to configure the registers

class driver extends uvm_driver #(seq_item);
   `uvm_component_utils (driver)
 
   seq_item  tr;     //sequence item handle
   virtual sfr_if  vif;   //interface handle

  //class constructor new
   function new (string name = "driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
  //get the virtual interface
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     
     //get the interface
     if (!uvm_config_db#(virtual sfr_if)::get(this,"", "vif", vif))
         `uvm_error ("BUS DRIVER", "Did not get bus if handle")
   endfunction

       
   virtual task run_phase (uvm_phase phase);
      bit [31:0] data;
 
     //initialize all the signals to zero
      vif.psel <= 0;
      vif.pen <= 0;
      vif.p_write <= 0;
      vif.paddr <= 0;
      vif.p_wdata <= 0;
      forever begin
         @(posedge vif.clk)
         seq_item_port.get_next_item (tr);
        
        //calling the write or read tasks based on rd_or_wr bit value
         if (tr.rd_or_wr)
            write (tr.addr, tr.data);
         else begin
            read (tr.addr, data);
            tr.data = data;
         end
         seq_item_port.item_done ();
      end
   endtask
 
     //read task that drives the address, data and all read related signals to the interface
   virtual task read (  input bit    [31:0] addr, 
                        output logic [31:0] data);
      vif.paddr <= addr;
      vif.p_write <= 0;
      vif.psel <= 1;
      @(posedge vif.clk);
      vif.pen <= 1;
      @(posedge vif.clk);
     @(posedge vif.clk);
      data = vif.prdata;
      vif.psel <= 0;
      vif.pen <= 0;
     `uvm_info(get_type_name, $sformatf("[DRIVER READ TASK]read_address = %0h, read_data = %0h", tr.addr, tr.data), UVM_LOW);
   endtask
 
     //write task that drives the address, data and all write related signals to the interface
   virtual task write ( input bit [31:0] addr,
                        input bit [31:0] data);
      vif.paddr <= addr;
      vif.p_wdata <= data;
      vif.p_write <= 1;
      vif.psel <= 1;
      @(posedge vif.clk);
      vif.pen <= 1;
      @(posedge vif.clk);
      vif.psel <= 0;
      vif.pen <= 0;
     `uvm_info(get_type_name, $sformatf("[DRIVER WRITE TASK]write_address = %0h, write_data = %0h", tr.addr, tr.data), UVM_LOW);
   endtask
endclass
//base sequence class from which the actual sequences has been extended

class base_seq extends uvm_sequence#(seq_item);
  seq_item req;  //sequence item handle
  `uvm_object_utils(base_seq)
 
  //class constructor new
  function new (string name = "base_seq");
    super.new(name);
  endfunction

  task body();
    repeat(2) begin
    `uvm_info(get_type_name(), "Base seq: Inside Body", UVM_LOW);
      `uvm_do(req);   //handshake mechanism
    end
  endtask
endclass

//...........................................................................................

//write sequence class 
class write_seq extends uvm_sequence#(seq_item);
  seq_item wreq;
  `uvm_object_utils(write_seq)
  
  function new (string name = "write_seq");
    super.new(name);
  endfunction

  task body();
    repeat(2) begin
    `uvm_info(get_type_name(), "Write seq: Inside Body", UVM_LOW);
    `uvm_do(wreq);
   end
  endtask
endclass

//........................................................................................

//register sequence class
class reg_seq extends uvm_sequence#(seq_item);
  seq_item req;
  RegModel_SFR rg;  //register model handle
  uvm_status_e status;  
  uvm_reg_data_t read_data;
  `uvm_object_utils(reg_seq)
  
  function new (string name = "reg_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Reg seq: Inside Body", UVM_LOW);
    
    // Check if reg_model is set
    if (!uvm_config_db#(RegModel_SFR)::get(uvm_root::get(), "", "rg", rg))
      `uvm_fatal(get_type_name(), "reg_model is not set at top level");
   
    // Write to and read from enable_reg
    rg.mod_reg.enable_reg.write(status, 1'b1);
    `uvm_info(get_type_name(), $sformatf("After write: Desired value of chip enable register is %0h, Mirrored value is %0h",
                                         rg.mod_reg.enable_reg.get(), rg.mod_reg.enable_reg.get_mirrored_value()), UVM_NONE);
    rg.mod_reg.enable_reg.read(status, read_data);
    `uvm_info(get_type_name(), $sformatf("After read: Desired value for chip enable register is: %0h, Mirrored value is: %0h, Read data is: %0h",
                                         rg.mod_reg.enable_reg.get(), rg.mod_reg.enable_reg.get_mirrored_value(), read_data), UVM_NONE);

    // Write to and read from Id_reg
    rg.mod_reg.Id_reg.write(status, 8'b10000000);
    `uvm_info(get_type_name(), $sformatf("After write: Desired value of chip ID register is %0h, Mirrored value is %0h",
                                         rg.mod_reg.Id_reg.get(), rg.mod_reg.Id_reg.get_mirrored_value()), UVM_NONE);
    rg.mod_reg.Id_reg.read(status, read_data);
    `uvm_info(get_type_name(), $sformatf("After read: Desired value for chip ID register is: %0h, Mirrored value is: %0h, Read data is: %0h",
                                         rg.mod_reg.Id_reg.get(), rg.mod_reg.Id_reg.get_mirrored_value(), read_data), UVM_NONE);

    // Write to and read from Port_enable_reg
    rg.mod_reg.Port_enable_reg.write(status, 4'b0010);
    `uvm_info(get_type_name(), $sformatf("After write: Desired value of port enable register is %0h, Mirrored value is %0h",
                                         rg.mod_reg.Port_enable_reg.get(), rg.mod_reg.Port_enable_reg.get_mirrored_value()), UVM_NONE);
    rg.mod_reg.Port_enable_reg.read(status, read_data);
    `uvm_info(get_type_name(), $sformatf("After read: Desired value for port enable register is: %0h, Mirrored value is: %0h, Read data is: %0h",
                                         rg.mod_reg.Port_enable_reg.get(), rg.mod_reg.Port_enable_reg.get_mirrored_value(), read_data), UVM_NONE);
  endtask
endclass
with Ada.Text_IO;
with Ada.Command_Line;
with Interfaces; use Interfaces;
with Pmp; use Pmp;

procedure Pmp_Check is
   package IO  renames Ada.Text_IO;
   package CL  renames Ada.Command_Line;
begin
   --  Check whether amount of Arguments is correct
   if CL.Argument_Count /= 4 then
      IO.Put_Line ("Usage");
      IO.New_Line;
      IO.Put_Line ("    ./pmp_check <path-conf-file>"    &
                                   " <physical-address>" &
                                   " <privilege-mode>"   &
                                   " <operation>");
      IO.New_Line;
      IO.Put_Line ("Where:");
      IO.Put_Line ("    <path-conf-file>   : Path to the configuration file");
      IO.Put_Line ("    <physical-address> : Address in hexadecimal" &
                                            " starting with 0x");
      IO.Put_Line ("    <privilege-mode>   : Either M, S or U");
      IO.Put_Line ("    <operation>        : Either (R)ead, (W)rite or" &
                                             "e(X)ecute");
      return;
   end if;

   declare

      --  Command Line Arguments
      Arg_Path           : constant String := CL.Argument (1);
      Arg_Address        : constant Physical_Address :=
        Physical_Address'Value ("16#" &
        CL.Argument (2) (3 .. CL.Argument (2)'Last) & "#");
      Arg_Privilege_Mode : constant Privilege_Mode :=
        Privilege_Mode'Value (CL.Argument (3));
      Arg_Operation      : constant Operation :=
        Operation'Value (CL.Argument (4));

      --  File Related
      F : IO.File_Type;

   begin
      --  Open configuration file
      IO.Open (F, IO.In_File, Arg_Path);

      --  Populate pmpncfg array with the input
      for Index in Pmp.Pmp_Index'First .. Pmp.Pmp_Index'Last loop
         declare
            Line : constant String := IO.Get_Line (F);
            Pmpn : constant Unsigned_8 := Unsigned_8'Value
              ("16#" & Line (3 .. Line'Last) & "#");
         begin
            Pmpncfg_Add_Entry (Pmpn, Index);
         end;
      end loop;

      --  Populate pmpaddr array with the input
      for Index in Pmp_Index'First .. Pmp_Index'Last loop
         declare
            Line : constant String := IO.Get_Line (F);
            Reg  : constant Pmp_Address := Pmp_Address'Value
              ("16#" & Line (3 .. Line'Last) & "#");
         begin
            Pmpaddr_Add_Address (Reg, Index);
         end;
      end loop;

      --  Close stream
      IO.Close (F);

      --  Check access
      Print_Result (Check_Access (Arg_Address,
                                  Arg_Privilege_Mode,
                                  Arg_Operation));
   end;

end Pmp_Check;

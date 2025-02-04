 --------------------------------------------------------
 --                                                    --
 --             Physical Memory Protection             --
 --                                                    --
 --                       PMP.adb                      --
 --                                                    --
 --            Copyright (C) 2025, G. V. S.            --
 --                                                    --
 --                        Body                        --
 --                                                    --
 -- This package implements the Physical Memory Prot-  --
 -- ection (PMP) mechanism of the RISC-V architecture. --
 -- It is not meant for usage as part of a runtime, it --
 -- is based on the IDL verification coding challenge. --
 -- Also, please take into consideration that:         --
 --  · There is no support for different granularities.--
 --  · (G)ranularity is always 0. NA4 is enabled.      --
 --  · MPRV is not set. M always accesses as such.     --
 --  · There is always one entry implemented minimum.  --
 --  · This is the 64-bit version of this package.     --
 --  · There are 64 PMP entries.                       --
 --                                                    --
 --------------------------------------------------------

with Ada.Text_IO;

package body Pmp is

   --  Verify whether an address is in range
   function Verify_Address (Start_Address,
                            End_Address,
                            Arg_Address : Physical_Address)
                            return Boolean is
   begin
      return (Start_Address < End_Address) and then
        (Start_Address <= Arg_Address) and then
        (Arg_Address < End_Address);
   end Verify_Address;

   --  Verify whether an operation is allowed
   function Verify_Operation (Index : Pmp_Index;
                              Arg_Privilege_Mode : Privilege_Mode;
                              Arg_Operation : Operation)
                              return Boolean is
         Access_Allowed : Boolean := False;
   begin
      --  If we are in M-Mode and L = 0 we can bypass
      if Arg_Privilege_Mode = M and then pmpncfg (Index).L = 0 then
         Access_Allowed := True;
      else
         case Arg_Operation is --  Is the operation permitted?
            when R =>
               if pmpncfg (Index).R = 1 then
                  Access_Allowed := True;
               end if;
            when W =>
               if pmpncfg (Index).W = 1 then
                  Access_Allowed := True;
               end if;
            when X =>
               if pmpncfg (Index).X = 1 then
                  Access_Allowed := True;
               end if;
         end case;
      end if;
      return Access_Allowed;
   end Verify_Operation;

   --  Prints whether an access is successfull or faults
   procedure Print_Result (Result : Boolean) is
   begin
      if Result then
         Ada.Text_IO.Put_Line ("Success");
      else
         Ada.Text_IO.Put_Line ("Access Fault");
      end if;
   end Print_Result;

   --  Set new granularity
   procedure Set_Granularity (New_Granularity : Granularity) is
   begin
      G := New_Granularity;
   end Set_Granularity;

   --  Add address to pmpaddr array at given Index
   procedure Pmpaddr_Add_Address (New_Address : Pmp_Address;
                                  Index : Pmp_Index) is
   begin
      pmpaddr (Index) := New_Address;
   end Pmpaddr_Add_Address;

   --  Add entry to pmpcnfg array at given Index
   procedure Pmpncfg_Add_Entry (New_Entry : Unsigned_8;
                                Index : Pmp_Index) is
   begin
      pmpncfg (Index).R := Integer (New_Entry and 1);
      pmpncfg (Index).W := Integer (Shift_Right (New_Entry, 1) and 1);
      pmpncfg (Index).X := Integer (Shift_Right (New_Entry, 2) and 1);
      pmpncfg (Index).A :=
        Pmp_Mode'Val (Integer (Shift_Right (New_Entry, 3) and 3));
      pmpncfg (Index).Reserved :=
        Integer (Shift_Right (New_Entry, 5) and 3);
      pmpncfg (Index).L := Integer (Shift_Right (New_Entry, 7) and 1);
   end Pmpncfg_Add_Entry;

   --  Check whether an access is allowed with this PMP config
   function Check_Access (Arg_Address : Physical_Address;
                          Arg_Privilege_Mode : Privilege_Mode;
                          Arg_Operation : Operation)
                          return Boolean is
   begin
      --  Find matching PMP entry
      for Index in Pmp_Index'First .. Pmp_Index'Last loop
         declare
            Start_Address : Physical_Address;
            End_Address   : Physical_Address;
         begin
            --  Top of Range Mode
            if pmpncfg (Index).A = TOR then
               --  Set up range
               if Index = Pmp_Index'First then
                  Start_Address := Physical_Address'First;
               else
                  Start_Address := Shift_Left
                    (Physical_Address (pmpaddr (Index - 1)), 2);
               end if;
               End_Address := Shift_Left
                 (Physical_Address (pmpaddr (Index)), 2);

            --  Naturally-Aligned 4-byte region
            elsif pmpncfg (Index).A = NA4 then
               --  Set up range
               Start_Address := Shift_Left
                 (Physical_Address (pmpaddr (Index)), 2);
               End_Address := Start_Address + 4;

            --  Naturally-Aligned Power of Two Region
            elsif pmpncfg (Index).A = NAPOT then
               --  Set up range
               declare
                  Shifted_Address : Pmp_Address := pmpaddr (Index);
                  Offset_Base_2   : Integer     := 3; --  2³ alignment
                  type Bit is mod 2;
                  LSB : Bit;
               begin
                  loop --  Calculate address and size
                     LSB := Bit (Shifted_Address and 1);
                     exit when (LSB = 0) or else
                               (Offset_Base_2 = MSB);
                     Shifted_Address := Shift_Right (Shifted_Address, 1);
                     Offset_Base_2 := Offset_Base_2 + 1;
                  end loop;
                  Start_Address := Physical_Address (pmpaddr (Index) and
                    Shift_Left (Pmp_Address'Last, Offset_Base_2 - 3));
                  Start_Address := Shift_Left (Start_Address, 2);
                  End_Address := Start_Address + 2 ** Offset_Base_2;
               end;

            end if;

            --  Is address within range?
            if pmpncfg (Index).A /= OFF and then
                 Verify_Address (Start_Address, End_Address, Arg_Address)
            then
               --  Check if operation is allowed
               return Verify_Operation (Index,
                                        Arg_Privilege_Mode,
                                        Arg_Operation);
            end if;
         end;

      end loop;
      --  0 matches and we assume entries are implemented
      --    so the access faults for S and U, but succeeds for M.
      if Arg_Privilege_Mode = M then
         return True;
      else
         return False;
      end if;

   end Check_Access;

end Pmp;

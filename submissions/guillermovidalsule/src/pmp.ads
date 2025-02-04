 --------------------------------------------------------
 --                                                    --
 --             Physical Memory Protection             --
 --                                                    --
 --                       PMP.ads                      --
 --                                                    --
 --            Copyright (C) 2025, G. V. S.            --
 --                                                    --
 --                        Spec                        --
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

with Interfaces; use Interfaces;

package Pmp is
   --  Types for Mode and Operation
   type Privilege_Mode is (M, S, U);
   type Operation      is (R, W, X);
   type Pmp_Mode       is (OFF, TOR, NA4, NAPOT);

   --  Granularity
   type Granularity is new Integer range 0 .. 0;

   --  Configuration architecture
   type Architecture is (Riscv_32, Riscv_64);

   MSB : constant Integer := 55;
   type Pmp_Address is new Unsigned_64
     range 0 .. 2**(MSB - 1) - 1;
   type Physical_Address is new Unsigned_64
     range 0 .. 2**(MSB + 1) - 1;

   --  Array definitions for PMP entries and addresses
   type Pmp_Index is range 0 .. 64 - 1;
   type Pmpaddr_Array is array (Pmp_Index) of Pmp_Address;
   type Pmp_Entry is record
      L        : Integer range 0 .. 1; --  Lock
      Reserved : Integer range 0 .. 0; --  Reserved, 0
      A        : Pmp_Mode;             --  PMP mode
      X        : Integer range 0 .. 1; --  Execute
      W        : Integer range 0 .. 1; --  Write
      R        : Integer range 0 .. 1; --  Read
   end record;
   type Pmpncfg_Array is array (Pmp_Index) of Pmp_Entry;

   --  Arrays of PMP CSRs
   pmpncfg : Pmpncfg_Array;
   pmpaddr : Pmpaddr_Array;

   --  Functions, info on body
   function Verify_Address (Start_Address,
                            End_Address,
                            Arg_Address : Physical_Address)
                            return Boolean;

   function Verify_Operation (Index : Pmp_Index;
                              Arg_Privilege_Mode : Privilege_Mode;
                              Arg_Operation : Operation)
                              return Boolean;

   procedure Print_Result (Result : Boolean);
   procedure Set_Granularity (New_Granularity : Granularity);

   procedure Pmpaddr_Add_Address (New_Address : Pmp_Address;
                                  Index : Pmp_Index);

   procedure Pmpncfg_Add_Entry (New_Entry : Unsigned_8;
                                Index : Pmp_Index);

   function Check_Access (Arg_Address : Physical_Address;
                          Arg_Privilege_Mode : Privilege_Mode;
                          Arg_Operation : Operation)
                          return Boolean;

private

   G : Granularity := 0;

end Pmp;

# Physical Memory Protection - Configuration Verifier

This purpose of this tool is to verify whether a given access
with privilege mode _M_ can undertake an operation of type _O_
at a specific address.

## Project Structure

The folders and files are the following:

| Name | Type  | Description |
| :--- | :---: | :---------- |
| `bin` | Directory | Output directory where the executable is placed. |
| `config` | Directory | Further configuration of the project. |
| `src` | Directory | Source code. |
| `alire.toml` | File | Crate settings. |
| `configuration.txt` | File | Basic PMP configuration to test the program. |
| `pmp_check.gpr` | File | Project configuration file. |
| `README.md` | File | Informational README about the project. |
 
There could be more entries, but they are out of the scope for the coding challenge.

The most important part is the source code, which consists of:

1. `pmp_check.adb` - Main program.
2. `pmp.ads` - Description of the PMP system.
3. `pmp.adb` - Implementation of the PMP system.

## Compile

In order to run the program you will need `gprbuild`. You can download it
with the GNAT FSF toolchain, which includes other necessary packages.

```
project-dir$ gprbuild -P pmp_check.adb
```

Alternatively, if you have the toolchain set up with Alire:

```
project-dir$ alr build
```

## Run

Running it is as simple as:

```
project-dir$ ./bin/pmp_check <path-to-config-file> <address> <privilege-mode> <operation>
```

> [!NOTE]
> If you do not wish / cannot compile it, a binary is already provided at the bin directory, but it can only be run on a x86\_64 architecture.

## Tools

I used the GNAT FSF 14 toolchain paired with Alire. In particular:

- `gprbuild 22.0.0`
- `alr 2.0.2`
- `gcc 14.2.0` (precompiled version that came with the toolchain)

This does not imply that other versions will not work, you could even try
using `gnatmake`, but I will not verify whether they are compatible or not.

## Final Remarks

I chose Ada because it is a statically and strongly typed language like IDL,
 which is mentioned in the project description.

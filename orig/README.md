### What I did to adopt Dr. Ting's eJsv32k to Radiant with iCE40UP (the only device I have)
1. add a spram.sv module and a 8-bit interface spram_if.sv for iCE40 Single Port RAM (128K) access.
2. replaced mult, divide, shifter, ushifter modules with simply *, /, <<
    + on iCE40, they all need multiple cycles but I left them as is now.
3. refactor eJsv32k to eJ32.sv
    + bring the memory block outside as a external module
    + stacks are using LUT now, could try EBR memory later
    + simplify syntax with a few macros
    + add one extra memory cycle to a few opcodes (i.e. bastore, sastore, get)
4. extract JVM opcode as enum into a include file eJ32.vh (ModelSim can display opcode name)
5. extract a simple hex formatted file from ej32i.mif into eJ32sv.hex (for Verilog fopen/fscan)
6. create dict_setup.sv module to load the hex file into SPRAM
7. create outer_tb.sv test bench to bind all modules together
8. once Radiant compiled, kick it off to ModelSim (my license is Radiant dependent).

### Notes on current eJsv32k implementation.
1. To expand memory (say from 8K to 64K), tib and output buffer sit at lower address would be easier.
2. Link fields are 16-bit even though addr registers are at 32-bit.
3. If addr reduced to 16-bit, dup_1x, and dup2 need fixing because using A as temp.
4. sastore logic for dsel is off by 1. Tough find but easy fix.
5. Calling takes a few cycles. For short words (i.g. emit), we can add a flag to help assembler just copy the content of parameter field (aka inline).

### To Simulate
1. Open eJsv32.rdf with Radiant. It should include all the source files from the original eJsv32k package.
    + opcodes are extracted to source/eJ32.vh as enums
    + a few macro tasks to reduce verbosity, the logic is pretty much verbatim from your original source
    + iCE SPRAM module is used and accessed via the forthsuper_if interface.
    + mult, shift, ushift are simplified to just one line (supported by onboard DSPs).
    + A 32-bit divider is coded but have some bug that I have to add a patch task temporarily.
    + a single-byte per row hex file is created in source/eJ32.hex from your mif. It is fed to dict_setup.
2. use Tools->Simulation Wizard
    + with outer_tb as the top module.
    + It will take about 500K cycles to finish the built-in test cases.







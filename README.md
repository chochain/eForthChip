## Forth on FPGA for AI &amp; Robotics
Typically, a Forth CPU has a core that functions as the Forth inner-interpreter with a small instruction set that represents the core primitive words. The Forth outer-interpreter is then built on top of these primitive words via cross-compilation on other development platform and copy onto the FPGA RAM either from external SD card or as binary image onboard ROM.

With the advance of SystemVerilog, having an outer-interpreter entirly in hardware is possible. Though the practicality of having it is in question, my task here is to give it a try to see how does and how well it work?

## Is it time for another Forth Chip?
* [This Google conversation](https://groups.google.com/g/comp.lang.forth/c/6adve-Z1ppU) sort of sealing the fate of this project. And, the answer is NOT REALLY!
* So, with spare time, I look at eJsv32 which was the extension of Dr. Ting's last project before his passing. (https://github.com/chochain/eJsv32/)

## Outer Interpreter block diagram
  <img src="./img/forthsuper_outer_arch.png" width='600px'>

## Status
* Serve as a temp storage before transition to the team project (https://github.com/angelus9/AI-Robotics/)
* Functional units

  |Unit|Desc|Status|Note|
  |--|--|--|--|
  |Outer|Top Module|OK||
  |Atoi(er)|ASCII to integer converter|OK||
  |Finder|Dictionary walker|OK||
  |Comma|Byte Compiler|Mock||
  |Pusher|Stack operation|Mock||
  |Mem|SPRAM dictionary pool|OK|8-bit|
  |Exec|Execution Unit|OK|25 opcodes only|
  |Inner|Inner-interpreter|Mock||
  |Dict_setup|Dictionary/TIB initializer|OK||

## Implementation Details
* Mem pool and Find
  |mem pool (single port RAM)|find (dictionary search)|
  |---|---|
  |<img src="./img/mem_0.png" width='600px'>|<img src="./img/find_0.png" width='600px'>|
* Atoi (string to integer)
  |   |case0|case1|
  |---|---|---|
  |   |8-state, dedicated comparator|3-state, synthesizer gen comparators|
  |LUT|220 LUTS|182 LUTS|
  |src|<img src="./img/atoi_0_src.png" width='400px'>|<img src="./img/atoi_1_src.png" width='400px'>|
  |syn|<img src="./img/atoi_0_syn.png" width='500px'>|<img src="./img/atoi_1_syn.png" width='500px'>|
  |sim|<img src="./img/atoi_0_sim.png" width='500px'>|<img src="./img/atoi_1_sim.png" width='500px'>|
* Module transition (outer interpreter)
  |fnd -> a2i -> psh|fnd -> exe -> fnd|
  |---|---|
  |<img src="./img/fnd_a2i_psh.png" width='500px'>|<img src="./img/fnd_exe.png" width='500px'>|
* Execution unit
  |stack op|ALU op|
  |---|---|
  |<img src="./img/exec_ss_01.png" width='500px'>|<img src="./img/exec_02.png" width='500px'>|
* Inner interpreter
  |123 dup +|234 -|
  |---|---|
  |<img src="./img/inner_0.png" width='500px'>|<img src="./img/inner_1.png" width='500px'>|




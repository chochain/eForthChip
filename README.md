## Forth on FPGA for AI &amp; Robotics
* temp storage before transition to the team project (https://github.com/angelus9/AI-Robotics/)
* work in progress (inner, comma, pusher)

## Is it time for another Forth Chip?
* [this conversation](https://groups.google.com/g/comp.lang.forth/c/6adve-Z1ppU) sort of seal the fate of this project.

## Outer Interpreter block diagram
> ![](./img/forthsuper_outer_arch.png | width=600px)

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
  |fnd->a2i-psh|fnd->exe->fnd|
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




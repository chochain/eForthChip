# forthsuper
## Forth on FPGA for AI &amp; Robotics
* temp storage before the team project is created
* work in progress (inner, comma, pusher)

### Outer Interpreter block diagram
<img src="./img/forthsuper_outer_arch.png">

### mem pool (single port RAM)
<img src="./img/mem_0.png">

### find (dictionary search)
<img src="./img/find_0.png">

### atoi (string to integer)
|   |case0|case1|
|---|---|---|
|   |8-state, dedicated comparator|3-state, synthesizer gen comparators|
|LUT|220 LUTS|182 LUTS|
|src|<img src="./img/atoi_0_src.png">|<img src="./img/atoi_1_src.png">|
|syn|<img src="./img/atoi_0_syn.png">|<img src="./img/atoi_1_syn.png">|
|sim|<img src="./img/atoi_0_sim.png">|<img src="./img/atoi_1_sim.png">|

### module transition (outer interpreter)
|case|simulation|
|---|---|
|fnd->a2i->psh|<img src="./img/fnd_a2i_psh.png">|
|fnd->exe->fnd|<img src="./img/fnd_exe.png">|

### execution unit
|case|simulation|
|---|---|
|stack op|<img src="./img/exec_ss_01.png">|
|alu op|<img src="./img/exec_02.png">|


//
// @file - Verilator main file
// @brief - copy testbench (i.g. spram_tb.v) to top.v and make
// @note - environment variables automatically set
//    * --cc         VM_SC=0           // using C++ instead of SystemC
//    * --no-debug   VL_DEBUG=0        // default is 1
//    * --trace      VM_TRACE=1 VM_TRACE_VCD=1 VM_TRACE_FST=0
//    * --trace-fst  VM_TRACE=1 VM_TRACE_VCD=0 VM_TRACE_FST=1
//    * --coverage   VM_COVERAGE=1
//
//======================================================================
#include <memory>                      // For std::unique_ptr
#include <verilated.h>                 // Include common routines
#if VM_TRACE_VCD
#include <verilated_vcd_c.h>
typedef VerilatedVcdC Tracer;
#define DUMP_FILE     "logs/wave.vcd"
#endif
#if VM_TRACE_FST
#include <verilated_fst_c.h>
typedef VerilatedFstC Tracer;
#define DUMP_FILE     "logs/wave.fst"
#endif
#include "Vtop.h"                      // Include model header, generated from Verilating "top.v"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

int main(int argc, char** argv) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Prevent unused variable warnings
    if (false && argc && argv) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");
    
    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};

#if VM_TRACE
    Tracer *trace = new Tracer;
    top->trace(trace, 99);
    trace->open(DUMP_FILE);
#endif    
    // Set Vtop's input signals
    top->clk = 0;

    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions just assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(1);  // 1 timeprecision period passes...
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        top->clk = !top->clk;
        
#if 0
        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // reset is not sampled there.
        if (!top->clk) {
            if (contextp->time() > 1 && contextp->time() < 10) {
                top->reset_l = !1;  // Assert reset
            } else {
                top->reset_l = !0;  // Deassert reset
            }
            // Assign some other inputs
            top->in_quad += 0x12;
        }
#endif

        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();
#if VM_TRACE
        trace->dump(contextp->time()*2);
#endif        
        // Read outputs
        VL_PRINTF("[%" PRId64 "] clk=%x ai=%4x vi=%02x vo=%02x\n",
                  contextp->time(), top->clk, top->ai, top->vi, top->vo);
    }

    // Final model cleanup
    top->final();
    
#if VM_TRACE
    trace->flush();
    trace->close();
#endif    

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}

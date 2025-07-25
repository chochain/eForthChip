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
#include <iostream>
#include <iomanip>
#include <memory>                      // For std::unique_ptr
#include <verilated.h>                 // Include common routines
#include <vltstd/vpi_user.h>
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
#define COVER_FILE    "logs/coverage.dat"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

void _dump_tree(vpiHandle modHandle, int indent) {
    if (!modHandle) return;
    
    // Print indentation
    for (int i = 0; i < indent; i++) std::cout << "  ";
    
    // Get module information
    PLI_BYTE8* modName = vpi_get_str(vpiName, modHandle);
    PLI_BYTE8* modType = vpi_get_str(vpiType, modHandle);

    if (strcmp(modType, "vpiModule")) {        // custom module?
        std::cout << '<' << modType << '>';   
    }
    std::cout << (modName ? modName : "???") << std::endl;
    
    // Iterate through child modules
    vpiHandle modIter = vpi_iterate(vpiModule, modHandle);
    if (modIter) {
        vpiHandle childHandle;
        while ((childHandle = vpi_scan(modIter))) {
            _dump_tree(childHandle, indent + 1);
        }
    }
}

void dump_hierarchy(const char *name) {
    std::cout << "VPI Hierarchy Dump: " << name << std::endl;
    
    // Start from top module
    vpiHandle topHandle = vpi_handle_by_name((PLI_BYTE8*)name, NULL);
    if (!topHandle) {
        std::cout << " not found" << std::endl;
        return;
    }
    _dump_tree(topHandle, 0);
}

// Function to read a signal's value
void get_signal(const char *hier_name) {
    vpiHandle sig_handle = vpi_handle_by_name((PLI_BYTE8*)hier_name, NULL);

    if (!sig_handle) {
        std::cerr << "Error: Could not find handle for signal: " << hier_name << std::endl;
        return;
    }

    s_vpi_value value_s;
    value_s.format = vpiHexStrVal; // Request value as a hex string
    vpi_get_value(sig_handle, &value_s);

    std::cout << hier_name << '=' << value_s.value.str << std::endl;
}

// Startup routine for VPI registration
void register_vpi_tasks() {
    // Register system tasks/functions here if needed
    // For this example, vpi_handle_by_name is used directly
    // in the main simulation loop.
}

// Required for VPI startup
void (*vlog_startup_routines[])() = {
    register_vpi_tasks,
    0 // Null termination is crucial
};

#if 0 // simple - raw object
// Main simulation loop (simplified for demonstration)
// In a real application, this would be integrated with the Verilated model's eval loop.
int main(int argc, char** argv) {
    // Initialize Verilator (if using a Verilated model)
    Verilated::debug(0);
    Verilated::commandArgs(argc, argv);
    Vtop &top = *new Vtop;

    Verilated::scopesDump();
    dump_hierarchy("TOP.top");
    
    // Simulate some time or events
    for (int i = 0; i < 5; ++i, Verilated::timeInc(1)) {
        std::cout << "Simulation Cycle " << i << ":" << std::endl;
        
        top.clk = !top.clk;
        top.ai  = i;
        top.eval();

        // Access signals using vpi_handle_by_name
        get_signal("TOP.top.clk");
        get_signal("TOP.top.ai");
        get_signal("TOP.top.vi");
        get_signal("TOP.top.vo");
        get_signal("TOP.top._clk");

        std::cout << std::endl;
        
        VL_PRINTF("[%" PRId64 "] clk=%x ai=%4x vi=%02x vo=%02x\n",
                  Verilated::time(), top.clk, top.ai, top.vi, top.vo);
    }
    dump_hierarchy("TOP.top");

    // Clean up Verilator (if using a Verilated model)
    top.final();
    delete &top;

    return 0;
}

#else // complex - unique_ptr

int init_ctx(const std::unique_ptr<VerilatedContext> &ctx, int argc, char** argv) {
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    ctx->debug(0);     // use --debugi-spram8_128k 1

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    ctx->randReset(2);

    // Verilator must compute traced signals
    ctx->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    ctx->commandArgs(argc, argv);

    return 0;
}

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
    const std::unique_ptr<VerilatedContext> ctx{ new VerilatedContext };
    if (init_ctx(ctx, argc, argv)) return 1;

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vtop> top{ new Vtop{ ctx.get(), "TOP" } };

    // TOP module is instaintiated
    // We can dump them now
    ctx->scopesDump();
    dump_hierarchy("TOP.top");

    // Enable VCD or FST tracer
#if VM_TRACE
    Tracer *trace = new Tracer;
    top->trace(trace, 99);
    trace->open(DUMP_FILE);
#endif
    
    // Set Vtop's input signals
    top->clk = 0;

    // Simulate until $finish
    while (!ctx->gotFinish()) {
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions just assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        ctx->timeInc(1);  // 1 timeprecision period passes...
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
            if (ctx->time() > 1 && ctx->time() < 10) {
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
        trace->dump(ctx->time() * 2);
#endif        
        // Read outputs
        VL_PRINTF("[%" PRId64 "] clk=%x ai=%4x vi=%02x vo=%02x\n",
                  ctx->time(), top->clk, top->ai, top->vi, top->vo);
    }
    // Final model cleanup
    top->final();
    dump_hierarchy("TOP.top");
    
#if VM_TRACE
    trace->flush();
    trace->close();
    VL_PRINTF("%s created, open with gtkwave\n", DUMP_FILE);
#endif    

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    ctx->coveragep()->write(COVER_FILE);
    VL_PRINTF("%s created, 'make cover' to annotate\n", COVER_FILE);
#endif

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}

#endif // simple or complex main

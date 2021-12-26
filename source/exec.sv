///
/// ForthSuper - Execution Unit
///
`ifndef FORTHSUPER_EXEC
`define FORTHSUPER_EXEC
`include "../source/forthsuper.vh"
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
`include "../source/stack.sv"
import FS1::*;                            /// import opcode_e
///
/// macros to reduce verbosity
///
`define PUSH(v) _tos = v; ds_if.push(v);
`define POP     ds_if.pop()
module exec #(
    parameter IP0 = 'h100,                /// starting IP
    parameter DSZ = 32,                   /// 32-bit data path
    parameter ASZ = 17                    /// 128K address path
    ) (
    mb8_io                 mb_if,         /// opcode memory block
    ss_io                  ds_if,         /// data stack
    input                  clk,           /// clock signal
    input                  rst,           /// reset signal
    input                  en,            /// enable signal
    input opcode_e         op             /// opcode to be executed
    );
    logic [DSZ-1:0]        tos, _tos;     /// Top of data stack, next of data stack
    logic [ASZ-1:0]        ip, _ip;       /// address pointers
    stack_ops              dsop;

    //ss_io  rs_if();
    //stack  rs(.ss_if(rs_if.slave), .clk, .rst, .en(1'b1));
    ///
    /// logic for execution engine
    ///
    function void flow_op;
        /*        
        "nop",     {}
        "dovar",   PUSH(IPOFF); IP += sizeof(DU)
        "dolit",   PUSH(*(DU*)IP); IP += sizeof(DU)
        "dostr",   const char *s = (const char*)IP; PUSH(IPOFF); IP += STRLEN(s)
        "dotstr",  const char *s = (const char*)IP; fout << s;  IP += STRLEN(s)),
        "branch" , IP = JMPIP),
        "0branch", IP = POP() ? IP + sizeof(IU) : JMPIP),
        "donext",  if ((rs[-1] -= 1) >= 0) IP = JMPIP; else { IP += sizeof(IU); rs.pop(); }
        "does",    U8 *ip  = PFA(WP); U8 *ipx = ip + PFLEN(WP);
                   while (ip < ipx && *(IU*)ip != DOES) ip+=sizeof(IU);
                   while ((ip += sizeof(IU)) < ipx) add_iu(*(IU*)ip);
                   IP = ipx),
        ">r",      rs.push(POP())
        "r>",      PUSH(rs.pop())
        "r@",      PUSH(rs[-1])
        */
    endfunction: flow_op
    
    function void stack_op;
        automatic logic [DSZ-1:0] n;
        case(op)
        _DUP:   begin `PUSH(tos); end
        _DROP:  _tos = `POP;
        _OVER:  begin `PUSH(ds_if.s); end
        //_SWAP:  begin n = `POP; `PUSH(n); end
        //_ROT:  "rot",  DU n = ss.pop(); DU m = ss.pop(); ss.push(n); PUSH(m)
        //_PICK: "pick", DU i = top; top = ss[-i]
        endcase
    endfunction: stack_op
    
    function void alu_op;
        automatic logic [DSZ-1:0] n;
        case (op)
        _ADD:  begin
            _tos  = ds_if.s + tos;
            dsop  = POP;
        end
        _SUB:  begin
            _tos = ds_if.s - tos;
            dsop = POP;
        end
        _MUL:   _tos = `POP * tos;
//      _DIV:   _tos = `POP / tos;     // 3K LUTs
//      _MOD:   _tos = `POP % tos;     // 2.2K LUTs
//      _MDIV:  "*/",   top =  ss.pop() * ss.pop() / top
//      _SMOD:  "/mod", DU n = ss.pop(); DU t = top;  ss.push(n % t); top = (n / t)
//      _MSMOD: "*/mod", DU n = ss.pop() * ss.pop();  DU t = top; ss.push(n % t); top = (n / t)
        _AND:   _tos = `POP & tos;
        _OR:    _tos = `POP | tos;
        _XOR:   _tos = `POP ^ tos;
        _ABS:   _tos = tos > 0 ? tos : -tos;
        _NEG:   _tos = ~tos;
        _MAX:   begin
            _tos = $signed(tos) > $signed(ds_if.s) ? tos : ds_if.s;
            dsop = POP;
        end
        _MIN: begin
            _tos = $signed(tos) < $signed(ds_if.s) ? tos : ds_if.s;
            dsop = POP;
        end
        default: begin _tos = tos; dsop = NOP; end
        endcase        
    endfunction: alu_op

    function void logic_op;
        case(op)
        _ZEQ: _tos = tos == 0;
        _ZLT: _tos = tos <  0;
        _ZGT: _tos = tos >  0;
        _EQ:  _tos = `POP == tos;
        _GT:  _tos = `POP >  tos;
        _LT:  _tos = `POP <  tos;
        _NE:  _tos = `POP != tos;
        _GE:  _tos = `POP >= tos;
        _LE:  _tos = `POP <= tos;
        endcase
    endfunction: logic_op

    function void io_op;
        /*
    _QRX, _TXSTO,
    _QKEY, _KEY, _EMIT, 
    _WITHIN, _TCHAR, 
    _CHARS, _TYPE, _SPC, _SPCS,
    _HEX, _DEC,
    _CR, _DOSTR, _STRQP, _DSTR, 
    _DOT, _DOTR, _UDOTR, _UDOT, _QUEST,
        "base@",   PUSH(base)
        "base!",   fout << setbase(base = POP())
        "hex",     fout << setbase(base = 16)
        "decimal", fout << setbase(base = 10)
        "cr",      fout << ENDL
        ".",       fout << POP() << " "
        ".r",      DU n = POP(); dot_r(n, POP())
        "u.r",     DU n = POP(); dot_r(n, abs(POP()))
        ".f",      DU n = POP(); fout << setprecision(n) << POP()
        "key",     PUSH(next_word()[0])
        "emit",    char b = (char)POP(); fout << b
        "space",   fout << " "
        "spaces",  for (DU n = POP(), i = 0; i < n; i++) fout << " "
         */
    endfunction: io_op

    function void lit_op;
        /*
    _DOTSTR, _STRQP, _DOTQP, _BSLSH, _DOSTR,         
       i".\"",     const char *s = scan('"')+1; add_iu(DOTSTR); add_str(s))
       i"(",       scan(')')
       i".(",      fout << scan(')')
        "\\",      scan('\n')
        "$\"",     const char *s = scan('"')+1; add_iu(DOSTR); add_str(s))
        */
    endfunction: lit_op

    function void branch_op;
    /*
       i"if",      add_iu(ZBRAN); PUSH(XIP); add_iu(0)),
       i"else",    add_iu(BRAN);  IU h=XIP;  add_iu(0); SETJMP(POP()) = XIP; PUSH(h)
       i"then",    SETJMP(POP()) = XIP)
       i"begin",   PUSH(XIP)
       i"again",   add_iu(BRAN);  add_iu(POP())
       i"until",   add_iu(ZBRAN); add_iu(POP())
       i"while",   add_iu(ZBRAN); PUSH(XIP); add_iu(0)
       i"repeat",  add_iu(BRAN);  IU t=POP(); add_iu(POP()); SETJMP(t)  = XIP),             
       i"for" ,    add_iu(TOR); PUSH(XIP)),
       i"next",    add_iu(DONEXT); add_iu(POP())),
       i"aft",     POP(); add_iu(BRAN); IU h=XIP; add_iu(0); PUSH(XIP); PUSH(h)
    */                                                  
    endfunction: branch_op

    function void meta_op;
        /*
        case (op)
        "[",       compile = false
        "]",       compile = true
        ":", colon(next_word()); compile=true
       i";", compile = false
        "variable", colon(next_word()); add_iu(DOVAR); int n = 0; add_du(n)),
        "constant", colon(next_word()); add_iu(DOLIT); add_du(POP())),
        "exit",  IP = PFA(WP) + PFLEN(WP)),
        "exec",  CALL(POP())),
        "create", colon(next_word()); add_iu(DOVAR)),
        "to",    IU w = find(next_word()); *(DU*)(PFA(w) + sizeof(IU)) = POP()
        "is",    IU w = find(next_word()); dict[POP()].pfa = dict[w].pfa),
        "[to]",  IU w = *(IU*)IP; IP += sizeof(IU); *(DU*)(PFA(w) + sizeof(IU)) = POP()
        "@",     IU w = POP(); PUSH(CELL(w)))
        "!",     IU w = POP(); CELL(w) = POP();)
        ",",     DU n = POP(); add_du(n)
        "allot", DU v = 0; for (IU n = POP(), i = 0; i < n; i++) add_du(v))
        "+!",    IU w = POP(); CELL(w) += POP())
        "?",     IU w = POP(); fout << CELL(w) << " ")
        endcase
        */
    endfunction: meta_op

    function void debug_op;
        /*
        "here",  PUSH(HERE)
        "ucase", ucase = POP()
        "words", words()
        "'",     IU w = find(next_word()); PUSH(w)
        ".s",    ss_dump()
        "see",   IU w = find(next_word()); IU ip=0; see(&w, &ip)
        "dump",  DU n = POP(); IU a = POP(); mem_dump(a, n)
        "peek",  DU a = POP(); PUSH(PEEK(a))
        "poke",  DU a = POP(); POKE(a, POP())
        "forget", IU w = find(next_word()); if (w<0) return; IU b = find("boot")+1; dict.clear(w > b ? w : b)
        */
    endfunction: debug_op

    function void pin_op;
        /*
        "pin",   DU p = POP(); pinMode(p, POP())
        "in",    PUSH(digitalRead(POP()))
        "out",   DU p = POP(); digitalWrite(p, POP())
        "adc",   PUSH(analogRead(POP()))
        "duty",  DU p = POP(); analogWrite(p, POP(), 255)
        "attach",DU p  = POP(); ledcAttachPin(p, POP())
        "setup", DU ch = POP(); DU freq=POP(); ledcSetup(ch, freq, POP())
        "tone",  DU ch = POP(); ledcWriteTone(ch, POP())
        "clock", PUSH(millis())
        "delay", delay(POP())
        "bye",   exit(0)
        "boot",  dict.clear(find("boot") + 1); pmem.clear())
         */
    endfunction: pin_op
    //
    // dispatcher
    //
    always_comb begin // (sensitivity list: tos, ip, ss_if.s)
        _tos = 'h0;
        _ip  = IP0;
        if (en) begin
            flow_op();
            stack_op();
            alu_op();
            logic_op();
            io_op();
            lit_op();
            branch_op();
            meta_op();
            debug_op();
            pin_op();
            _ip = ip + 1'b1;
            ds_if.op = dsop;
            mb_if.get_u8(ip);      // prefetch next instruction
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            tos <= 'h0;
            ip  <= IP0;
        end
        else begin
            tos <= _tos;
            ip  <= _ip;
        end
    end
    
    initial begin
        $monitor("%6d:[%2d](%4d,%4d)", $time, op, $signed(ds_if.s), $signed(tos));
    end
endmodule: exec
`endif // FORTHSUPER_EXEC

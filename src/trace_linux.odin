
import "core:sys/linux"

pid    :: linux.Pid
errno  :: linux.Errno
signal :: linux.Signal

PTrace_Request :: enum {
    TRACEME                = 0,
    PEEKTEXT               = 1,
    PEEKDATA               = 2,
    PEEKUSER               = 3,
    POKETEXT               = 4,
    POKEDATA               = 5,
    POKEUSER               = 6,
    CONT                   = 7,
    KILL                   = 8,
    SINGLESTEP             = 9,
    GETREGS                = 12,
    SETREGS                = 13,
    GETFPREGS              = 14,
    SETFPREGS              = 15,
    ATTACH                 = 16,
    DETACH                 = 17,
    GETFPXREGS             = 18,
    SETFPXREGS             = 19,
    SYSCALL                = 24,
    GET_THREAD_AREA        = 25,
    SET_THREAD_AREA        = 26,
    ARCH_PRCTL             = 30,
    SYSEMU                 = 31,
    SYSEMU_SINGLESTEP      = 32,
    SINGLEBLOCK            = 33,
    SETOPTIONS             = 0x4200,
    GETEVENTMSG            = 0x4201,
    GETSIGINFO             = 0x4202,
    SETSIGINFO             = 0x4203,
    GETREGSET              = 0x4204,
    SETREGSET              = 0x4205,
    SEIZE                  = 0x4206,
    INTERRUPT              = 0x4207,
    LISTEN                 = 0x4208,
    PEEKSIGINFO            = 0x4209,
    GETSIGMASK             = 0x420a,
    SETSIGMASK             = 0x420b,
    SECCOMP_GET_FILTER     = 0x420c,
    SECCOMP_GET_METADATA   = 0x420d,
    GET_SYSCALL_INFO       = 0x420e,
    GET_RSEQ_CONFIGURATION = 0x420f,
};

PTrace_Options_Bits :: enum {
    TRACESYSGOOD    = 0,
    TRACEFORK       = 1,
    TRACEVFORK      = 2,
    TRACECLONE      = 3,
    TRACEEXEC       = 4,
    TRACEVFORKDONE  = 5,
    TRACEEXIT       = 6,
    TRACESECCOMP    = 7,
    EXITKILL        = 20,
    SUSPEND_SECCOMP = 21,
}

PTrace_Event_Code :: enum {
    EVENT_FORK       = 1,
    EVENT_VFORK      = 2,
    EVENT_CLONE      = 3,
    EVENT_EXEC       = 4,
    EVENT_VFORK_DONE = 5,
    EVENT_EXIT       = 6,
    EVENT_SECCOMP    = 7,
    EVENT_STOP       = 128,
}

PTrace_Get_Syscall_Info_Op :: enum u8 {
    NONE    = 0,
    ENTRY   = 1,
    EXIT    = 2,
    SECCOMP = 3,
};

PTrace_Peek_Sig_Info_Flags_Bits :: enum {
    SHARED = 0,
}

PTrace_Options :: bit_set[PTrace_Options_Bits; u32]

PTrace_Peek_Sig_Info_Args :: struct {
    off:   u64,
    flags: PTrace_Peek_Sig_Info_Flags,
    nr:    i32,
}

PTrace_Peek_Sig_Info_Flags :: bit_set[PTrace_Peek_Sig_Info_Flags_Bits, u32]

PTrace_Seccomp_Metadata
{
    filter_off: u64,
    flags:      u64,
}

PTrace_Syscall_Info :: struct {
    op:                  PTrace_Get_Syscall_Info_Op,
    arch:                u32, // TODO: AUDIT_ARCH*
    instruction_pointer: u64,
    stack_pointer:       u64,
    using _: struct #raw_union {
        entry: struct {
            nr:       u64,
            args:     [6]u64,
        },
        exit: struct {
            rval:     i64,
            is_error: b8,
        },
        seccomp: struct {
            nr:       u64,
            args:     [6]u64,
            ret_data: u32,
        },
    };
};

PTrace_RSeq_Configuration {
    rseq_abi_pointer: u64,
    rseq_abi_size:    u32,
    signature:        u32,
    flags:            u32,
    _:                u32,
};

IO_Vec :: struct {
    base: rawptr,
    len:  uint,
}

ptrace_traceme :: proc() -> (Errno) {
    ret := linux.syscall(linux.SYS_ptrace, PTrace_Request.TRACEME)
    return Errno(-ret)
}

ptrace_getregset :: proc(pid: Pid, set: uint, dest: ^IO_Vec) -> (Errno) {
    ret := linux.syscall(linux.SYS_ptrace, PTrace_Request.GETGEGSET, set, dest)
    return Errno(-ret)
}

ptrace_singlestep :: proc(pid: Pid, signal: Signal) -> (Errno) {
    ret := linux.syscall(linux.SYS_ptrace, PTrace_Request.SINGLESTEP, 0, signal)
    return Errno(-ret)
}

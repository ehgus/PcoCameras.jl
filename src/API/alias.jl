module TypeAlias

export VOID, HANDLE, SHORT, INT, LONG, WORD, DWORD, BYTE, bool, BOOL

const VOID = Cvoid
const HANDLE = Ptr{VOID}
const SHORT = Cshort
const INT = Cint
const LONG = Clong
const WORD = Cushort
const DWORD = Culong
const BYTE = Cuchar
const bool = Cuchar
const BOOL = Cint

end
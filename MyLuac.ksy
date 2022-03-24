meta:
  id: myluac
  endian: le

seq:
  - id: magic
    contents: [0x1b, 0x4c, 0x75, 0x61]
  - id: luac_version
    type: u1
  - id: luac_format
    type: u1
  - id: luac_little_endian
    type: u1
  - id: luac_sizeof_int
    type: u1
  - id: luac_sizeof_size_t
    type: u1
  - id: luac_sizeof_instruction
    type: u1
  - id: luac_sizeof_lua_number
    type: u1
  - id: luac_number_format
    type: u1
  - id: luac_tail
    contents: [0x19, 0x93, 0x0d, 0x0a, 0x1a, 0x0a]
  - id: root_prototype
    type: prototype

types:
  prototype:
    seq:
      - id: linedefined
        type: u4
      - id: lastlinedefined
        type: u4
      - id: numparams
        type: u1
      - id: is_vararg
        type: u1
      - id: maxstacksize
        type: u1
      - id: n_ins
        type: u4
      - id: code
        type: ins_format
        repeat: expr
        repeat-expr: n_ins
        if: n_ins != 0
      - id: n_constants
        type: u4
      - id: constants
        type: constanstype
        repeat: expr
        repeat-expr: n_constants
        if: n_constants != 0
      - id: nprototype
        type: u4
      - id: prototypes
        type: prototype
        repeat: expr
        repeat-expr: nprototype
        if: nprototype != 0
      - id: upvalues
        type: upvaldesc_info
      - id: debug
        type: debug_info
        
  sprototype:
    seq:
      - id: linedefined
        type: u4
      - id: lastlinedefined
        type: u4
      - id: numparams
        type: u1
      - id: is_vararg
        type: u1
      - id: maxstacksize
        type: u1
      - id: n_ins
        type: u4
      - id: code
        type: ins_format
        repeat: expr
        repeat-expr: n_ins
        if: n_ins != 0
      - id: n_constants
        type: u4
      - id: constants
        type: constanstype
        repeat: expr
        repeat-expr: n_constants
        if: n_constants != 0
      - id: nprototype
        type: u4
      - id: prototypes
        type: sprototype
        repeat: expr
        repeat-expr: nprototype
        if: nprototype != 0
      - id: upvalues
        type: upvaldesc_info
      - id: debug
        type: debug_info
  
  
  constanstype:
    seq:
      - id: type
        type: s1
        enum: valtype
      - id: value
        type:
          switch-on: type
          cases:
            'valtype::lua_tint': constanst_int
            'valtype::lua_tnil': constanst_nil
            'valtype::lua_tboolean': constanst_boolean
            'valtype::lua_tnumber': constanst_number
            'valtype::lua_tstring': constanst_string

    enums:
      valtype:
        -2: lua_tint
        0: lua_tnil
        1: lua_tboolean
        3: lua_tnumber
        4: lua_tstring

  constanst_nil:
    instances:
      value:
        value: '"NIL"'

  constanst_boolean:
    seq:
      - id: val
        type: u1
    instances:
      value:
        value: val != 0

  constanst_number:
    seq:
      - id: val
        type: u8

  constanst_string:
    seq:
      - id: ssize
        type: u4
      - id: sstr
        type: str
        size: ssize
        encoding: UTF-8
        if: ssize != 0

  constanst_int:
    seq:
      - id: val
        type: u4

  constanst_null:
    instances:
      value:
        value: '"NULL"'
  
  upvaldesc_info:
    seq:
      - id: n_upvalues
        type: u4
      - id: noupvalues
        type: constanst_null
        if: n_upvalues == 0
      - id: upvalues
        type: upvaldesc
        repeat: expr
        repeat-expr: n_upvalues
        if: n_upvalues != 0
  
  upvaldesc:
    seq:
      - id: instack
        type: u1
      - id: idx
        type: u1
  
  debug_info:
    seq:
      - id: source
        type: constanst_string
      - id: lineinfo
        type: int_array
      - id: locvars
        type: loc_vars_info
      - id: upvalues_name
        type: upvalues_name_info
        
  int_array:
    seq:
      - id: nint
        type: u4
      - id: array
        type: u4
        repeat: expr
        repeat-expr: nint
        if: nint != 0
  
  loc_vars_info:
    seq:
      - id: nloc
        type: u4
      - id: locvars
        type: loc_vars
        repeat: expr
        repeat-expr: nloc
        if: nloc != 0
        
  
  loc_vars:
    seq:
      - id: varname
        type: constanst_string
      - id: startpc
        type: u4
      - id: endpc
        type: u4
  
  upvalues_name_info:
    seq:
      - id: nupvalues_name
        type: u4
      - id: name
        type: constanst_string
        repeat: expr
        repeat-expr: nupvalues_name
        if: nupvalues_name != 0
  
  ins_format:
    seq:
      - id: ins
        type: u4
    instances:
      op:
        value: ins & 0x3f
      a:
        value: (ins >> 6) & 0xff
      c:
        value: (ins >> 14) & 0x1ff
      b:
        value: (ins >> 23) & 0x1ff
      bx:
        value: (ins >> 14) & 0x3ffff
      ax:
        value: (ins >> 6) & 0x3ffffff

meta:
  id: lstsp
  file-extension: tsp
  endian: le

seq:
  - id: header
    type: tsp_header
  - id: data
    type: tsp_data_dict
    repeat: until
    repeat-until:  _.type == 'END'
    
types:
  tsp_header:
    seq:
      - id: format
        type: u4
      - id: version
        type: u2
        
  tsp_data_dict:
    seq:
      - id: type
        type: str
        size: 3
        encoding: UTF-8
      - id: encrypt
        type: u1
      - id: sequence
        type: u4
      - id: startpos
        type: u4
      - id: endpos
        type: u4
      - id: size
        type: u4
    instances:
      data:
        io: _root._io
        pos: startpos
        size: endpos-startpos+1
        if: endpos != 0
import fs from 'fs';

const engine = fs.readFileSync('./temp/audio/spc_engine.bin');
const BASE = 0x0200;

const opcodes = {
  0x00: ['NOP', 1], 0x02: ['SET1 dp.0', 2], 0x03: ['BBS dp.0,rel', 3],
  0x04: ['OR A,dp', 2], 0x05: ['OR A,!abs', 3], 0x06: ['OR A,(X)', 1], 0x07: ['OR A,[dp+X]', 2],
  0x08: ['OR A,#imm', 2], 0x09: ['OR dp,dp', 3], 0x0B: ['ASL dp', 2],
  0x0C: ['ASL !abs', 3], 0x0D: ['PUSH PSW', 1],
  0x10: ['BPL rel', 2], 0x12: ['CLR1 dp.0', 2], 0x13: ['BBC dp.0,rel', 3],
  0x14: ['OR A,dp+X', 2], 0x15: ['OR A,!abs+X', 3], 0x16: ['OR A,!abs+Y', 3], 0x17: ['OR A,[dp]+Y', 2],
  0x18: ['OR dp,#imm', 3], 0x19: ['OR (X),(Y)', 1], 0x1A: ['DECW dp', 2], 0x1B: ['ASL dp+X', 2],
  0x1C: ['ASL A', 1], 0x1D: ['DEC X', 1], 0x1F: ['JMP [!abs+X]', 3],
  0x20: ['CLRP', 1], 0x22: ['SET1 dp.1', 2], 0x23: ['BBS dp.1,rel', 3],
  0x24: ['AND A,dp', 2], 0x25: ['AND A,!abs', 3], 0x27: ['AND A,[dp+X]', 2],
  0x28: ['AND A,#imm', 2], 0x29: ['AND dp,dp', 3], 0x2B: ['ROL dp', 2],
  0x2D: ['PUSH A', 1], 0x2E: ['CBNE dp,rel', 3], 0x2F: ['BRA rel', 2],
  0x30: ['BMI rel', 2], 0x32: ['CLR1 dp.1', 2], 0x33: ['BBC dp.1,rel', 3],
  0x38: ['AND dp,#imm', 3], 0x3A: ['INCW dp', 2],
  0x3C: ['ROL A', 1], 0x3D: ['INC X', 1], 0x3E: ['CMP X,dp', 2], 0x3F: ['CALL !abs', 3],
  0x42: ['SET1 dp.2', 2], 0x43: ['BBS dp.2,rel', 3],
  0x44: ['EOR A,dp', 2], 0x45: ['EOR A,!abs', 3],
  0x48: ['EOR A,#imm', 2], 0x49: ['EOR dp,dp', 3], 0x4B: ['LSR dp', 2],
  0x4D: ['PUSH X', 1], 0x4E: ['TCLR1 !abs', 3],
  0x50: ['BVC rel', 2], 0x52: ['CLR1 dp.2', 2], 0x53: ['BBC dp.2,rel', 3],
  0x58: ['EOR dp,#imm', 3], 0x5A: ['CMPW YA,dp', 2],
  0x5C: ['LSR A', 1], 0x5D: ['MOV X,A', 1], 0x5F: ['JMP !abs', 3],
  0x60: ['CLRC', 1], 0x62: ['SET1 dp.3', 2], 0x63: ['BBS dp.3,rel', 3],
  0x64: ['CMP A,dp', 2], 0x65: ['CMP A,!abs', 3], 0x67: ['CMP A,[dp+X]', 2],
  0x68: ['CMP A,#imm', 2], 0x69: ['CMP dp,dp', 3],
  0x6B: ['ROR dp', 2], 0x6D: ['PUSH Y', 1], 0x6E: ['DBNZ dp,rel', 3], 0x6F: ['RET', 1],
  0x70: ['BVS rel', 2], 0x72: ['CLR1 dp.3', 2], 0x73: ['BBC dp.3,rel', 3],
  0x74: ['CMP A,dp+X', 2], 0x75: ['CMP A,!abs+X', 3], 0x76: ['CMP A,!abs+Y', 3], 0x77: ['CMP A,[dp]+Y', 2],
  0x78: ['CMP dp,#imm', 3], 0x79: ['CMP (X),(Y)', 1], 0x7A: ['ADDW YA,dp', 2],
  0x7C: ['ROR A', 1], 0x7D: ['MOV A,X', 1], 0x7E: ['CMP Y,dp', 2], 0x7F: ['RETI', 1],
  0x80: ['SETC', 1], 0x82: ['SET1 dp.4', 2], 0x83: ['BBS dp.4,rel', 3],
  0x84: ['ADC A,dp', 2], 0x85: ['ADC A,!abs', 3], 0x87: ['ADC A,[dp+X]', 2],
  0x88: ['ADC A,#imm', 2], 0x89: ['ADC dp,dp', 3],
  0x8B: ['DEC dp', 2], 0x8D: ['MOV Y,#imm', 2], 0x8E: ['POP PSW', 1], 0x8F: ['MOV dp,#imm', 3],
  0x90: ['BCC rel', 2], 0x92: ['CLR1 dp.4', 2], 0x93: ['BBC dp.4,rel', 3],
  0x94: ['ADC A,dp+X', 2], 0x95: ['ADC A,!abs+X', 3], 0x96: ['ADC A,!abs+Y', 3], 0x97: ['ADC A,[dp]+Y', 2],
  0x98: ['ADC dp,#imm', 3], 0x99: ['ADC (X),(Y)', 1], 0x9A: ['SUBW YA,dp', 2], 0x9B: ['DEC dp+X', 2],
  0x9C: ['DEC A', 1], 0x9D: ['MOV X,A', 1], 0x9E: ['DIV YA,X', 1], 0x9F: ['XCN A', 1],
  0xA4: ['SBC A,dp', 2], 0xA5: ['SBC A,!abs', 3], 0xA7: ['SBC A,[dp+X]', 2],
  0xA8: ['SBC A,#imm', 2], 0xA9: ['SBC dp,dp', 3],
  0xAB: ['INC dp', 2], 0xAD: ['CMP Y,#imm', 2], 0xAE: ['POP A', 1], 0xAF: ['MOV (X)+,A', 1],
  0xB0: ['BCS rel', 2], 0xB2: ['CLR1 dp.5', 2], 0xB3: ['BBC dp.5,rel', 3],
  0xB4: ['SBC A,dp+X', 2], 0xB5: ['SBC A,!abs+X', 3], 0xB6: ['SBC A,!abs+Y', 3], 0xB7: ['SBC A,[dp]+Y', 2],
  0xB8: ['SBC dp,#imm', 3], 0xBA: ['MOVW YA,dp', 2], 0xBB: ['INC dp+X', 2],
  0xBC: ['INC A', 1], 0xBD: ['MOV SP,X', 1], 0xBF: ['MOV A,(X)+', 1],
  0xC4: ['MOV dp,A', 2], 0xC5: ['MOV !abs,A', 3], 0xC6: ['MOV (X),A', 1], 0xC7: ['MOV [dp+X],A', 2],
  0xC8: ['CMP X,#imm', 2], 0xC9: ['MOV !abs,X', 3],
  0xCB: ['MOV dp,Y', 2], 0xCC: ['MOV !abs,Y', 3], 0xCD: ['MOV X,#imm', 2], 0xCE: ['POP X', 1], 0xCF: ['MUL YA', 1],
  0xD0: ['BNE rel', 2], 0xD2: ['CLR1 dp.6', 2], 0xD3: ['BBC dp.6,rel', 3],
  0xD4: ['MOV dp+X,A', 2], 0xD5: ['MOV !abs+X,A', 3], 0xD6: ['MOV !abs+Y,A', 3], 0xD7: ['MOV [dp]+Y,A', 2],
  0xD8: ['MOV dp,X', 2], 0xDA: ['MOVW dp,YA', 2], 0xDB: ['MOV dp+X,Y', 2],
  0xDC: ['DEC Y', 1], 0xDD: ['MOV A,Y', 1], 0xDE: ['CBNE dp+X,rel', 3],
  0xE0: ['CLRV', 1], 0xE2: ['SET1 dp.7', 2], 0xE3: ['BBS dp.7,rel', 3],
  0xE4: ['MOV A,dp', 2], 0xE5: ['MOV A,!abs', 3], 0xE6: ['MOV A,(X)', 1], 0xE7: ['MOV A,[dp+X]', 2],
  0xE8: ['MOV A,#imm', 2], 0xE9: ['MOV X,dp', 2],
  0xEB: ['MOV Y,dp', 2], 0xEC: ['MOV Y,!abs', 3], 0xED: ['NOTC', 1], 0xEE: ['POP Y', 1],
  0xF0: ['BEQ rel', 2], 0xF2: ['CLR1 dp.7', 2], 0xF3: ['BBC dp.7,rel', 3],
  0xF4: ['MOV A,dp+X', 2], 0xF5: ['MOV A,!abs+X', 3], 0xF6: ['MOV A,!abs+Y', 3], 0xF7: ['MOV A,[dp]+Y', 2],
  0xF8: ['MOV X,dp', 2], 0xF9: ['MOV X,dp+X', 2], 0xFA: ['MOV dp,dp', 3], 0xFB: ['MOV Y,dp+X', 2],
  0xFC: ['INC Y', 1], 0xFD: ['MOV Y,A', 1], 0xFE: ['DBNZ Y,rel', 2], 0xFF: ['STOP', 1],
};

function disasm(start, len) {
  let off = start;
  while (off < start + len && off < engine.length) {
    const b = engine[off];
    const info = opcodes[b];
    const addr = BASE + off;
    
    if (!info) {
      console.log(addr.toString(16).padStart(4, '0') + ': ' + b.toString(16).padStart(2, '0') + '          ???');
      off++; continue;
    }
    
    const sz = info[1];
    const hex = Array.from(engine.subarray(off, off + sz)).map(b => b.toString(16).padStart(2, '0')).join(' ');
    let text = info[0];
    
    if (sz === 2) {
      const op = engine[off + 1];
      text = text.replace('#imm', '#$' + op.toString(16).padStart(2, '0'));
      text = text.replace(/rel$/, '$' + (addr + 2 + (op > 127 ? op - 256 : op)).toString(16).padStart(4, '0'));
      text = text.replace(/dp(\.[0-7])?/, (m) => '$' + op.toString(16).padStart(2, '0') + (m.includes('.') ? m.slice(2) : ''));
    } else if (sz === 3) {
      const lo = engine[off + 1], hi = engine[off + 2];
      const w = lo | (hi << 8);
      text = text.replace('!abs', '!$' + w.toString(16).padStart(4, '0'));
      text = text.replace(/dp,#imm/, '$' + lo.toString(16).padStart(2, '0') + ',#$' + hi.toString(16).padStart(2, '0'));
      text = text.replace(/dp,dp/, '$' + hi.toString(16).padStart(2, '0') + ',$' + lo.toString(16).padStart(2, '0'));
      if (text.includes(',rel')) {
        const rel = hi > 127 ? hi - 256 : hi;
        text = text.replace(',rel', ',$' + (addr + 3 + rel).toString(16).padStart(4, '0'));
      }
      // For dp in first position with bit ops
      if (text.includes('dp')) {
        text = text.replace('dp', '$' + lo.toString(16).padStart(2, '0'));
      }
    }
    
    console.log(addr.toString(16).padStart(4, '0') + ': ' + hex.padEnd(10) + text);
    off += sz;
  }
}

console.log('=== Sequence byte reader ($0893) ===');
disasm(0x693, 0x20);

console.log('\n=== Main parsing loop ($05B0-$0640) ===');
disasm(0x3B0, 0x90);

console.log('\n=== Note/rest handler ($0511-$0570) ===');
disasm(0x311, 0x70);

console.log('\n=== Command dispatch ($0881) ===');
disasm(0x681, 0x20);

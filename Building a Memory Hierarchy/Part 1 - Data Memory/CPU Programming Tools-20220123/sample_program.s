loadi 2 0x09    // store the value in r2 = 9
swi   2 0x04    // store the reg(r2) value in memory address in 0x04
lwi   4 0x04    // load the value in memory address 0x04 and store in reg 4 // r4 = 4; 
add 0 4 2       // r0 = r4 + r2 // r0 = 9 + 9 = 18

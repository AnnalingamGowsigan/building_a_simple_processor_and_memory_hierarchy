loadi 0 0x09    // r0 = 9
j  0x01 
loadi 1 0x09    // r1 = 9
loadi 1 0x10    // r1 = 10
beq 0x01 1 0
loadi 2 0x10    // r2 = 9
beq 0x01 2 1     
//add   3 1 0     // 10+9
//sub   3 1 0     // 10-9

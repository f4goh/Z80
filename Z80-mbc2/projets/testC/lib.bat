rem sans irq
rem sdcc -c -mz80 S290923_Z80-MBC2.c 
rem avec irq
rem sdcc -c -mz80 -DZ80MBC2IRQ S290923_Z80-MBC2.c

sdasz80 -plosgff -o S190818-R011023_crt0.s

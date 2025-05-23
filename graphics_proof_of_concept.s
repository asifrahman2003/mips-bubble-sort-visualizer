.data

# assumes a 64x64 display.  To set this up, do the following steps:
#    - Tools->Bitmap Display
#    - Set "Unit width/height in pixels" to 8
#    - Set "Display width/height in pixels" to 512
#    - Set "Base Address for display" to static data
#    - Click "Connect to MIPS" *after* the rest are set

DISPLAY:
	.space  16384
END_OF_DISPLAY:
.text


main:
	la      $t0, DISPLAY
	addi    $t1, $zero,-1
	sw      $t1, 0($t0)       # row 0, col 0
	sw      $t1, 512($t0)     # row 2, col 0
	
	la      $t2, END_OF_DISPLAY
	lui     $t3, 0xff
	sw      $t3, -4($t2)      # row 63, col 63
	
LOOP:
	j       LOOP
	

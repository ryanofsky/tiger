# "Hello World" for the SPIM simulator

	.data
st1:
	.asciiz	"Hello, World!\n"

	.text
	.globl	main
main:
	li	$v0, 4		# Code for print_str
        la	$a0, st1	# Load address of string constant
	syscall

	li	$v0, 10		# Code for exit
	syscall			# Terminate the program
	

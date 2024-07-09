.data
prompt: .asciiz "Please enter a 10-character string: "
input: .space 11            # Space for the input string (10 characters + null terminator)
invalid_msg: .asciiz "N/A"  # Message for invalid input
sum_msg: .asciiz "The sum is: "  # Message to display before the sum

.text
.globl main

main:
    # Print the prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Read the string of 10 characters
    li $v0, 8
    la $a0, input
    li $a1, 11             # 10 characters + null terminator
    syscall

    # Initialize sums and other variables
    li $t0, 0             # Sum of characters at even indices (G)
    li $t1, 0             # Sum of characters at odd indices (H)
    li $t2, 0             # Current index in input string
    li $t3, 0             # Count of valid characters

    # Constants
    li $t6, 22            # M = 22 (calculated from student ID)
    li $t7, 32            # N = 32 (calculated from student ID)

    # Process each character
    la $t4, input         # Load address of input string
process_loop:
    lb $t5, 0($t4)        # Load character from input string
    beqz $t5, end_process # Null terminator

    # Check if character is a valid digit or letter
    li $t8, '0'
    li $t9, '9'
    blt $t5, $t8, check_lowercase
    bgt $t5, $t9, check_lowercase
    sub $t5, $t5, $t8     # Convert char to int value (0 = 0, ..., 9 = 9)
    j update_sum

check_lowercase:
    li $t8, 'a'
    li $t9, 'v'           # 'v' is the 22nd lowercase letter
    blt $t5, $t8, check_uppercase
    bgt $t5, $t9, check_uppercase
    sub $t5, $t5, $t8     # Convert char to int value (a = 0, b = 1, ..., v = 21)
    addi $t5, $t5, 10     # Adjust value to match the sum calculation (a = 10, ..., v = 31)
    j update_sum

check_uppercase:
    li $t8, 'A'
    li $t9, 'V'           # 'V' is the 22nd uppercase letter
    blt $t5, $t8, invalid_char
    bgt $t5, $t9, invalid_char
    sub $t5, $t5, $t8     # Convert char to int value (A = 0, B = 1, ..., V = 21)
    addi $t5, $t5, 10     # Adjust value to match the sum calculation (A = 10, ..., V = 31)
    j update_sum

invalid_char:
    addi $t4, $t4, 1      # Move to next character
    j process_loop

update_sum:
    # Check if the index is even or odd and update sums
    rem $t9, $t2, 2       # Calculate $t2 % 2
    beqz $t9, even_index  # If even
    add $t1, $t1, $t5     # Update H
    j continue_process

even_index:
    add $t0, $t0, $t5     # Update G

continue_process:
    addi $t2, $t2, 1      # Increment index
    addi $t4, $t4, 1      # Move to next character
    j process_loop

end_process:
    # Ensure the input length is 10 characters
    bne $t2, 10, print_invalid

    # Calculate G - H
    sub $t0, $t0, $t1

    # Print "The sum is:"
    li $v0, 4
    la $a0, sum_msg
    syscall

    # Print the result
    move $a0, $t0         # Move result to $a0 for printing
    li $v0, 1
    syscall

    j exit_program

print_invalid:
    # Print "N/A" and exit
    li $v0, 4
    la $a0, invalid_msg
    syscall

exit_program:
    # Exit
    li $v0, 10
    syscall

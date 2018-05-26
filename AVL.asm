.data			      # |4bits|4bits|4bits|4bits|
	estrutura: .space 1024  # |valor|sbe|sbd|altura|
	fileInput: .asciiz "tree.in"
	fileOutput: .asciiz "tree.out"
	pular_Linha: .asciiz "\n"
	buffer: .space 20
	int: .space 1024
	
.text
#ARQUIVO IN - Deve estar escrito em HEX
#ARQUIVO OUT- Escrito em HEx


j main
########
##Main##
########
	main:
		
		jal file_open
		jal file_read
		jal file_close
		
		la $s1, int #estrutura para salvar		
		
		la $s5, estrutura #root node
		la $s6, ($s5) 	  #atual position in the array
		
		la $t0, buffer #k
		lb $t1, ($t0)
		add $t0, $t0, 2
		lb $t2, ($t0)
		#semente 
		la $t8, ($t2)
		#tamanho max 
		la $a3, ($t1)
		
		li $s7,0
		li $t5, 0 #sem raiz
		loop:
			beq $s7, $a3, sair
			
			
			la $a0, ($t8)
			jal random
			
			la $a1, ($v0) #valor
			la $a0, ($t5)#raiz
			jal insere
			
			la $t5, ($v0) #nova raiz
			addi $s7, $s7, 1 
			#addi $t5, $t6, -16
		j loop
		

		sair:			
			la $s5,($t5) #novo root node
			la $a0, ($s5)
			jal posOrder
			
			j exit

########
##Tree##
########
	
	no:
		la $t0, 0	#sbe
		la $t1, 0	#sbd
		la $t2, 1	#altura
		
		sw $a0, 0($s6)	 #valor 
		sb $t0, 4($s6)	 #sbe
		sb $t1, 8($s6)   #sbd
		sb $t2, 12($s6)	 #altura	
		
		add $s6, $s6 ,16 
		
		jr $ra
		
	insere:

		la $t0, ($a0) #no
		la $s0, ($t0) #salvar pra geral
		la $t1, ($a1) #chave
		bnez $t0, ElSEI1
			#se nao existir a raiz ela cria a raiz
				addiu   $sp,$sp,-12     # aloca 3 posições na pilha
		        	sw      $t1, 8($sp)	# empilha 
        			sw	$t0, 4($sp)	# empilha 
			        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			        
			        la $a0, ($t1)
			        
				jal no
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        		lw      $t0,4($sp)      
	        		lw      $t1,8($sp)
	        		addiu   $sp,$sp,12
	        		
			        la $t6, ($s6)
				addi $t5, $t6, -16
				
				la $v0, ($t5)
				
				jr $ra
		ElSEI1: 
			#se existir raiz
			lw $t3, 0($t0)	 #valor
			
			bne $t1, $t3,note
				#nao ha nos com valores iguais
				la $v0, ($t0)
	       			jr $ra
			
			note:bgt $t1, $t3, ELSEIF #esquerda
			
				addiu   $sp,$sp,-12     # aloca 3 posições na pilha
		        	sw      $t1, 8($sp)	# empilha 
        			sw	$t0, 4($sp)	# empilha 
			        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			        
				lw $t2, 4($t0)	#esquerda
				la $a0, ($t2)	#no
				la $a1, ($t1)	#key
				
				jal insere
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        		lw      $t0,4($sp)      
	        		lw      $t1,8($sp)
	        		addiu   $sp,$sp,12			
				
				sw $v0, 4($t0)
				b alturaI
                		
			ELSEIF:#direita
				addiu   $sp,$sp,-12     # aloca 3 posições na pilha
		        	sw      $t1, 8($sp)	# empilha 
        			sw	$t0, 4($sp)	# empilha 
			        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			        
				lw $t2, 8($t0)	#direita
				la $a0, ($t2)	#no
				la $a1, ($t1)	#key
				
				jal insere
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        		lw      $t0,4($sp)      
	        		lw      $t1,8($sp)
	        		addiu   $sp,$sp,12			
				
				sw $v0, 8($t0)
				
				b alturaI

	       		
	       			
			#altura calculo
			alturaI: addiu   $sp,$sp,-16     # aloca 4 posições na pilha
			sw	$t1, 12($sp)
			sw	$t0, 8($sp)
			sw	$t5, 4($sp)
			sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO		
			

			lw $a0, 4($t0) #no pai
			la $t4, ($t0)  #salvar o no pai
			jal altura
			la $t2, ($v0) # a
			

			lw $a0, 8($t4) #no pai
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t1, ($v0)
			addi $t1,$t1,1
			
			sb $t1, 12($t4) #no pai que recebe
			
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			lw	$t5, 4($sp)
			lw	$t0, 8($sp)
			lw	$t1, 12($sp)
			addiu   $sp,$sp,16
			
			#balanceamento
			addiu   $sp,$sp,-16     # aloca 4 posições na pilha
			sw	$t1, 12($sp)
			sw	$t0, 8($sp)
			sw	$t5, 4($sp)
			sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			la 	$s5, ($ra)
		
		        la $a0, ($t0)
			
			jal getBalance
			
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			lw	$t5, 4($sp)
			lw	$t0, 8($sp)
			lw	$t1, 12($sp)
			addiu   $sp,$sp,16
			
			la $t2, ($v0)
			la $s0, ($t0)
			
			#left left case
			ble $t2, 1, rightright
				lw $t4, 4($t0)
				lw $t4, 0($t0) #left key
				bgt $t1, $t4,rightright
					la $a0, ($t0)
					jal rot_direita
					la $s0, ($v0)
					j volt
					
			#right right case
			rightright: bge $t2, -1, leftright
				lw $t4, 8($t0)
				lw $t4, 0($t4) #right key
				blt $t1,$t4,leftright
				
					la $a0, ($s0)
					jal rot_esquerda
					la $s0, ($v0)
					j volt

			leftright: ble $t2, 1, rightleft
				lw $t4, 8($t0)
				lw $t4, 0($t0) #right key
				blt $t4, $t1,rightleft
					
					lw $t0, 4($s0)
					la $a0, ($t0)
					jal rot_esquerda
					
					sw $v0, 4($s0)
					
					la $a0, ($s0)
					jal rot_direita	
												
					la $s0, ($v0)
					j volt
			
        		rightleft: bge $t2, -1, volt
        			
        			li $v0, -1
        			bgt $t2, $v0, volt
				lw $t4, 8($t0)
				lw $t4, 0($t4) #right key
				bgt $t1, $t4,volt
					
					lw $t0, 8($s0)
					la $a0, ($t0)
					jal rot_direita
					
					sw $v0, 8($s0)
					
					la $a0, ($s0)
					jal rot_esquerda
												
					la $s0, ($v0)
					j volt 
			
			volt:
			#return node
			la $v0, ($s0) #problema aqui
			la $ra, ($s5)
			jr $ra
   
	altura: 
			la $t0, ($a0) #no
			
			bne $t0,$zero ELSEA
				li $v0, 0 # no==NULL
				jr $ra
			ELSEA:
				lb $t1, 12($t0)
				la $v0, ($t1)
				jr $ra
 	max:
			la $t0, ($a0) # a
			la $t1, ($a1) #b	
			
			blt $t0, $t1 , ELSEMAX
				la $v0, ($t0)  # a>b
				jr $ra
			ELSEMAX:
				la $v0, ($t1) #a<b
				jr $ra
			

	getBalance:
			la $t0,($a0)	
			bnez $t0, prox
				li $v0, 0
				jr $ra
			prox:
				addiu   $sp,$sp,-8     # aloca 2 posições na pilha
				sw	$t0, 4($sp)
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				
				lw $a0, 4($t0) #esq
				jal altura
				la $t4, ($v0) # a
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t0, 4($sp)
				addiu   $sp,$sp,8
				
				lw $a0, 8($t0) #dir
				
				addiu   $sp,$sp,-8     # aloca 2 posições na pilha
				sw	$t0, 4($sp)
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				
				jal altura
				la $t2, ($v0) # b
			
				sub $t3, $t4, $t2
				
				la $v0, ($t3)
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t0, 4($sp)
				addiu   $sp,$sp,8
				jr $ra

	rot_esquerda:
			
			la $t0, ($a0) #x   
			lw $t1, 8($t0)  
			lw $t2, 4($t1)	

    			# Perform rotation
    			sw $t0, 4($t1)
			sw $t2, 8($t0)
			
 
    			#Update heights
    			
    			#X
    			
			addiu   $sp,$sp,-4     # aloca 1 posições na pilha
			sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			
			addiu   $sp,$sp,-12     # aloca 3 posições na pilha
 			sw	$t2, 8($sp)
 			sw	$t1, 4($sp)
			sw      $t0, 0($sp)	# empilha o endereço de retorno par ao SO
			
			
			lw $a0, 4($t0) 
			la $s2,($t0)
			jal altura
			la $t2, ($v0) # a
			
			
			lw $a0, 8($s2) #dir
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t5, ($v0)
			addi $t5,$t5,1
			
			lw $t0, 0($sp)
			lw $t1, 4($sp)
			lw $t2, 8($sp)
			addiu $sp, $sp, 12
			
			sb $t5, 12($t0)
			 
			
			#y
			
 			addiu   $sp,$sp,-12     # aloca 3 posições na pilha
 			sw	$t2, 8($sp)
 			sw	$t1, 4($sp)
			sw      $t0, 0($sp)	# empilha o endereço de retorno par ao SO
 			
 			la $t7, ($t1)
 			lw $a0, 4($t7) #dir
			jal altura
			la $t2, ($v0) # a
			
			lw $a0, 8($t7) #dir
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t5, ($v0)
			addi $t5,$t5,1
		
			lw $t0, 0($sp)
			lw $t1, 4($sp)
			lw $t2, 8($sp)
			addiu $sp, $sp, 12
			
			sb $t5, 12($t1)
 			
    			#Return new root
			la $v0, ($t1)
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			addiu   $sp,$sp,4
			jr $ra
			
	rot_direita:	##analisar agora aqui
			
			la $t0, ($a0)   #y
			lw $t1, 4($t0)  #x=y->esq
			lw $t2, 8($t1)	#T2=y->esq->dir	

    			# Perform rotation
    			sw $t0, 8($t1)
			sw $t2, 4($t0)
			
 
    			#Update heights
    			
    			addiu   $sp,$sp,-4     # aloca 1 posições na pilha
			sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			la $t9, ($ra)
			
			#y
			
 			addiu   $sp,$sp,-12     # aloca 3 posições na pilha
 			sw	$t2, 8($sp)
 			sw	$t1, 4($sp)
			sw      $t0, 0($sp)	# empilha o endereço de retorno par ao SO
 			
 			la $t7, ($t0)
 			lw $a0, 4($t7) #dir
			jal altura
			la $t2, ($v0) # a
			
			lw $a0, 8($t7) #dir
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t5, ($v0)
			addi $t5,$t5,1
		
			lw $t0, 0($sp)
			lw $t1, 4($sp)
			lw $t2, 8($sp)
			addiu $sp, $sp, 12
			
			sb $t5, 12($t0)
 			
 			#x
 						
			addiu   $sp,$sp,-12     # aloca 3 posições na pilha
 			sw	$t2, 8($sp)
 			sw	$t1, 4($sp)
			sw      $t0, 0($sp)	# empilha o endereço de retorno par ao SO
			
			
			lw $a0, 4($t1) 
			la $s2,($t1)
			jal altura
			la $t2, ($v0) # a
			
			
			lw $a0, 8($s2) #dir
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t5, ($v0)
			addi $t5,$t5,1
			
			lw $t0, 0($sp)
			lw $t1, 4($sp)
			lw $t2, 8($sp)
			addiu $sp, $sp, 12
			
			sb $t5, 12($t0)

    			#Return new root
			la $v0, ($t1)
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			addiu   $sp,$sp,4
			la $ra, ($t9)
			jr $ra
		
	posOrder:
			la $t0, ($a0)
			beqz $t0, sairOrder

				#esquerda
				lw $t1, 4($t0)
				addiu   $sp,$sp,-12     # aloca 5 posições na pilha
				sw	$t0, 8($sp)
				sw	$t1, 4($sp)
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO

				
				la $a0, ($t1)
				jal posOrder
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t1,4($sp)
				lw	$t0,8($sp)
				addiu   $sp,$sp,12
				
				
				#direita
				lw $t2, 8($t0)
        			addiu   $sp,$sp,-12     # aloca 5 posições na pilha
				sw	$t0, 8($sp)
				sw	$t1, 4($sp)
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				
				la $a0, ($t2)
				jal posOrder
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t1,4($sp)
				lw	$t0,8($sp)
				addiu   $sp,$sp,12
        			
        			
        			
        			lw $t0, 0($t0) #escrever o valor em t0 pra printar 
			        la $t1, ($t0)
			        addiu   $sp,$sp,-4     # aloca 1 posições na pilha
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				
				la $a0, ($t1)
			        jal fout
			        jal printString
			        
			        lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				addiu   $sp,$sp,4
			sairOrder:
				
				jr $ra

	

##########
##random##
##########
	random:
		la $t2, ($a0)
		addi $v0, $zero, 30     # Syscall 30: System Time syscall
		syscall                 # $a0 will contain the 32 LS bits of the system time
		add $t0, $zero, $a0     # Save $a0 value in $t0 

		addi $v0, $zero, 40      # Syscall 40: Random seed
		add $a0, $zero, $zero   # Set RNG ID to 0
		add $a1, $zero, $t0     # Set Random seed to
		syscall

		addi $v0, $zero, 42      # Syscall 42: Random int range
		add $a0, $zero, $t2      # Set RNG ID to 0
		addi $a1, $zero, 10000     # Set upper bound to 4 (exclusive)
		syscall                  # Generate a random number and put it in $a0
		add $v0, $zero, $a0      # Copy the random number to $s1 and return $v0
		
		jr $ra


############
##arquivos##
############
		
	fout:
		la $t0, ($a0)
		#alinhamento de memoria
		div $t2, $s1, 4
		mfhi $t2
		beqz $t2, cont
			add $s1, $s1, 1
		cont:sw $t0, 0($s1)
		addi $s1, $s1, 4 
		jr $ra
		
		
	file_open:
		li $v0, 13 #system call for open file
		la $a0, fileInput #board file name
		li $a1,0 #open for reading
		li $a2, 0
		syscall #open a file
		move $s6, $v0 #save the file descriptor
		jr $ra
		
	file_write:
		###############################################################
  		# Open (for writing) a file that does not exist
		li   $v0, 13       # system call for open file
		la   $a0, fileOutput     # output file name
		li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
		li   $a2, 0        # mode is ignored
		syscall            # open a file (file descriptor returned in $v0)
		move $s6, $v0      # save the file descriptor 
		###############################################################
		# Write to file just opened
		li   $v0, 15       # system call for write to file
		move $a0, $s6      # file descriptor 
		la $t0, int
		#add $t0, $t0, 2
		la   $a1, ($t0)   # address of buffer from which to write
		li   $a2, 32      # hardcoded buffer length
		syscall            # write to file
		###############################################################
		# Close the file 
		li   $v0, 16       # system call for close file
		move $a0, $s6      # file descriptor to close
		syscall            # close file
		###############################################################
		
	file_read:
		li $v0, 14 #sytem call for rad from file
		move $a0, $s6 #file descriptor
		la $a1, buffer #address of buffer to which to read
		li $a2, 1024 # hardcoded buffer length
		syscall
		jr $ra
		
	file_close:
		li $v0, 16 # $a0 already has the file descriptor
		move $a0, $s6 # file descriptor to close	
		syscall # read from file
		jr $ra
##########
##System##
##########
	printString:
		li $v0, 1
		la $a0, ($t1)
		syscall
		
		li $v0, 4
		la $a0, pular_Linha
		syscall
		
		jr $ra
	printInt:
		li $v0, 1
		la $a0, ($t1)
		syscall
	exit:
		
		jal file_write
		li $v0, 10		# system call code for exit = 10
		syscall

.data			      # |4bits|4bits|4bits|4bits|
	estrutura: .space 1024  # |valor|sbe|sbd|altura|
	fileInput: .asciiz "tree.in"
	fileOutput: .asciiz "tree.out"
	buffer: .space 1024
	ola: .asciiz "oi amigo"
	
.text

###obs percorrer em pos fixa e salvar no vetor e depois salvar o vetor em arquivo

#################################################################
#$v0-$v1 - expressoes de avaliação e retorno de funcoes #values	#
#$a0-$a3 - parametros de subrotinas #arguments			#
#$t0-t7 -  variaveis temporarias #temporaries			#
#$s0-$s7 - variaveis globais #savede calue			#
#$t8-$t9 - temporarias#temporaries				#
#$gp - ponteiro global						#
#$sp - ponteiro pilha						#
#$s8/$fp - saved value/frame pointe				#
#################################################################


j main
########
##Main##
########
	#$s5- Root
	main:
		la $s5, estrutura #root node
		la $s6, ($s5) 	  #atual position in the array
		
		#jal random
		la $a0, 10	  #valor 
		jal no	
		
		li $s7,20
		la $t5, ($s5)
		loop:
			beq $s7, 60, sair
			
			#jal random
			la $a1, ($s7) #valor
			la $a0, ($t5)#raiz
			jal insere
			
			la $t5, ($v0) #nova raiz
			
			addi $s7, $s7, 10 
			#addi $t5, $t6, -16
		j loop
		

		sair:j exit

########
##Tree##
########
	
	no:
		la $t0, 0	#sbe
		la $t1, 0	#sbd
		la $t2, 0	#altura
		
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
			        
				lw $t2, 8($t0)	#esquerda
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
			
			la $t1, ($t5)
			lw $a0, 4($t1)
			jal altura
			la $t2, ($v0) # a
			
			la $t1, ($t5)
			lw $a0, 8($t1)
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t1, ($v0)
			addi $t1,$t1,1
			
			sb $t1, 12($t5) 
			
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
			blt $t2, 1, rightright
				lw $t4, 4($t0)
				lw $t4, 0($t0) #left key
				bgt $t1, $t4,rightright
					la $a0, ($t0)
					jal rot_direita
					la $t5, ($v0)
					j volt
					
			#right right case
			rightright: bgt $t2, -1, leftright
				lw $t4, 8($t0)
				lw $t4, 0($t0) #right key
				blt $t1,$t4,leftright
				
					la $a0, ($s0)
					jal rot_esquerda
					la $t5, ($v0)
					j volt

			leftright: blt $t2, 1, rightleft
				lw $t4, 8($t0)
				lw $t4, 0($t0) #right key
				blt $t4, $t1,rightleft
					
					lw $t0, 4($s0)
					la $a0, ($t0)
					jal rot_esquerda
					
					sw $v0, 4($s0)
					
					la $a0, ($s0)
					jal rot_direita	
												
					la $t5, ($v0)
					j volt
			
        		rightleft:
        			
        			li $v0, -1
        			bgt $t2, $v0, volt
				lw $t4, 8($t0)
				lw $t4, 0($t0) #right key
				bgt $t4, $t1,volt
					
					lw $t0, 8($s0)
					la $a0, ($t0)
					jal rot_direita
					
					sw $v0, 8($s0)
					
					la $a0, ($s0)
					jal rot_esquerda
												
					la $t5, ($v0)
					j volt 
			
			volt:
			#return node
			la $v0, ($t5)
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
			la $t1, ($a0) #b	
			
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
				
				#t1esquerda
				#t2direita
				#t3 subt
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
			
			
			lw $a0, 4($s0) #esq
			jal altura
			la $t2, ($v0) # a
			
			
			lw $a0, 8($s0) #dir
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
			
 			lw $a0, 4($t1) #esq
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
			
			sb $t5, 12($t0)
 			
    			#Return new root
			la $v0, ($t1)
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			addiu   $sp,$sp,4
			jr $ra
			
	rot_direita:
			
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
			
 			lw $a0, 4($t1) #esq
 			
 			addiu   $sp,$sp,-12     # aloca 3 posições na pilha
 			sw	$t2, 8($sp)
 			sw	$t1, 4($sp)
			sw      $t0, 0($sp)	# empilha o endereço de retorno par ao SO
 			
 			
			jal altura
			la $t2, ($v0) # a
			

			lw $a0, 8($t1) #dir
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
 			
 			#x
 			addiu   $sp,$sp,-12     # aloca 1 posições na pilha
 			sw	$t2, 8($sp)
 			sw	$t1, 4($sp)
			sw      $t0, 0($sp)	# empilha o endereço de retorno par ao SO
 			
 			
 			lw $a0, 4($t0) #esq
 			la $t8, ($t0)
			jal altura
			la $t2, ($v0) # a
			
			lw $a0, 8($t8) #dir
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
				addiu   $sp,$sp,-8     # aloca 5 posições na pilha
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				sw	$t1, 4($sp)
				
				la $a0, ($t1)
				jal posOrder
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t1,4($sp)
				addiu   $sp,$sp,8
				
				
				#direita
				lw $t2, 8($t0)
        			addiu   $sp,$sp,-8     # aloca 5 posições na pilha
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				sw	$t2, 4($sp)
				
				la $a0, ($t2)
				jal posOrder
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t2,4($sp)
				addiu   $sp,$sp,8
        			
        			
        			
			        la $t1, ($t0)
			        addiu   $sp,$sp,-4     # aloca 1 posições na pilha
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				
			        jal printString
			        
			        lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				addiu   $sp,$sp,4
			sairOrder:
				
				jr $ra

	

##########
##random##
##########
	random:
		li $v0, 42  # 42 is system call code to generate random int
		li $a1, 10000 # $a1 is where you set the upper bound
		syscall     # your generated number will be at $a0
		jr $ra


############
##arquivos##
############

	file_open:
		li $v0, 13 #system call for open file
		la $a0, fileInput #board file name
		li $a1,0 #open for reading
		li $a2, 0
		syscall #open a file
		move $s6, $v0 #save the file descriptor
		jr $ra
		
	file_write:
		li $v0,13           # open_file syscall code = 13
    		la $a0,fileOutput # get the file name
    		li $a1,9            # file flag = write
    		li $a2, 0	# Mode 
    		syscall
    		move $s6,$v0        # save the file descriptor 

    				       #write into the file
    		li $v0, 15             # write_file syscall code = 15
    		move $a0, $s6          # file descriptor (fileName)
    		
    		la $a1, ($t7)          # the text that will be written in the file
    		la $a2, ($s7)            # file size? 
    		syscall
		jr $ra
		
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
		li $v0, 4
		la $a0, ($t1)
		syscall
	printInt:
		li $v0, 1
		la $a0, ($t1)
		syscall
	exit:
		li $v0, 10		# system call code for exit = 10
		syscall	

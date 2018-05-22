.data			      # |4bits|4bits|4bits|4bits|
	estrutura: .space 1024  # |valor|sbe|sbd|altura|
	fileInput: .asciiz "tree.in"
	fileOutput: .asciiz "tree.out"
	buffer: .space 1024
	
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
		li $a0, 10	  #valor 
		jal no	
		
		li $s0,9
		la $t5, ($s5)
		loop:
			beq $s0, 0, sair
			la $a0, ($s0) #valor
			la $a1, ($t5)#raiz
			jal insert
			addi $s0, $s0, -1 
			addi $t5, $t6, -16
		j loop
			
		sair:j exit

########
##Tree##
########
	
	no:
		la $t0, 0	#sbe
		la $t1, 0	#sbd
		la $t2, 0	#altura
		
		sb $a0, 0($s6)	 #valor 
		sb $t0, 4($s6)	 #sbe
		sb $t1, 8($s6)   #sbd
		sb $t2, 12($s6)	 #altura	
		
		add $s6, $s6 ,16 
		
		jr $ra
		
	insert:
		la $t0, ($a1) #raiz
		la $t1, ($t0) #aux2
		la $t2, ($a0) # valor
		
		lb $t3, 0($t0)	 #valor
		
		bgt $t2, $t3, ELSED #esquerda
			
			lb $t4, 4($t1)	 #sae
			la $t7, 4($t1)
			la $t1, ($t4)
			
			bnez $t1, ElSEI1
				addiu   $sp,$sp,-16     # aloca 5 posições na pilha
			        sw      $t4, 12($sp)	# empilha 
		        	sw      $t7, 8($sp)	# empilha 
        			sw	$t1, 4($sp)	# empilha 
			        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			        
				jal no
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        		lw      $t1,4($sp)      
	        		lw      $t7,8($sp)      
			        lw      $t4,12($sp)
			        la $t6, ($s6)
				addi $t5, $t6, -16
				sw $t5,($t7)
				
				
				j retornaI

                	ElSEI1: #POSSUI ERRO
                		la $t0,( $t1)
				sw $t0,($t7)
                		j retornaI
                		
		ELSED:#direita
			lb $t4, 8($t1)	 #sad
			la $t7, 8($t1)
			la $t1, ($t4)
			
			bnez $t1, ElSEI2
				addiu   $sp,$sp,-16     # aloca 5 posições na pilha
			        sw      $t4, 12($sp)	# empilha 
		        	sw      $t7, 8($sp)	# empilha 
        			sw	$t1, 4($sp)	# empilha 
			        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			        
				jal no
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        		lw      $t1,4($sp)      
	        		lw      $t7,8($sp)      
			        lw      $t4,12($sp)     
				addiu   $sp,$sp,16
				
				la $t6, ($s6)
				addi $t5, $t6, -16
				sw $t5,($t7)
				
				j retornaI

                	ElSEI2:#POSSUI ERRO
                		la $t0,( $t1)
				sw $t0,($t7)
                		j retornaI
		retornaI:	
			
			#altura calculo
			addiu   $sp,$sp,-4     # aloca 5 posições na pilha
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
			
			#balanceamento
			la $a0, ($t5)
			jal balanceia
			
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			addiu   $sp,$sp,4
			jr $ra
		
		altura: 
			la $t0, ($a0)
			
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
				
		balanceia:	
			la $t0, ($a0) # recebe um no como argumento	
			lb $t1, 16($t0) #carrega a altura
			li $t2, -1
			bgt $t1, $t2, ELSEIFB 
				# altura < -1
				lw $t3, 8($t0)
				lb $t4, 16($t3)
				blt $t4, $zero, ELSEB2
					addiu   $sp,$sp,-20     # aloca 5 posições na pilha
					sw	$t4, 16($sp)	# empilha
			        	sw      $t3, 12($sp)	# empilha 
			        	sw      $t1, 8($sp)	# empilha 
	        			sw	$t0, 4($sp)	# empilha 
				        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
					la $a0, ($t4)
					
					jal rot_esquerda		
					
					lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        			lw      $t0,4($sp)      
		        		lw      $t1,8($sp)      
				        lw      $t3,12($sp)     
				        lw	$t4,16($sp)
					addiu   $sp,$sp,20
					
					sw $v0, 8($t0)
					
					
				
				ELSEB2:
					addiu   $sp,$sp,-20     # aloca 5 posições na pilha
					sw	$t4, 16($sp)	# empilha
			        	sw      $t3, 12($sp)	# empilha 
			        	sw      $t1, 8($sp)	# empilha 
	        			sw	$t0, 4($sp)	# empilha 
				        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
					la $a0, ($t0)
					
					jal rot_direita			
					
					lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        			lw      $t0,4($sp)      
		        		lw      $t1,8($sp)      
				        lw      $t3,12($sp)     
				        lw	$t4,16($sp)
					addiu   $sp,$sp,20
					
					la $a0, ($v0 )

			ELSEIFB: 
				# altura > -1
				lw $t3, 8($t0) #direita
				bnez $t0, cont # se nao tiver subarvore direita
					li $t4, 0 
					b pass
				cont:lb $t4, 12($t3)
				pass:
				blt $t4, $zero, ELSEB3
					addiu   $sp,$sp,-20     # aloca 5 posições na pilha
					sw	$t4, 16($sp)	# empilha
			        	sw      $t3, 12($sp)	# empilha 
			        	sw      $t1, 8($sp)	# empilha 
	        			sw	$t0, 4($sp)	# empilha 
				        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
					la $a0, ($t4)
					
					jal rot_esquerda		
					
					lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        			lw      $t0,4($sp)      
		        		lw      $t1,8($sp)      
				        lw      $t3,12($sp)     
				        lw	$t4,16($sp)
					addiu   $sp,$sp,20
					
					sw $v0, 12($t0)
					
					
				
				ELSEB3:
					addiu   $sp,$sp,-20     # aloca 5 posições na pilha
					sw	$t4, 16($sp)	# empilha
			        	sw      $t3, 12($sp)	# empilha 
			        	sw      $t1, 8($sp)	# empilha 
	        			sw	$t0, 4($sp)	# empilha 
				        sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
					la $a0, ($t0)
					
					jal rot_direita			
					
					lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
	        			lw      $t0,4($sp)      
		        		lw      $t1,8($sp)      
				        lw      $t3,12($sp)     
				        lw	$t4,16($sp)
					addiu   $sp,$sp,20
					
					la $a0, ($v0 )
			
			la $v0, ($a0)
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
    			
			addiu   $sp,$sp,-4     # aloca 5 posições na pilha
			sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
			

			lw $a0, 4($t0) #esq
			jal altura
			la $t2, ($v0) # a
			
			lw $a0, 8($t0) #dir
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t5, ($v0)
			addi $t5,$t5,1
			
			sb $t5, 12($t0) 
			
			#y
			
 			lw $a0, 4($t1) #esq
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
			
			sb $t5, 12($t5) 
 			
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
			
			
			#y
			
 			lw $a0, 4($t1) #esq
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
			
			sb $t5, 12($t5) 
 			
 			#x
 			lw $a0, 4($t0) #esq
			jal altura
			la $t2, ($v0) # a
			
			lw $a0, 8($t0) #dir
			jal altura
			la $t3, ($v0) # b
			
			
			la $a0, ($t2)
			la $a1, ($t3)
			
			jal max 
			
			la $t5, ($v0)
			addi $t5,$t5,1
			
			sb $t5, 12($t0) 

    			#Return new root
			la $v0, ($t1)
			lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
			addiu   $sp,$sp,4
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
				addiu   $sp,$sp,4
				
				
				#direita
				lw $t2, 8($t0)
        			addiu   $sp,$sp,-8     # aloca 5 posições na pilha
				sw      $ra, 0($sp)	# empilha o endereço de retorno par ao SO
				sw	$t2, 4($sp)
				
				la $a0, ($t2)
				jal posOrder
				
				lw      $ra,0($sp)      # ao voltar, recupera endereço de retorno da pilha
				lw	$t2,4($sp)
				addiu   $sp,$sp,4
        			
        			
        			
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

# Grupo 5
#Radix Sort
#Raissa, Mayara, Peppe e Jonas
.data
array_to_sort:  .space 2716
array_sorting:  .space 2716
array_sorted:   .space 2716
bucket: .space 40
barra_n: .byte '\n'
space: .byte ' '

.text

#Reservar Registradores
	#S0 -> Tamanho do Array (Corresponde ao nr de Bytes para chegar no ultimo elemento do Array + 4)/ numero total de bytes no array
	add $s0, $zero, $zero
	#S1 -> Valor do Expoente        (1, 10, 100 ...) Irá pegar os digitos de cada casa decimal
	addi $s1, $zero,1
	#S2 -> Valor do maior número
	#S3 -> Valor 10 (Pra usar nas iterações do Bucket [na vdd é 40 pois 4bytes x 10)
	addi $s3, $zero,40 
#Gerar Valores Random pro Array_to_sort #
	addi $s0, $zero, 2716 #Definir tamanho do Array
	add $t0, $zero, $zero
	random_generate:
		li $v0, 42        #Syscall Random
		li $a1, 100000    # Valor max
		syscall           # Pegar em a0
		
		sw $a0, array_to_sort($t0)
		sw $a0, array_sorting($t0)
  
  	addi $t0, $t0,4	
	bne $t0, $s0, random_generate
	  
	
#Achar o maior
	#s0 contém o tamanho do Array
	add $t1, $zero, $zero #Iterador pro branch / leitura do Array
	add $s2, $zero, $zero #Salvar o maior aqui      <<<<<<<<<<<<<<<<<<<<<<<<<<<  USAR ATÉ O FIM DO CÓDIGO
	#t3 Salva o booleano (se eh maior ou não)
	#t4 Pega os valores do Array
	achar_maior:
		lw $t4, array_to_sort($t1)
		sgt $t3, $t4, $s2    #O valor lido eh maior que o maior? (0 / 1)?
		beqz $t3, else       #Se nao for maior, continue
		move $s2, $t4  #Se for maior, atualize o registrador maior (s2)
		else:
		addi $t1, $t1,4    #Incrementa o contador do Array (+4 pq eh inteiro)
		bne $t1, $s0, achar_maior #Enquanto nao chegar no fim do Array, branch

#Count Sort
#s0 tamanho do Array, s1 expoente, 
	loop_do_expoente:      #While que roda a quantidade digitos max (ex: maior n no Array é 100, logo, sao 3 digitos, 3 rodadas)
		div $t1,$s2, $s1   #Divida o maior pelo expoente
		beqz $t1, exit 
		#Contar Ocorrências no bucket (Ordenar por digito)
			add $t0, $zero, $zero      #Limpa o registrador t0
			contador_de_ocorrencias:
			lw $t4, array_to_sort($t0) #Pega valor do Array
			div $t1,$t4,$s1            #Divida o valor atual pelo expoente
			div $t1,$t1, 10		   #Divida por 10 pra pegar o mod 10
			mfhi $t1		   #Pega o resto da divisão por 10
			mul $t1,$t1,4              #Pegar posição no bucket pra incrementar (x4 pq sao 4 Bytes)
			lw $t4, bucket($t1)        #Pega o valor que ta na posicao  $t1 do bucket pra dar ++
			addi $t4, $t4,1            #T4++   
			sw $t4, bucket($t1)        #Salva de volta, basicamente bucket[t1]++; b[(array[i]/exp) % 10]++
			addi $t0,$t0,4
			bne $t0, $s0,contador_de_ocorrencias
			
		#Calcular posições reais (Somar as posições + a anterior)
			addi $t0, $zero,4         #Iterador do Bucket  b[i]
			add $t1, $zero, $zero     #Ireador do Bucket -1 b[i-1]
			somador_bucket:
			lw $t4, bucket($t0)       #Bucket[i]
			lw $t5, bucket($t1)       #Bucket[i-1]
			add $t6, $t4,$t5          #B[i] += B[i-1}]
			sw $t6, bucket($t0)       #Salve
			
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			bne $t0, $s3, somador_bucket #Itere até o fim do Bucket i = 40 (4Bytes x 10)
			
		#Salvar no Array_sourted as novas posições
			add $t0, $zero, $s0      #Pôe o tamanho do Array_to_sort
			addi $t0, $t0, -4        #Ultima posição do Array
			por_no_array:
			lw $t4, array_sorting($t0) #Pega valor do Array, em T4
			div $t1,$t4,$s1            #Divida o valor atual pelo expoente
			div $t1,$t1, 10		   #Divida por 10 pra pegar o mod 10
			mfhi $t1		   #Pega o resto da divisão por 10 e salva em t1 (Valor número)
			mul $t1, $t1,4             #O valor da posição em Bytes agora 
			lw $t5, bucket($t1)        #Pega o valor que ta na posicao  $t1 do bucket pra dar --
			addi $t5, $t5,-1            #T5-- posição que vai salvar
			sw $t5, bucket($t1)        #Atualiza o valor de posição do Bucket
			mul $t5, $t5,4             #Posição em Byes tb
			sw $t4, array_sorted($t5)  #Põe o valor reposicionado no Array novo
			
			
			addi $t0, $t0, -4 
			bne $t0, -4 por_no_array     #Itere até passar por todos os valores do Array
			
		#Passar valores do Sorted pro Sorting
			add $t0, $zero,$zero
			copy:
			lw $t5, array_sorted($t0)
			sw $t5, array_sorting($t0)
			addi $t0,$t0,4
			bne $t0,$s0, copy
		#Limpar Bucket
			add $t0, $zero,$zero
			limpa:
			sw $zero, bucket($t0)
			addi $t0,$t0,4
			bne $t0,$s3, limpa
			
			
	mul $s1, $s1,10  #expoente x 10 (Pegar próxima casa decimal)
	j loop_do_expoente
	
        exit:
#		>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TESTES<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#Printar maior
	li $v0, 1
	add $a0, $zero, $s2
	syscall
#/n
	li $v0, 4
	la $a0, barra_n
	syscall
#Printar Bucket de Ocorrencias
add $t0, $zero, $zero
printar_bucket:
	li $v0, 1
	lw $a0, bucket($t0)
	syscall
	
	li $v0, 4
	la $a0, space   #espaço entre numeros
	syscall
	
	addi $t0, $t0, 4
	bne $t0, $s3 printar_bucket
	
#/n
	li $v0, 4
	la $a0, barra_n
	syscall
	
#Printar o Array Original
add $t0, $zero, $zero
printar_array_original:
	li $v0, 1
	lw $a0, array_to_sort($t0)
	syscall
	
	li $v0, 4
	la $a0, space   #espaço entre numeros
	syscall
	
	addi $t0, $t0, 4
	bne $t0, $s0 printar_array_original
	
#/n
	li $v0, 4
	la $a0, barra_n
	syscall

#Printar o OutPut Array
add $t0, $zero, $zero
printar_array_sorted:
	li $v0, 1
	lw $a0, array_sorted($t0)
	syscall
	
	li $v0, 4
	la $a0, space   #espaço entre numeros
	syscall
	
	addi $t0, $t0, 4
	bne $t0, $s0 printar_array_sorted

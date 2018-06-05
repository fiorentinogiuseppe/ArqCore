
package br.ufrpe.deinfo.aoc.mips.example;


import java.io.IOException;

import jline.console.ConsoleReader;
import br.ufrpe.deinfo.aoc.mips.InvalidMemoryAlignmentExpcetion;
import br.ufrpe.deinfo.aoc.mips.MIPS;
import br.ufrpe.deinfo.aoc.mips.Simulator;
import br.ufrpe.deinfo.aoc.mips.State;

public class MyMIPS implements MIPS{
	
	private boolean pcPlus4;

	@SuppressWarnings("unused")
	private ConsoleReader console;
	
	public MyMIPS() throws IOException {
		this.console = Simulator.getConsole();
	}
	@Override
	public void execute(State s) throws Exception {
		if(s.getPC().equals(0)){
			s.writeRegister(28,  0x1800); //Global Pointer Localization  
			s.writeRegister(29,  0x3ffc); //Stack Pointer Localization
		}

		
		String inst = completeLeftSide(Integer.toBinaryString(s.readInstructionMemory(s.getPC())), '0', 32);
		String op = inst.substring(0,6);
		if(op.equals("000000"))
			tipoR(s, inst);
		else if(op.equals("000010") || op.equals("000011"))
			tipoJ(s, inst, op);
		else
			tipoI(s, inst, op);
		if(pcPlus4)
			s.setPC(s.getPC()+4);
		pcPlus4 = true;
	}

	private String completeLeftSide(String str, char c, int i) { 
		// Caso a instruÃ§Ã£o tenha varios zeros antes este sera ignorado, mas Ã© preciso usa-lo. EntÃ£o essa classe existe
		// Pensar em usar o >> Ã© deslocamento logico, preenche sempre com zero a esquerda
		String nstr = Character.toString(c);

		if(str.length()<i){
			int tam =  i - str.length();
			 for(int j =0; j<tam-1; j++) nstr = c+nstr;
			
			return nstr+str;
		}
		else if(str.length()==i) return str;
		return null;
	}

	private void tipoI(State s, String inst, String op) throws InvalidMemoryAlignmentExpcetion {

		Integer rs = Integer.parseInt(inst.substring(6,11),2);
		Integer rt = Integer.parseInt(inst.substring(11,16),2);
		//Integer immediate = Integer.parseInt(inst.substring(16,32),2);
		Integer result = 0;
		Integer ValueRs = s.readRegister(rs);
		Integer ValueRt = s.readRegister(rt);
		
		Integer SignExtImm; // {16{immediate[16]}, immediate} concatenar 16 immediate[16]'s e depois concatenar com immediate
		Integer ZeroExtImm; // {16{1b'0}, immediate} concatenar 16 0's e depois concatenar com immediate
		Integer BranchAddr; // {14{immediate[16]}, immediate , 2'b0} concatenar 14 immediate[16] e depois concatenar com immediate e depois com 2'b0
		
		//String de concatenacao 

			
		String repetSignExtImm = inst.substring(16,17); 
		String repetZeroExtImm = "0";
		String repetBranchAddr = inst.substring(16,17);
		String zeros ="000";
		//concatenacao

		for(int i=0;i<15;i++){ //como ja ocorreu um elemento apenas. Agora precisa concatenas 15 valores
			repetSignExtImm += inst.substring(16,17);
			repetZeroExtImm += "0";
			if(i<12) repetBranchAddr += inst.substring(16,17); //como so precisa de 14 e ja foi feito uma
		}
		
		SignExtImm = binarySigned(repetSignExtImm + inst.substring(16,32)); //valor do SignExtImm
		ZeroExtImm = Integer.parseInt((repetZeroExtImm + inst.substring(16,32)),2); //valor do ZeroExtImm
		BranchAddr =  binarySigned(repetBranchAddr + inst.substring(16,32) + zeros); //Valor do BranchAddr
		switch(op){
			case "001000": //ADDI OK
				ValueRs = binarySigned(completeLeftSide(Integer.toBinaryString(ValueRs), '0', 32));
				SignExtImm = binarySigned(completeLeftSide(Integer.toBinaryString(SignExtImm), '0', 32));
				result = ValueRs + SignExtImm;
				s.writeRegister(rt, result);

				break;
			case "001001": //ADDIU OK
				result = ValueRs + SignExtImm;
				s.writeRegister(rt, result);
				break;
			case "001100":	//ANDI OK
				result = ValueRs & ZeroExtImm;
				s.writeRegister(rt, result);
				break;
			case "000100": //BEQ OK
			
				if(ValueRs==ValueRt){
					result = s.getPC()+BranchAddr;
					s.setPC(result);
					pcPlus4 = false;
				}
				break;
			case "000101": //BNE OK
				if(ValueRs!=ValueRt){
					s.setPC(s.getPC()+BranchAddr);
					pcPlus4 = false;
				}

				break;
			
			case "100100": //LBU
				//Esta instrução carrega uma estrutura de 1 byte sem sinal 
	            //localizada no endereço representado pela soma do valor
	            //armazenado no registrador rs + imediato. O resultado e armazenado em rt.
				
				String ins = Integer.toBinaryString(s.readWordDataMemory(ValueRs+SignExtImm));
				ins = ins.substring(24,32);
				String zerosLBU="000000000000000000000000";
				String conc = zerosLBU+ins;
				Integer resultLBU = Integer.parseInt(conc,2);
				s.writeRegister(rt, resultLBU);		
				break;
				
			case "100101": //LHU
				//Esta instrução carrega uma estrutura de 2 bytes sem sinal 
	            //localizada no endereço representado pela soma do valor
	            //armazenado no registrador rs + imediato. O resultado e armazenado em rt.
				
				String insLHU = Integer.toBinaryString(s.readWordDataMemory(ValueRs+SignExtImm));
				insLHU = insLHU.substring(16,32);
				String zerosLHU="0000000000000000";
				String concLHU = zerosLHU+insLHU;
				Integer resultLHU = Integer.parseInt(concLHU,2);
				s.writeRegister(rt, resultLHU);		
				
				break;
				//Esta instrucao carrega o valor contido no imediato (16 bits) 
				//E desloca 16 bits para a esquerda (acrescentando 16 0s a direita)
			case "001111"://Lui OK
				String imm = inst.substring(16,32);
				String zerosLUI="0000000000000000";
				String concLUI = imm+zerosLUI;
				Integer resultLUI = binarySigned(concLUI);
				s.writeRegister(rt, resultLUI);		
				break;
				
			case "100011": //lw
				//Esta instrução carrega uma palavra (estrutura de 4 bytes)
	            //localizada no endereço representado pela soma do valor
	            //armazenado no registrador rs + imediato. O resultado é armazenado em rt.
				s.writeRegister(rt, s.readWordDataMemory(ValueRs +SignExtImm));		
				break;		

			case "001101"://Ori OK
				result = ValueRs | ZeroExtImm;
				s.writeRegister(rt, result);
				break;
			case "001010": //SLTI OK
				ValueRs = binarySigned(completeLeftSide(Integer.toBinaryString(ValueRs), '0', 32));
				SignExtImm = binarySigned(completeLeftSide(Integer.toBinaryString(SignExtImm), '0', 32));
				if(ValueRs < SignExtImm) result = 1;
				else result = 0;
				s.writeRegister(rt, result);
				break;
			case "001011": //SLTIU OK
				if(ValueRs < SignExtImm) result = 1;
				else result = 0;
				s.writeRegister(rt, result);
				break;
			
			case "101000": //SB  OK
				//Esta instrução carrega uma estrutura de 1 byte
				//localizada no registrador rt e armazena no endereço representado 
				//pela soma do valor armazenado no registrador rs mais o imediato. 
				s.writeByteDataMemory(ValueRs+SignExtImm, ValueRt);
				break;
			case "101001": //SH OK 
				//Esta instrução carrega uma estrutura de 2 bytes
				//localizada no registrador rt e armazena no endereço representado 
				//pela soma do valor armazenado no registrador rs mais o imediato. 
				s.writeHalfwordDataMemory(ValueRs+SignExtImm, ValueRt);
				break;
			case "101011": //SW OK
				//Esta instrução carrega uma palavra (estrutura de 4 bytes)
				//localizada no registrador rt e armazena no endereço representado 
				//pela soma do valor armazenado no registrador rs mais o imediato. 
				s.writeWordDataMemory(ValueRs + SignExtImm , ValueRt);
				break;
				
		}
		
	}

	private void tipoJ(State s, String inst, String op) { //100% okay
		//Integer address = Integer.parseInt(inst.substring(6,32),2);
		Integer JumpAddr = null;	 

		Integer PCP4 = s.getPC() + 4; // chamemos PC+4 de PCP4

		String PCP4String = Integer.toBinaryString(PCP4); //PCP4[31:28] em verilog 
		String complete = completeLeftSide(PCP4String, '0', 32);
		String part1 = complete.substring(0, 3); // em java eh a posiÃ§Ã£o 0 a 3
		String part2=inst.substring(6,32); // address
		String part3="00"; //2â€™b0
		
		JumpAddr = Integer.parseInt((part1+part2+part3),2); 
		switch(op){
			case "000010": //JUMP OK
				s.setPC(JumpAddr);
				pcPlus4 = false;
				break;
			case "000011": //JUMP AND LINK OK
				s.writeRegister(31,  s.getPC()+4); 
				s.setPC(JumpAddr);
				pcPlus4 = false;
				break;				
		}		
	}

	private void tipoR(State s, String inst) {
		Integer rs = Integer.parseInt(inst.substring(6,11),2);
		Integer rt = Integer.parseInt(inst.substring(11,16),2);
		Integer rd = Integer.parseInt(inst.substring(16,21),2);
		Integer shamt = Integer.parseInt(inst.substring(21,26),2);
		String funct = inst.substring(26,32);
		Integer result = 0;
		Integer ValueRs = s.readRegister(rs);
		Integer rtValue = s.readRegister(rt);

		switch(funct){
			case "100000": //ADD OK
				

				ValueRs = binarySigned(completeLeftSide(Integer.toBinaryString(ValueRs), '0', 32));
				rtValue = binarySigned(completeLeftSide(Integer.toBinaryString(rtValue), '0', 32));
				result = ValueRs + rtValue;
				s.writeRegister(rd, result);
				break;
			case "100001": //ADDU  OK
				result = ValueRs + rtValue;
				s.writeRegister(rd, result);
				break;
			case "100100": //AND OK
				result = ValueRs & rtValue;
				s.writeRegister(rd, result);
				break;
			case "001000": //JR OK
				s.setPC(ValueRs);
				pcPlus4 = false;
				break;
			case "100111": //NOR OK
				result = ~(ValueRs | rtValue);
				s.writeRegister(rd, result);	
				break;
			case "100101": //OR OK
				result = (ValueRs | rtValue);
				s.writeRegister(rd, result);
				break;
			case "101010": //SLT OK
				
				//Ela armazena 1 em rd se rs < rt e 0 caso contrário.
				
				ValueRs = binarySigned(completeLeftSide(Integer.toBinaryString(ValueRs), '0', 32));
				rtValue = binarySigned(completeLeftSide(Integer.toBinaryString(rtValue), '0', 32));
				if(ValueRs < rtValue) result = 1;
				else result = 0;
				s.writeRegister(rd, result);
				break;
			case "101011": //SLTU OK
				if(ValueRs < rtValue) result = 1;
				else result = 0;
				s.writeRegister(rd, result);
				break;
			case "000000": //SLL OK
				result = rtValue << shamt;
				s.writeRegister(rd, result);
				break;
			case "000010": //SRL OK
				result = rtValue >> shamt;
				s.writeRegister(rd, result);
				break;
			case "100010"://SUB OK
				ValueRs = binarySigned(completeLeftSide(Integer.toBinaryString(ValueRs), '0', 32));
				rtValue = binarySigned(completeLeftSide(Integer.toBinaryString(rtValue), '0', 32));
				result = ValueRs - rtValue;
				s.writeRegister(rd, result);
				break;
			case "100011":  //SUBU OK
				result = ValueRs - rtValue;
				s.writeRegister(rd, result);
				break;				
			
		}
	}

	private static Integer binarySigned(String binaryInt) {
		// recebo um valor e converto para inteiro e retorno
		
	    if (binaryInt.charAt(0) == '1') {
	    	//negativo
	    	
	        //complemento de 1
	        String invertedInt = invertDigits(binaryInt);
	        //inverto pra decimal
	        int decimalValue = Integer.parseInt(invertedInt, 2);
	        //Add 1 to the curernt decimal and multiply it by -1
	        //because we know it's a negative number
	        decimalValue = (decimalValue + 1) * -1;
	        //return the final result
	        return decimalValue;
	    } else {
	    	//positivo
	        return Integer.parseInt(binaryInt, 2);
	    }
	}
	public static String invertDigits(String binaryInt) {
		//complemento de 1
	    String result = binaryInt;
	    result = result.replace("0", " "); 
	    result = result.replace("1", "0"); 
	    result = result.replace(" ", "1"); 
	    return result;
	}
	
	public static void main(String[] args) {
		try {
			MS.setMIPS(new MyMIPS());
			MS.setLogLevel(MS.LogLevel.INFO);
			MS.start();

		} catch (Exception e) {		
			e.printStackTrace();
		}	
		
	}

}

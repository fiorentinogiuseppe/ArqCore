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
		// Caso a instrução tenha varios zeros antes este sera ignorado, mas é preciso usa-lo. Então essa classe existe
		// Pensar em usar o >> é deslocamento logico, preenche sempre com zero a esquerda
		String nstr = Character.toString(c);

		if(str.length()<i){
			int tam =  i - str.length();
			 for(int j =0; j<tam-1; j++) nstr = c+nstr;
			
			return nstr+str;
		}
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
			
			case "100100": //LBU OK
				String ins = Integer.toBinaryString(s.readWordDataMemory(ValueRs+SignExtImm));
				String zerosLBU="000000000000000000000000";
				String conc = zerosLBU+ins;
				Integer resultLBU = Integer.parseInt(conc,2);
				s.writeRegister(rt, resultLBU);		
				break;
				
			case "100101": //LHU OK
				String insLHU = Integer.toBinaryString(s.readWordDataMemory(ValueRs+SignExtImm));
				String zerosLHU="0000000000000000";
				String concLHU = zerosLHU+insLHU;
				Integer resultLHU = Integer.parseInt(concLHU,2);
				s.writeRegister(rt, resultLHU);		
				
				break;
				
			case "001111"://Lui OK
				String imm = inst.substring(16,32);
				String zerosLUI="0000000000000000";
				String concLUI = imm+zerosLUI;
				Integer resultLUI = binarySigned(concLUI);
				s.writeRegister(rt, resultLUI);		
				break;
				
			case "100011": //lw OK
				Integer insLW = s.readWordDataMemory(ValueRs+SignExtImm);
				s.writeRegister(rt, insLW);		
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
			
			case "101000": //SB OK
				s.writeByteDataMemory(rs+SignExtImm, ValueRt);
				break;
			case "101001": //SH 
				s.writeHalfwordDataMemory(rs+SignExtImm, ValueRt);
				break;
			case "101011": //SW OK
				result = ValueRs+SignExtImm;
				s.writeWordDataMemory(result, ValueRt);
				break;
				
		}
		
	}

	private void tipoJ(State s, String inst, String op) { //100% okay
		//Integer address = Integer.parseInt(inst.substring(6,32),2);
		Integer JumpAddr = null;	 

		Integer PCP4 = s.getPC() + 4; // chamemos PC+4 de PCP4

		String PCP4String = Integer.toBinaryString(PCP4); //PCP4[31:28] em verilog 
		String complete = completeLeftSide(PCP4String, '0', 32);
		String part1 = complete.substring(0, 3); // em java eh a posição 0 a 3
		String part2=inst.substring(6,32); // address
		String part3="00"; //2’b0
		
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
			Simulator.setMIPS(new MyMIPS());
			Simulator.setLogLevel(Simulator.LogLevel.INFO);
			Simulator.start();
		} catch (Exception e) {		
			e.printStackTrace();
		}	
		
	}

}

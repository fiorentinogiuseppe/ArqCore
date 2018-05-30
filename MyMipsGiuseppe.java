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
		//MODIFICAR AQUI
		
		String inst = completToLeft(Integer.toBinaryString(s.readInstructionMemory(s.getPC())), '0', 32);
		String op = inst.substring(0,6);
		
		if(op.equals("000000"))
			tipoR(s, inst);
		else if(op.equals("000010"))
			tipoJ(s, inst, op);
		else
			tipoI(s, inst, op);
		if(pcPlus4)
			s.setPC(s.getPC()+4);
		pcPlus4 = true;
	}

	private String completToLeft(String str, char c, int i) { 
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

	private void tipoI(State s, String inst, String op) {
		//TODO analisar
		Integer rs = Integer.parseInt(inst.substring(6,11),2);
		Integer rt = Integer.parseInt(inst.substring(11,16),2);
		//Integer immediate = Integer.parseInt(inst.substring(16,32),2);
		Integer result = 0;
		Integer rsValue = s.readRegister(rs);
		
		Integer SignExtImm; // {16{immediate[16]}, immediate} concatenar 16 immediate[16]'s e depois concatenar com immediate
		Integer ZeroExtImm; // {16{1b'0}, immediate} concatenar 16 0's e depois concatenar com immediate
		Integer BranchAddr; // {14{immediate[16]}, immediate , 2'b0} concatenar 14 immediate[16] e depois concatenar com immediate e depois com 2'b0
		
		//String de concatenacao 
		String repetSignExtImm = inst.substring(16); 
		String repetZeroExtImm = "0";
		String repetBranchAddr = inst.substring(16);
		String zeros ="000";
		
		//concatenacao
		for(int i=0;i<15;i++){ //como ja ocorreu um elemento apenas. Agora precisa concatenas 15 valores
			repetSignExtImm += inst.substring(16);
			repetZeroExtImm += "0";
			if(i<12) repetBranchAddr += inst.substring(15); //como so precisa de 14 e ja foi feito uma
		}

		SignExtImm = Integer.parseInt((repetSignExtImm + inst.substring(16,32)),2); //valor do SignExtImm
		ZeroExtImm = Integer.parseInt((repetZeroExtImm + inst.substring(16,32)),2); //valor do ZeroExtImm
		BranchAddr = Integer.parseInt((repetBranchAddr + inst.substring(16,32) + zeros),2); //Valor do BranchAddr
		
		switch(op){
			case "001000": //ADDI
				rsValue = binarySigned(completToLeft(Integer.toBinaryString(rsValue), '0', 32));
				SignExtImm = binarySigned(completToLeft(Integer.toBinaryString(SignExtImm), '0', 32));
				result = rsValue + SignExtImm;
				s.writeRegister(rt, result);

				break;
			case "001001": //ADDIU
				result = rsValue + SignExtImm;
				s.writeRegister(rt, result);
				break;
			case "001100":	//ANDI
				result = rsValue & ZeroExtImm;
				s.writeRegister(rt, result);
				break;
			case "000100": //BEQ
				if(rs==rt)
					s.setPC(s.getPC()+4+BranchAddr);
				break;
			case "000101": //BNE
				if(rs!=rt)
					s.setPC(s.getPC()+4+BranchAddr);
				break;
			case "100100": //LBU
				//TODO Fazer
				break;
		}
		
	}

	private void tipoJ(State s, String inst, String op) {
		//Integer address = Integer.parseInt(inst.substring(6,32),2);
		Integer JumpAddr = null;	 //TODO deselvolver essa equação
		String part1=null; //PC+4op[31:28]
		String part2=inst.substring(6,32); // address
		String part3="000"; //2’b0
		
		JumpAddr = Integer.parseInt((part1+part2+part3),2);
		
		switch(op){
			case "000010": //JUMP 
				s.setPC(JumpAddr);
				break;
			case "000011": //JUMP AND LINK
				s.writeRegister(31,  s.getPC()+4); 
				s.setPC(JumpAddr);
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
		Integer rsValue = s.readRegister(rs);
		Integer rtValue = s.readRegister(rt);

		switch(funct){
			case "100000": //ADD
				rsValue = binarySigned(completToLeft(Integer.toBinaryString(rsValue), '0', 32));
				rtValue = binarySigned(completToLeft(Integer.toBinaryString(rtValue), '0', 32));
				result = rsValue + rtValue;
				s.writeRegister(rd, result);
				break;
			case "100001": //ADDU TODO ANALISAR
				result = rsValue + rtValue;
				s.writeRegister(rd, result);
				break;
			case "100100": //AND
				result = rsValue & rtValue;
				s.writeRegister(rd, result);
				break;
			case "001000": //JR
				s.setPC(rsValue);
				break;
			case "100111": //NOR
				result = ~(rsValue | rtValue);
				s.writeRegister(rd, result);	
				break;
			case "100101": //OR
				result = (rsValue | rtValue);
				s.writeRegister(rd, result);
				break;
			case "101010": //SLT
				rsValue = binarySigned(completToLeft(Integer.toBinaryString(rsValue), '0', 32));
				rtValue = binarySigned(completToLeft(Integer.toBinaryString(rtValue), '0', 32));
				if(rsValue < rtValue) result = 1;
				else result = 0;
				s.writeRegister(rd, result);
				break;
			case "101011": //SLTU
				if(rsValue < rtValue) result = 1;
				else result = 0;
				s.writeRegister(rd, result);
				break;
			case "000000": //SLL
				result = rtValue << shamt;
				s.writeRegister(rd, result);
				break;
			case "000010": //SRL
				result = rtValue >> shamt;
				s.writeRegister(rd, result);
				break;
			case "100010"://SUB
				rsValue = binarySigned(completToLeft(Integer.toBinaryString(rsValue), '0', 32));
				rtValue = binarySigned(completToLeft(Integer.toBinaryString(rtValue), '0', 32));
				result = rsValue - rtValue;
				s.writeRegister(rd, result);
				break;
			case "100011":  //SUBU
				result = rsValue - rtValue;
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

//TODO
//the curly braces are for concatenation. The extra curly braces around 16{a[16]} are the replication operator.
//{ 
//a[16], a[15], a[15], a[15], a[15], a[15], a[15], a[15],
//a[15], a[15], a[1
/*
assign result = {{16{a[15]}}, {a[15:0]}};
is the same as:

assign result[ 0] = a[ 0];
assign result[ 1] = a[ 1];
assign result[ 2] = a[ 2];
assign result[ 3] = a[ 3];
assign result[ 4] = a[ 4];
assign result[ 5] = a[ 5];
assign result[ 6] = a[ 6];
assign result[ 7] = a[ 7];
assign result[ 8] = a[ 8];
assign result[ 9] = a[ 9];
assign result[10] = a[10];
assign result[11] = a[11];
assign result[12] = a[12];
assign result[13] = a[13];
assign result[14] = a[14];
assign result[15] = a[15];
assign result[16] = a[15];
assign result[17] = a[15];
assign result[18] = a[15];
assign result[19] = a[15];
assign result[20] = a[15];
assign result[21] = a[15];
assign result[22] = a[15];
assign result[23] = a[15];
assign result[24] = a[15];
assign result[25] = a[15];
assign result[26] = a[15];
assign result[27] = a[15];
assign result[28] = a[15];
assign result[29] = a[15];
assign result[30] = a[15];
assign result[31] = a[15];*/

package br.ufrpe.deinfo.aoc.mips.example;


import java.io.IOException;

import jline.console.ConsoleReader;
import br.ufrpe.deinfo.aoc.mips.MIPS;
import br.ufrpe.deinfo.aoc.mips.Simulator;
import br.ufrpe.deinfo.aoc.mips.State;

public class MyMIPS implements MIPS{
	
	private boolean pcPlus4;

	
	@Override
	public void execute(State s) throws Exception {
		if(s.getPC().equals(0)){
			s.writeRegister(28,  0x1800); //Global Pointer Localization  
			s.writeRegister(29,  0x3ffc); //Stack Pointer Localization
		}
		
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

	private static String completToLeft(String str, char c, int i) { //TODO remover static
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
		// TODO Auto-generated method stub
		
	}

	private void tipoJ(State s, String inst, String op) {
		// TODO Auto-generated method stub
		
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
			case "100001": //ADDU
				result = rsValue + rtValue;
				s.writeRegister(rd, result);
				break;
				
		}
		
		//ADDU - ADD Unsigned
		//AND
		//JR - Jump register
		//Nor
		//Or
		//SLT - Set less than
		//SLTU - Set less than Unsigned
		//SLL - Shift Left Logical
		//SRL - Shift Right Logical
		//Sub - Subtract
		//Subu - Subtract Unsigned
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
	    result = result.replace("0", " "); //temp replace 0s
	    result = result.replace("1", "0"); //replace 1s with 0s
	    result = result.replace(" ", "1"); //put the 1s back in
	    return result;
	}
	
	public static void main(String[] args) {
		
		System.out.println(binarySigned("00001010"));
		
	}

}

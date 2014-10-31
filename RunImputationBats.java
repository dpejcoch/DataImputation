package cz.dataquality.SOMA;

import java.io.IOException;

public class RunImputationBats
{
   public static void main(String[] args) throws InterruptedException 
   {
	   
	int c;
     
	for (int d = 9; d <= 9; d++) 
	{
		c=1000;
		
		for (int n = 1; n <= 10; n++)
	      {
			int m;
			 m = n * 5;
	    	  try {
	              /*String[] command = {"cmd.exe", "/C", "Start", "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\ds1_M8_"+m+".bat"};*/
	              String[] command = {"cmd.exe", "/C", "Start", "r:\\ROOT\\install\\kdd\\RapidMiner\\rapidminer\\scripts\\rapidminer","-f","r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\ds"+d+"_M10_"+m+".rmp"};
	              @SuppressWarnings("unused")
	              Process p =  Runtime.getRuntime().exec(command);  
	              
	              Thread.sleep(c * 1000);
	             /* Runtime.getRuntime().exec("taskkill /f /im cmd.exe") ;*/
	          } catch (IOException ex) {}
	
	      }
   	}
  }
}

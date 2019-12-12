package JavaAIO;

import java.io.*;

public class TraversingFileAndDirectories{

      public static void main(String args[]){

            // String dirname = System.getProperty("user.dir");
    	    String dirname = "C:/Programming/testDir";

            File file = new File(dirname);
            
            if(file.isDirectory())
            {
                  System.out.println("Directory is  " + dirname);
                  String str[] = file.list();

                  for( int i = 0; i<str.length; i++)
                  {
                	  String fullname = dirname + "/" + str[i];
                	  System.out.print(fullname);
                        File f=new File(dirname + "/" + str[i]);
                        System.out.print("\t");
                        if(f.isDirectory())
                        {
                              System.out.println(" is a directory");
                        }
                        else
                        {
                              System.out.println(" is a f");
                        }
                  }
            }
            else
            {
                  System.out.println(dirname  + " is not a directory");
            }
      }
}

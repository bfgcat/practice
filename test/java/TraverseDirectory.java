package JavaAIO;

import java.io.*;

public class TraverseDirectory
{
	public static void main(String args[])
	{
		String indent = "";

		// String dirname = System.getProperty("user.dir");
		String startDir = "C:/Programming/testDir";

		File file = new File(startDir);

		if(file.isDirectory())
		{
			System.out.println("Starting directory " + startDir + "\n");
			TestDir dir = new TestDir(file);
			dir.traverse(indent);
			
			System.out.println();
			System.out.println("-----------------------------");
			System.out.println();
			
			dir.showDirs();
			
			System.out.println();
			System.out.println("-----------------------------");
			System.out.println();

			dir.showFiles();
		}	
	}
}

package JavaAIO;

import java.io.File;


public class TestDir
{
	private File f;
	static String[] files = new String[100];
	static int fileCount = 0;
	static String[] dirs = new String[100];
	static int dirCount = 0;
	
	public TestDir(File file)
	{
		f = file;
		dirs[dirCount++] = f.getPath();
	}
	
	public void traverse(String prefix)
	{
		prefix += "    ";
		String str[] = f.list();
		String currDir = f.getPath();

		for( int i = 0; i<str.length; i++)
		{
			String fullname = currDir + "\\" + str[i];
			System.out.print(prefix + fullname);
			File f=new File(fullname);
			System.out.print("\t");
			if(f.isDirectory())
			{
				System.out.println(" is a directory");
				TestDir dir = new TestDir(f);
				
				dir.traverse(prefix);
			}
			else
			{
				System.out.println(" is a file");
				files[fileCount++] = f.getPath();
			}
		}
	}
	
	public void showDirs()
	{
		for (int i = 0; i < dirCount; i++)
		{
			System.out.println(dirs[i]);
		}
	}
	
	public void showFiles()
	{
		for (int i = 0; i < fileCount; i++)
		{
			System.out.println(files[i]);
		}
	}
}

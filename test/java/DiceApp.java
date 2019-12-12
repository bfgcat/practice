package JavaAIO;

public class DiceApp
{
	public static void main(String[] args)
	{
		int roll1;
		int roll2;
		int total;
		int sum = 0;
		double average = 0.0;
		String msg = "Here are 100 random rolls of two dice:";
		System.out.println(msg);
		for (int i=0; i<100; i++)
		{
			roll1 = randomInt(1, 6);
			roll2 = randomInt(1, 6);
			total = roll1 + roll2;
			sum += total;
			System.out.print(total + " ");
		}
		System.out.println();
		System.out.println("sum: " + sum);
		average = (double)sum / 100.0;
		System.out.println("average: " + average);
	}

	public static int randomInt(int low, int high)
	{
		int result = (int)(Math.random() * (high - low + 1)) + low;
		return result;
	}

}

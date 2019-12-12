package JavaAIO;

public class HelloSayer {
	public HelloSayer(String greet, String address) {
		this.greeting = greet;
		this.addressee = address;
	}
	private String greeting;
	private String addressee;
	
	public void SayHello()
	{
		System.out.println(greeting + ", " + addressee + "!");
	}
}

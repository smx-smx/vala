public class Foo {
	public int i;
	public int j;
	public Foo () {
		j = 1;
	}
	public Foo.bar () {
		this ();
		i = 1;
	}
}

void main () {
	var foo = new Foo.bar ();
	assert (foo.i == 1);
	assert (foo.j == 1);
}

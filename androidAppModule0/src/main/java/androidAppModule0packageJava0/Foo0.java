package androidAppModule0packageJava0;

public class Foo0 {
  public void foo0() {
    final Runnable anything = () -> System.out.println("anything");
    new androidAppModule1packageJava0.Foo4().foo3();
    new androidAppModule2packageJava0.Foo4().foo3();
    new androidAppModule3packageJava0.Foo4().foo3();
  }

  public void foo1() {
    final Runnable anything = () -> System.out.println("anything");
    foo0();
  }

  public void foo2() {
    final Runnable anything = () -> System.out.println("anything");
    foo1();
  }

  public void foo3() {
    final Runnable anything = () -> System.out.println("anything");
    foo2();
  }
}

public class ListExcise<T> {
    private T t;
    public ListExcise(T t){
        this.t = t;
    }
    public T get(){
        System.out.println(t);
        return t;
    }
    public static void main(String args[]){
        ListExcise<Integer> listInteger = new ListExcise<Integer>(123456);
        listInteger.get();

        //ListExcise<Double> listDouble = new ListExcise<Double>(1.1,2.2,3.3);
        //listDouble.get();

        ListExcise<String> listString = new ListExcise<String>("abcdef");
        listString.get();
    }
    
}

public class GenericMethodTest {
    public static < E > void printArray( E[] inputArray){
        for ( E element: inputArray){
            System.out.printf("%s ", element);
        }
        System.out.println();
    }

    public static void main(String args[]){
        Integer[] intArray = {1, 2, 3};
        Double[] doubleArray = {1.1, 2.2, 3.3};
        Character[] charArray = {'a', 'b', 'c'};

        System.out.println("Integer:");
        printArray(intArray);

        System.out.println("Double:");
        printArray(doubleArray);

        System.out.println("Character:");
        printArray(charArray);
    }
}
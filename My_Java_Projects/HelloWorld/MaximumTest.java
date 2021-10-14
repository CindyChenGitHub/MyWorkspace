public class MaximumTest {
    public static <T extends Comparable<T>> T maximum(T x, T y, T z){
        T max = x;
        if (y.compareTo(max)>0){
            max = y;
        }
        if (z.compareTo(max)>0){
            max = z;
        }
        return max;
    }
    public static void main(String args[]){
        System.out.printf("The maximum amount %d, %d and %d is %d\n\n", 3, 4, 5, maximum(3, 4, 5));
        System.out.printf("The maximum amount %.1f, %.1f and %.1f is %.1f\n\n", 3.3, 4.4, 5.5, maximum(3.3, 4.4, 5.5));
        System.out.printf("The maximum amount %s, %s and %s is %s\n\n", "aaa", "bbb", "ccc", maximum("aaa", "bbb", "ccc"));
    }
}

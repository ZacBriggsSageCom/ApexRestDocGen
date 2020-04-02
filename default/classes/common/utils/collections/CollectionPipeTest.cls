@isTest
public class CollectionPipeTest {

    private class MockCollectionOperation extends CollectionPipe.Operation {

        private Integer callCount = 0;

        public override List<Object> process(List<Object> objs) {
            callCount++;
            return objs;
        }

    }

    @isTest
    private static void testApply() {
        // GIVEN some Operation
        MockCollectionOperation op = new MockCollectionOperation();

        // WHEN applying this to a CollectionPipe
        new CollectionPipe(new List<String> { 'hello', 'world' })
                .apply(op);

        // THEN its `process` method gets called
        System.assertEquals(1, op.callCount);
    }

    @isTest
    private static void testFromList_ToList() {
        // GIVEN a CollectionPipe
        List<String> source = new List<String> { 'hello', 'world' };
        CollectionPipe pipe = new CollectionPipe(source);

        // WHEN exporting its source to a List
        // THEN the List contains the expected elements
        System.assertEquals(source, pipe.toList());
    }

    @isTest
    private static void testFromSet_ToSet() {
        // GIVEN a CollectionPipe
        Set<Object> source = new Set<Object> { 'hello', 'world' };
        CollectionPipe pipe = new CollectionPipe(source);

        // WHEN exporting its source to a Set
        // THEN the Set contains the expected elements
        System.assertEquals(source, pipe.toSet());
    }

}

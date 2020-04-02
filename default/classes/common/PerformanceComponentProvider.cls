/**
 * Class responsible for instantiating components within the Performance Management package.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class PerformanceComponentProvider implements fHCM2.ComponentProvider {

    @TestVisible
    private static final String POLICY_COMPONENT = 'PerformancePolicyComponent';

    global ApexPages.Component provideComponent(String componentName) {

        if (componentName.equals(POLICY_COMPONENT)) {
            // The Policy page expects the tabFocusName to match the name of our component
            return new Component.PerformancePolicyComponent(tabFocusName=componentName);
        }

        return null;
    }
}
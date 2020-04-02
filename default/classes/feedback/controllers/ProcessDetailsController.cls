public class ProcessDetailsController {

    private static final String PROCESS_NAME_PERFORMANCE_OVERVIEW =
            'Performance Overview';

    // Value for HCM's "team" parameter, to refer to a single Team Member
    private static final String TEAM_TM = 'Team Member';

    /**
     * Gets the details of the Performance Overview process.
     */
    public static ProcessDetailsResponseModel getPerformanceOverviewDetails(
            Id subjectTmId) {

        Viewport view = new Viewport(subjectTmId);

        // Retrieve all Performance Overview process instances from HCM
        List<fHCM2.ProcessInstance> processInstances =
                fHCM2.ProcessHelper.getAllProcessInstances(
                        view.getHcmViewport(),
                        TEAM_TM,
                        PROCESS_NAME_PERFORMANCE_OVERVIEW);

        // Return an error if we don't find any
        if (processInstances == null || processInstances.isEmpty()) {
            // No custom label here, but error is never shown to user
            return new ProcessDetailsResponseModel(new ErrorModel(
                    HttpUtils.STATUS_INTERNAL_SERVER_ERROR,
                    'No Process Instances found!',
                    ''));
        }

        // Just take the first Performance Overview instance
        fHCM2.ProcessInstance pi = processInstances.get(0);
        String serviceId = pi.getCategoryId();
        String processId = pi.getId();

        return new ProcessDetailsResponseModel(serviceId, processId);
    }

}
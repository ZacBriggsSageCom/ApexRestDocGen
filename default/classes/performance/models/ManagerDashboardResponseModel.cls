public class ManagerDashboardResponseModel extends BaseResponseModel{

    public List<TeamMemberSummaryModel> directReportsSummary { get; set; }

    public ManagerDashboardResponseModel() {}

    public ManagerDashboardResponseModel(ErrorModel error) {
        super(error);
    }

    public ManagerDashboardResponseModel(List<TeamMemberSummaryModel> directReportsSummary) {
        this.directReportsSummary = directReportsSummary;
    }

}

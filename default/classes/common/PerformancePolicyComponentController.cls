public class PerformancePolicyComponentController {

    private static final String EDIT_PAGE_NAME =
            'PerformanceManagementPolicyEdit';

    public String tabName { get; set; }

    /**
     * The policy being viewed.
     */
    public fHCM2__Policy__c policy {

        get {

            if (policy == null) {
                Id policyId = ApexPages.currentPage().getParameters().get('id');
                policy = PolicyRepository.getPolicyForPolicyPage(policyId);
            }

            return policy;
        }

        private set;
    }

    /**
     * Gets the URL for the policy edit page.
     */
    public String getEditPageUrl() {

        String policyEditDomain =
                NamespaceUtils.replaceNamespace('fhcm2', NamespaceUtils.NAMESPACE);

        String retUrl = String.format('apex/fHCM2__Policy?id={0}&tab={1}',
                new String[] {
                    policy.Id,
                    tabName
                });

        return String.format('{0}/apex/{1}?id={2}&retURL={3}',
                new String[] {
                    policyEditDomain,
                    EDIT_PAGE_NAME,
                    policy.Id,
                    EncodingUtil.urlEncode(retUrl, 'UTF-8')
                });
    }

}
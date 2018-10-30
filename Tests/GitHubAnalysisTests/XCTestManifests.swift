import XCTest

extension CodeStatTests {
    static let __allTests = [
        ("test_CodeStatLines", test_CodeStatLines),
        ("test_CodeStatMutatingAdditionEqualsNonMutatingAddition", test_CodeStatMutatingAdditionEqualsNonMutatingAddition),
        ("test_CodeStatsAddTogetherCorrectly", test_CodeStatsAddTogetherCorrectly),
        ("test_emptyCodeStat", test_emptyCodeStat),
    ]
}

extension OrgStatTests {
    static let __allTests = [
        ("test_earliestReliableIsLatestEarliestDate", test_earliestReliableIsLatestEarliestDate),
        ("test_emptyReposAreUnreliableRepositories", test_emptyReposAreUnreliableRepositories),
        ("test_nonEmptyReposAreNotUnreliable", test_nonEmptyReposAreNotUnreliable),
    ]
}

extension PullRequestStatTests {
    static let __allTests = [
        ("test_ClosedPullRequestStatNoOpenTime", test_ClosedPullRequestStatNoOpenTime),
        ("test_ClosedPullRequestStatWithOpenTime", test_ClosedPullRequestStatWithOpenTime),
        ("test_CommentedPullRequestStat", test_CommentedPullRequestStat),
        ("test_emptyPullRequestStat", test_emptyPullRequestStat),
        ("test_OpenedPullRequestStat", test_OpenedPullRequestStat),
        ("test_PullRequestStatAvgOpenLength", test_PullRequestStatAvgOpenLength),
        ("test_PullRequestStatMutatingAdditionEqualsNonMutatingAddition", test_PullRequestStatMutatingAdditionEqualsNonMutatingAddition),
        ("test_PullRequestStatsAddTogetherCorrectly", test_PullRequestStatsAddTogetherCorrectly),
    ]
}

extension RepoStatTests {
    static let __allTests = [
        ("testEarliestEvent_AllUsersNoEvents", testEarliestEvent_AllUsersNoEvents),
        ("testEarliestEvent_NoUsers", testEarliestEvent_NoUsers),
        ("testEarliestEvent_OneOrMoreUsers", testEarliestEvent_OneOrMoreUsers),
    ]
}

extension StatTableTests {
    static let __allTests = [
        ("test_Placeholder", test_Placeholder),
    ]
}

extension StatTests {
    static let __allTests = [
        ("test_aggregateAvg", test_aggregateAvg),
        ("test_aggregateSum", test_aggregateSum),
        ("test_LimitedStatValuesAreLimited", test_LimitedStatValuesAreLimited),
        ("test_LimitlessStatValuesAreLimitless", test_LimitlessStatValuesAreLimitless),
    ]
}

extension UserStatTests {
    static let __allTests = [
        ("test_AddingCodeStatsToUserStat", test_AddingCodeStatsToUserStat),
        ("test_AddingCodeStatsToUserStatMutating", test_AddingCodeStatsToUserStatMutating),
        ("test_AddingCodeToEmptyUserStat", test_AddingCodeToEmptyUserStat),
        ("test_AddingPullRequestStatsToUserStat", test_AddingPullRequestStatsToUserStat),
        ("test_AddingPullRequestStatsToUserStatMutating", test_AddingPullRequestStatsToUserStatMutating),
        ("test_AddingPullRequestToEmptyUserStat", test_AddingPullRequestToEmptyUserStat),
        ("test_AddingUserStatComponentsMutatingEqualsNonMutating", test_AddingUserStatComponentsMutatingEqualsNonMutating),
        ("test_AddingUserStatsAddsComponents", test_AddingUserStatsAddsComponents),
        ("test_ReplacingCodeStatsOnUserStat", test_ReplacingCodeStatsOnUserStat),
        ("test_ReplacingPullRequestStatsOnUserStat", test_ReplacingPullRequestStatsOnUserStat),
        ("test_UpdatingEarliestEventOfEmptyUserStat", test_UpdatingEarliestEventOfEmptyUserStat),
        ("test_UpdatingEarliestEventOfUserStat", test_UpdatingEarliestEventOfUserStat),
        ("test_UserStatStartsEmpty", test_UserStatStartsEmpty),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CodeStatTests.__allTests),
        testCase(OrgStatTests.__allTests),
        testCase(PullRequestStatTests.__allTests),
        testCase(RepoStatTests.__allTests),
        testCase(StatTableTests.__allTests),
        testCase(StatTests.__allTests),
        testCase(UserStatTests.__allTests),
    ]
}
#endif

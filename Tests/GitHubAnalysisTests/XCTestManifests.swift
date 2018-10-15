import XCTest

extension OrgStatTests {
    static let __allTests = [
        ("test_earliestReliableIsLatestEarliestDate", test_earliestReliableIsLatestEarliestDate),
        ("test_emptyReposAreUnreliableRepositories", test_emptyReposAreUnreliableRepositories),
        ("test_nonEmptyReposAreNotUnreliable", test_nonEmptyReposAreNotUnreliable),
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
        ("test_Placeholder", test_Placeholder),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OrgStatTests.__allTests),
        testCase(RepoStatTests.__allTests),
        testCase(StatTableTests.__allTests),
        testCase(StatTests.__allTests),
        testCase(UserStatTests.__allTests),
    ]
}
#endif

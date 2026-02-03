# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

CI verified, failing.

Is there a test coverage tool that can be used for the Rust code? Both the NIF and the underlying joltshark library.

## Objectives

### V0.1-M3: Test Coverage Setup #4

Mark V0.1-M3 as complete.
Close GitHub Issue with appropriate message.

### V0.1-M4: Birdeye API Integration #5

Please implement V0.1-M4.
- Research Birdeye API endpoints and authentication
- Create CordialCantina.Integration.Birdeye module
- Implement OHLCV data fetching
- Add rate limiting and error handling
- Write tests with Bypass mocks

### Resolve Failing CI

Resolve failing CI.
See the following URL.
https://github.com/sgeos/cordial_cantina/actions/runs/21613626760/job/62287626863

Failing step is "Run precommit checks".

## Context

Moving on with the implementation.

## Constraints

Using the free tier of Birdeye.
This tier is rate limited.
If the rate limt is 60/requests a minute, the the rate probably wants to be slightly slower.
If more than one endpoint needs to be polled, it may make sense to have a list of that is cycled through for updates.
For example:
```
URL_A : 0, 3, 6 ...
URL_B : 1, 4, 7 ...
URL_C : 2, 5, 8 ...
```

## Success Criteria

- V0.1-M3 issue #4 closed with appropriate message.
- Can fetch historical OHLCV data from Birdeye
- Rate limits respected
- Error cases handled gracefully
- Tests pass with mocked responses
- CI issue resolved. Tested and working locally.

## Notes

Consider a clean build to test the CI.

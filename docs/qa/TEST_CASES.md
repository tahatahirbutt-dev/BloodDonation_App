# Manual test cases

Priority: **P1** must pass before any demo, **P2** should pass, **P3** nice to have. "Auto" names an automated test that covers the same behaviour. Record results in [MANUAL_TEST_RUN.md](MANUAL_TEST_RUN.md).

Accounts used: **A** (requester, blood group A+) and **B** (donor, blood group B+ or O+, available, no recent donation). Both email-verified.

## Authentication and profile

| ID | Pri | Test | Steps | Expected | Auto |
|---|---|---|---|---|---|
| TC-AUTH-01 | P1 | Sign up and verify | Create account, check email, tap link, return and refresh | Taken to profile setup after verification | auth flow tests |
| TC-AUTH-02 | P2 | Unverified user is held back | Sign up, do not verify, reopen app | Verify-email screen, no access to home | gate tests |
| TC-AUTH-03 | P2 | Wrong password | Sign in with a wrong password | Clear error message, stays on sign-in | auth tests |
| TC-AUTH-04 | P2 | Sign out | Tap sign out on home | Back on sign-in | gate tests |
| TC-PROF-01 | P1 | Create profile | Fill name, phone, blood group, area, optional last donation | Home opens, profile tab shows the details | profile flow |
| TC-PROF-02 | P1 | 90-day eligibility | Set last donation to 30 days ago | Profile says when donation is possible again, and "I can help" is disabled on requests | eligibility tests |
| TC-PROF-03 | P2 | Hide from search | Turn off "Show me in donor search", then search as the other account | The donor is not listed | profile tab tests |
| TC-PROF-04 | P2 | Unavailable | Turn off "I am available to donate" | Feed shows a banner, "I can help" is disabled | profile tab tests |

## Requests

| ID | Pri | Test | Steps | Expected | Auto |
|---|---|---|---|---|---|
| TC-REQ-01 | P1 | Post a request | As A: tap Request blood, choose blood group, hospital, units, urgency, submit | Snackbar "Request posted. Donors who can help will respond.", request appears under My requests | request flow |
| TC-REQ-02 | P1 | Validation | Submit with no blood group or no hospital | Form stays open, nothing is created | request flow |
| TC-REQ-03 | P2 | Open-request cap | Post 3 open requests, then try a 4th | Refused with a clear message | post_blood_request test |
| TC-REQ-04 | P1 | Feed shows only compatible requests | As B, open Requests | Requests A posted for a group B can donate to are listed; others are not; B's own requests never appear | get_nearby_requests, request flow |
| TC-REQ-05 | P2 | Ordering | Have a critical and a planned request | Critical is listed first | request flow |
| TC-REQ-06 | P2 | Empty state | New account, no requests | "No blood requests yet" | request flow |
| TC-REQ-07 | P2 | Request expires | Check a request past its expiry time | It no longer appears in the feed | entities tests |

## Responding and privacy

| ID | Pri | Test | Steps | Expected | Auto |
|---|---|---|---|---|---|
| TC-RESP-01 | P1 | I can help needs confirmation | As B: open a request, tap I can help | Dialog "Share your number?" with Cancel | request flow |
| TC-RESP-02 | P1 | Confirm | Confirm in the dialog | Screen says "You offered to help." and A sees B under "Donors who can help" with name, area and number | request flow |
| TC-RESP-03 | P2 | Cancel shares nothing | Tap Cancel in the dialog | No response is created, button still available | request flow |
| TC-RESP-04 | P2 | Withdraw | As B: tap Withdraw | Offer disappears for A | request flow |
| TC-RESP-05 | P1 | Own request | As A, open own request in the feed or detail | There is no "I can help" button for own request | respond_to_request test |
| TC-RESP-06 | P2 | Copy number | As A: tap copy | Snackbar "Number copied" and the number is on the clipboard | request flow |
| TC-RESP-07 | P2 | Call button | As A: tap call | Phone dialer opens with the number filled in, no call is placed automatically | call button test |
| TC-PRV-01 | P1 | No number before consent | As B, before tapping I can help, inspect what A and the donor directory show | No phone number anywhere | rules tests |
| TC-PRV-02 | P1 | Number only for the right requester | Offer on A's request. Sign in as a third account C | C cannot see B's number | rules tests |
| TC-PRV-03 | P1 | Search never shows numbers | Search donors as A | Results show name, group, area, distance and no phone | donor search flow |

## Closing requests

| ID | Pri | Test | Steps | Expected | Auto |
|---|---|---|---|---|---|
| TC-CLOSE-01 | P1 | Mark fulfilled | As A: Mark as fulfilled, confirm | Status becomes fulfilled, request leaves B's feed | request flow |
| TC-CLOSE-02 | P2 | Cancel | As A: Cancel request, confirm | Status becomes cancelled | request flow |
| TC-CLOSE-03 | P3 | Back from confirmation | Open a confirm dialog and go back | Nothing changes | request flow |

## Donor search

| ID | Pri | Test | Steps | Expected | Auto |
|---|---|---|---|---|---|
| TC-SRCH-01 | P1 | Search by group and place | Choose blood group and area, search | Compatible, available, eligible donors listed nearest first | donor search flow |
| TC-SRCH-02 | P2 | Radius | Repeat at 5 km and 50 km | Fewer results at 5 km, only donors inside the radius | search_donors test |
| TC-SRCH-03 | P2 | Empty result | Search where nobody matches | "No matching donors nearby" and an option to post a request | donor search flow |

## Resilience

| ID | Pri | Test | Steps | Expected | Auto |
|---|---|---|---|---|---|
| TC-RES-01 | P1 | Offline | Turn on airplane mode, open Requests | Friendly error with Try again, no crash | request flow |
| TC-RES-02 | P1 | Recover | Turn network on, tap Try again | List loads | request flow |
| TC-RES-03 | P2 | Offline submit | Offline, submit a new request | Error message, form stays open | request flow |
| TC-RES-04 | P2 | Session ends mid-flow | Open a request detail, then sign out from another way (or revoke session) | Returned to sign-in, no stuck screen | request flow |
| TC-RES-05 | P2 | First open with indexes still building | New Firebase project before indexes finish | "This feature is still being set up" message, not a crash | failure mapper test |

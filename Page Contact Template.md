# Page Contract Template

## Page Name

## Module / Week

## Assigned

- Front End:
- Back End:
- Database:
- Testing:

## Open Questions / Decisions Needed

-

## Front End Variables

Every field or control the page's UI sends to the Back End (form fields, query-string params on a lookup page, etc.).

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| | | | |

## Back End Parameters

What the Back End reads for each Front End field, plus anything it pulls from elsewhere (session, query string) rather than the form itself.

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| | | | |

## Database Returns

Every query or DAO method the Back End calls for this page, and its exact return shape — including what it returns on "no match" (null vs. empty object vs. exception).

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| | | | |

## Validation Rules

- **Client-side (UX only, not trusted):**
- **Server-side (source of truth):**

## Error Handling

Every user-facing error condition this page can hit, and exactly what the user sees.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| | | |

# Historical schema exemptions

`tatr check` validates every sibling record against its schema, and `tatr flow`
gates its transitions on the same rules. The records below were written before
the rule they now trip, and the flow trail is append-only history: a task
record is not rewritten to satisfy a rule invented after it landed. Each line
classifies one such record explicitly.

Format, one exemption per line:

```
- <task-id> <rule>: <why this record is exempt>
```

An entry suppresses that rule for that task only. An entry that never fires is
reported as `unused-exemption` on a full `tatr check`, so the list cannot rot:
when a record is legitimately rewritten, its exemption must go with it.

New work does not get exemptions. Scaffold the record with
`tatr scaffold <id> <RECORD>` and it is schema-clean from the first byte.

## Pre-v2 records

- 20260330-202900 bad-record-schema: pre-v2 record, free-form headings
- 20260330-202900 closed-missing-review: pre-v2 cycle, no review record was written
- 20260330-202900 closed-missing-retro: pre-v2 cycle, no retro record was written
- 20260401-135508 bad-record-schema: pre-v2 record, free-form headings
- 20260401-135508 closed-missing-review: pre-v2 cycle, no review record was written
- 20260401-135508 closed-missing-retro: pre-v2 cycle, no retro record was written

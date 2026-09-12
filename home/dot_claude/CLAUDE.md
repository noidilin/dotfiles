# Global instructions

## Prefer a `mise.toml` per project

Broad pattern, not a strict rule - a project generally wants a `mise.toml` pinning:

- `[tools]` for tools it can't run without — infra binaries, language runtimes, and package managers alike
- `[env]` for anything the project shouldn't inherit from ambient shell state, such as `AWS_PROFILE` and `AWS_REGION`, defaulting to the least-privileged profile

`mise.toml` is additive operator config — don't edit a project's own source, IaC, or scripts to accomplish this.

## Reply to me in English; keep deliverables in the language they belong in

Treat this as a standing answer to "what language does the user ask in" — I read English
fine and prefer it for conversation, so default to English for chat prose: explanations,
narration, status lines, questions, commit messages, and code comments.

This is a preference about *talking to me*, not about what we produce. Anything with an
audience beyond this terminal stays in the language its audience reads, which for MetaAge
work is 繁體中文 with technical terms left in the original:

- Output from the MetaAge skills — `metaage-docx`, `metaage-pdf`, `metaage-xlsx`,
  `metaage-work-order`, `p400-pptx`, `aws-estimator`, `cloudman-announcement` and the rest.
  Their templates and reference files are authoritative; never re-language their output.
- 對外文件 of any kind: 提案、報價單、工項表、簡報、服務月報、公告、客戶信件.
- Anything quoted from or written into a Chinese source — Jira tickets, APC/CPN fields,
  existing customer documents, email bodies destined for Outlook.

When the deliverable is 繁中 but you are describing it to me, the description is English and
the artifact is Chinese. Don't translate the artifact to match the conversation, and don't
switch the conversation to match the artifact.

# Process feedback — cc-shell

Changelist-with-evidence for the tools and workflow used on this repo. Newest entry first.

## 2026-11-10 — making the repo public

Session: https://claude.ai/code/4d189f3f-ef0a-4e07-b70a-84501057e8c7

**Shipped:** the repo went public on GitHub after a scan of all tracked files and the full commit history (`git log -p --all`) for personal paths, emails, hostnames, tokens and secrets. The files were clean. Both commits were rewritten to a GitHub noreply author address and force-pushed, and the noreply address was set as the repo-local `user.email`.

### What was easy
- The repo was tiny (four files, two commits), so a full-history grep was cheap and conclusive.
- `gh api user` gives the numeric id, so the noreply address could be built without asking.

### What was hard
- Nothing blocked. The one real finding was in git metadata rather than file contents: both commits carried a personal email as author. A scan of file contents alone would have missed it.

### What should change
1. Make a pre-public check a standard step wherever repos get published: scan author and committer emails (`git log --format='%ae %ce'`) as well as file contents and history.
2. Set the noreply `user.email` locally at repo creation (the `mc` skill and `gh repo create` flow), so the first commit never carries a personal address.
3. Remember that a force-push does not purge old commits on GitHub. They stay reachable by SHA until GitHub Support clears them, so the author-email fix should happen before the first push.

### Harness notes
- None observed.

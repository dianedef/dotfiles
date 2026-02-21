---
name: task-help
description: Complete guide to the task management system (tasks, priorities, backlog, review)
disable-model-invocation: true
---

# 📋 Task Management System Guide

Welcome to your intelligent task management system! This guide covers all four skills and how to use them effectively.

---

## 🎯 The Four Skills

### 1. `/tasks` - Daily Task Management
**Purpose:** Keep TASKS.md current with what's done and what's next

**When to use:**
- Start of work session (see what's pending)
- After completing work (check off done items)
- When you need to know what to do next

**Usage:**
```bash
/tasks                    # General update and next step suggestion
/tasks testing            # Focus on testing-related tasks
/tasks deployment         # Focus on deployment tasks
/tasks "CI/CD setup"      # Focus on specific area
```

**What it does:**
- ✅ Marks completed tasks as done
- ➕ Adds missing tasks based on project state
- 💡 Suggests highest priority next action
- 🏗️ Creates/maintains organized TASKS.md structure

**Output:** Updated TASKS.md with sections:
- Completed (with timestamps)
- In Progress
- Todo
- Notes

---

### 2. `/priorities` - Smart Prioritization
**Purpose:** Organize tasks by impact/effort to focus on what matters

**When to use:**
- When you have too many tasks and don't know where to start
- Weekly planning sessions
- After adding several new tasks
- When priorities shift

**Usage:**
```bash
/priorities               # Balanced prioritization
/priorities impact        # Sort by business value
/priorities effort        # Show quick wins (low effort, high impact)
/priorities blockers      # Prioritize tasks that unblock others
/priorities quick-wins    # Alias for low-effort, high-impact
```

**What it does:**
- 🔴 **P0 (Critical):** Blockers, security issues, high ROI tasks
- 🟠 **P1 (High):** Important features, medium effort
- 🟡 **P2 (Medium):** Standard work, nice improvements
- 🟢 **P3 (Low):** Nice to have, low impact, can wait

**Prioritization criteria:**
- **Impact:** How much value does this deliver?
- **Effort:** How much work is required?
- **Blockers:** Does this unblock other tasks?
- **Dependencies:** What must be done first?
- **Risk:** What happens if we delay this?

**Output:** Reorganized TASKS.md with priority sections and metadata like:
```markdown
## 🔴 P0 - Critical (Do First)
- [ ] Fix authentication bug [Impact: High | Effort: Low | Unblocks: 3 tasks]
```

---

### 3. `/backlog` - Future Work Management
**Purpose:** Capture ideas and defer non-urgent work to keep active tasks focused

**When to use:**
- When you have an idea but can't work on it now
- Weekly cleanup (move non-urgent tasks out of active list)
- When reviewing what should become active
- Finding old TODOs in code

**Usage:**
```bash
/backlog add "AI-powered search"              # Add new idea to backlog
/backlog defer                                # Move non-urgent tasks from TASKS.md
/backlog review                               # Check what's ready to promote
/backlog clean                                # Remove outdated items
/backlog                                      # General organization
```

**What it does:**
- 💡 Captures ideas with context and dates
- 📦 Moves low-priority tasks out of active work
- 🔍 Harvests TODO/FIXME comments from code
- 🧹 Archives or removes obsolete items
- ⬆️ Promotes ready items back to active tasks

**BACKLOG.md structure:**
- **Future Features:** New functionality ideas
- **Technical Debt:** Refactoring and improvements
- **Ideas & Research:** Exploratory tasks
- **Deferred:** Tasks moved from active (with reasons)
- **Discarded:** Removed items (with reasons, for history)

**Best practice:** Keep TASKS.md focused (5-10 active items), backlog can be larger (20-50 items)

---

### 4. `/review` - Work Review & Documentation
**Purpose:** Reflect on completed work, update docs, plan next session

**When to use:**
- End of day (daily standup)
- End of week (weekly review)
- End of sprint (~2 weeks)
- Before a release

**Usage:**
```bash
/review                   # Smart scope based on commit frequency
/review daily             # Last 24 hours
/review weekly            # Last 7 days
/review sprint            # ~2 weeks
/review release           # Since last release tag
```

**What it does:**
- 📊 Analyzes git commits and completed tasks
- 📝 Updates CHANGELOG.md with user-facing changes
- 🎯 Plans next session priorities
- 🏆 Highlights wins, learnings, and metrics
- 📄 Creates review report (REVIEW-[DATE].md)
- 🗂️ Archives old completed tasks

**Review includes:**
- **Completed:** What was finished (with evidence)
- **In Progress:** What's partially done
- **Blocked:** What's stuck and why
- **Learned:** Key insights or discoveries
- **Metrics:** Commits, files changed, test coverage
- **Next Steps:** Recommended priorities

---

## 🔄 Recommended Workflows

### Daily Workflow
```bash
# Morning (5 min)
/tasks                    # See what's done, what's next
# Recommended: Start with suggested task

# During work
# ... code, commit, test ...

# Evening (5 min)
/tasks                    # Check off what you completed
/review daily             # Document progress
```

### Weekly Workflow
```bash
# Monday Morning (15 min)
/review weekly            # Review last week's work
/priorities               # Re-prioritize based on progress
/backlog review           # Promote ready items to active

# During week
# ... daily workflow ...

# Friday Afternoon (10 min)
/backlog defer            # Move non-urgent tasks to backlog
/priorities quick-wins    # Plan next week's quick wins
```

### Sprint/Release Workflow
```bash
# Sprint Start
/review sprint            # Comprehensive review
/priorities impact        # Plan high-impact work
/backlog review           # Pull in ready items

# Sprint End
/review sprint            # Document achievements
/backlog clean            # Remove outdated items
/tasks                    # Clean slate for next sprint
```

---

## 💡 Pro Tips

### Getting Started
1. Start with `/tasks` in your current project
2. Let it create TASKS.md automatically
3. Run `/priorities` to organize them
4. Use `/backlog add` when ideas come up

### Keeping It Effective
- **Daily:** Run `/tasks` at start and end of day
- **Weekly:** Run `/priorities` and `/backlog review`
- **Keep active tasks small:** 5-10 items max in TASKS.md
- **Be specific:** "Add user auth" → "Add JWT authentication to /api/login"
- **Date everything:** Helps with reviews and cleanup

### Common Patterns
```bash
# Just finished a feature?
/tasks                    # Check it off and get next task

# Too many tasks?
/priorities effort        # Find quick wins
/backlog defer            # Move non-urgent items

# Not sure what to work on?
/priorities blockers      # Find tasks that unblock others

# End of sprint?
/review sprint            # Document everything
/backlog clean            # Clean up old ideas
```

### Task Writing Best Practices
**Good tasks:**
- [ ] Add error handling to payment API (2 hours)
- [ ] Write unit tests for UserService (covers auth flows)
- [ ] Deploy staging environment to AWS (needs env vars)

**Bad tasks:**
- [ ] Fix stuff
- [ ] Make it better
- [ ] TODO: look at this

**Include:**
- Clear outcome (what done looks like)
- Estimated effort (rough size)
- Dependencies or prerequisites
- Context (why it matters)

---

## 📁 File Structure

Your task management creates/maintains these files:

```
/your-project/
├── TASKS.md              # Active work (5-10 items)
├── BACKLOG.md            # Future work (20-50 items)
├── CHANGELOG.md          # User-facing changes
└── REVIEW-YYYY-MM-DD.md  # Review reports (generated by /review)
```

**TASKS.md** - Current sprint/week work
- Completed (recently done)
- In Progress (actively working)
- Todo (prioritized next steps)
- Notes (context, blockers)

**BACKLOG.md** - Future and deferred work
- Future Features
- Technical Debt
- Ideas & Research
- Deferred (from active)
- Discarded (archived)

**CHANGELOG.md** - Release documentation
- Semantic versioning sections
- User-facing changes only
- Categories: Added, Changed, Fixed, Security, Deprecated

**REVIEW-[DATE].md** - Review reports
- Generated by `/review`
- Snapshot of progress
- Learnings and metrics

---

## 🎨 Customization

### Adjust to Your Style
The skills adapt to your workflow:
- **Solo dev:** Use daily workflow, keep it simple
- **Team lead:** Use sprint workflow, detailed reviews
- **Side project:** Use weekly workflow, capture ideas in backlog

### Combine with Other Skills
```bash
/tasks                    # See what's next
# ... work on task ...
/ship "Implement feature X"   # Ship it
/tasks                    # Auto-checks off completed task
```

### Arguments Customize Behavior
- `/tasks testing` - Focus on specific area
- `/priorities impact` - Change sorting criteria
- `/backlog add "idea"` - Quick capture
- `/review weekly` - Set scope

---

## 🆘 Troubleshooting

**"TASKS.md not updating"**
- File might not exist - `/tasks` will create it
- Check you're in the right directory (`pwd`)
- Run `/tasks` without arguments first

**"Too many tasks, feeling overwhelmed"**
```bash
/priorities effort        # Find quick wins
/backlog defer            # Move non-urgent items
```

**"Don't know what to work on next"**
```bash
/priorities blockers      # Find critical path
```

**"Lost track of what I did"**
```bash
/review daily             # See your progress
```

**"Backlog is a mess"**
```bash
/backlog clean            # Clean up old items
```

---

## 🚀 Quick Reference

| Situation | Command |
|-----------|---------|
| Start of day | `/tasks` |
| End of day | `/tasks` then `/review daily` |
| Too many tasks | `/priorities` then `/backlog defer` |
| New idea | `/backlog add "description"` |
| Don't know what next | `/priorities blockers` |
| Need quick win | `/priorities quick-wins` |
| End of week | `/review weekly` |
| Before release | `/review release` |
| Clean up | `/backlog clean` |

---

## 📚 Examples

### Example 1: Starting Fresh
```bash
cd /root/my-project
/tasks                    # Creates TASKS.md, lists current work
/priorities               # Organizes by priority
# Work on P0 task suggested
/tasks                    # Checks off completed, suggests next
```

### Example 2: Weekly Planning
```bash
# Monday
/review weekly            # "Completed 8 tasks, 3 in progress, 2 blocked"
/priorities impact        # Re-prioritize for high-value work
/backlog review           # "These 2 items are ready to promote"

# Friday
/backlog defer            # Moves 5 non-urgent tasks to backlog
/review weekly            # Documents week's progress
```

### Example 3: Capturing Ideas
```bash
# During work, idea pops up
/backlog add "Add dark mode to dashboard"
# Continues working

# End of week
/backlog review           # Sees dark mode idea
# Promotes to active tasks if ready, or leaves in backlog
```

---

## 🎓 Philosophy

This system follows these principles:

1. **Active work stays small** - Focus on 5-10 tasks max
2. **Backlog captures everything** - Never lose an idea
3. **Priorities guide decisions** - Impact + effort trumps gut feel
4. **Reviews create learning** - Reflect on what worked
5. **Automation reduces friction** - Let Claude handle the bookkeeping

**Remember:** The tools serve you, not the other way around. Adapt the workflow to fit your needs!

---

## 📞 Getting Help

- **This guide:** `/task-help`
- **General help:** `/help`
- **Skill list:** Available skills shown in system reminders
- **Feedback:** https://github.com/anthropics/claude-code/issues

---

*Last updated: 2026-02-15*
*Part of Claude Code task management system*

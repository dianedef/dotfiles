# BMAD Method Usage Guide

Learn how to use the BMAD (Build More, Architect Dreams) Method with this dotfiles repository.

## What is BMAD?

BMAD is a **structured AI-driven development methodology** that uses specialized agents to:
- Plan and document features systematically
- Maintain high-quality code and documentation
- Follow agile best practices with AI assistance
- Scale from quick fixes to enterprise features

## Installed BMAD Agents

The following specialized agents are available in `.github/agents/`:

### Core Agents
1. **🎯 BMad Master** (`@bmd-custom-core-bmad-master`)
   - Project coordinator and workflow guide
   - Use for: Project initialization, workflow selection

2. **💻 Developer** (`@bmd-custom-bmm-dev`)
   - Code implementation and debugging
   - Use for: Writing code, fixing bugs, refactoring

3. **📝 Tech Writer** (`@bmd-custom-bmm-tech-writer`)
   - Documentation creation and improvement
   - Use for: Writing guides, updating docs, creating tutorials

4. **🏗️ Architect** (`@bmd-custom-bmm-architect`)
   - System design and configuration planning
   - Use for: Designing new features, architecture decisions

5. **🔍 Analyst** (`@bmd-custom-bmm-analyst`)
   - Requirement analysis and research
   - Use for: Understanding problems, gathering requirements

### Project Management Agents
6. **📊 PM (Product Manager)** (`@bmd-custom-bmm-pm`)
   - Feature planning and prioritization
   - Use for: Creating PRDs, planning features

7. **🏃 Scrum Master** (`@bmd-custom-bmm-sm`)
   - Sprint planning and task management
   - Use for: Breaking down work, managing sprints

### Specialized Agents
8. **🧪 Test Architect** (`@bmd-custom-bmm-tea`)
   - Testing strategy and quality assurance
   - Use for: Test planning, test automation

9. **🎨 UX Designer** (`@bmd-custom-bmm-ux-designer`)
   - User experience and interface design
   - Use for: UI improvements, user flows

10. **⚡ Quick Flow Solo Dev** (`@bmd-custom-bmm-quick-flow-solo-dev`)
    - Fast development for small changes
    - Use for: Bug fixes, quick features, simple updates

## Common Workflows

### 1. Initialize BMAD for Your Project

**First time only:**
```
@bmd-custom-core-bmad-master *workflow-init
```

This analyzes your project and recommends the right workflow track.

### 2. Quick Bug Fix or Small Feature

**Use Quick Flow for fast changes:**
```
@bmd-custom-bmm-quick-flow-solo-dev *workflow-quick-flow
```

**Example scenarios:**
- Fix broken script
- Add new alias
- Update configuration
- Small documentation fix

### 3. Adding New Tool Configuration

**Step 1: Plan with PM**
```
@bmd-custom-bmm-pm *workflow-planning-prd

Task: Add configuration for [tool name]
Requirements:
- Cross-platform support (Windows, Linux, Termux)
- Follows existing dotfiles structure
- Includes documentation
```

**Step 2: Design with Architect**
```
@bmd-custom-bmm-architect *workflow-solutioning-architecture

Based on the PRD, design the configuration structure
```

**Step 3: Implement with Developer**
```
@bmd-custom-bmm-dev *workflow-implementation-story

Implement the [tool] configuration following the architecture
```

**Step 4: Document with Tech Writer**
```
@bmd-custom-bmm-tech-writer

Create documentation for the new [tool] configuration
Include: installation, configuration, usage, troubleshooting
```

### 4. Improve Existing Documentation

**Use Tech Writer directly:**
```
@bmd-custom-bmm-tech-writer

Review and improve documentation for [topic]
Ensure:
- Clear structure
- Code examples work
- Cross-references correct
- Beginner-friendly
```

### 5. Major Feature Development

**Full BMAD Method workflow:**

1. **Analysis Phase** (Optional)
```
@bmd-custom-bmm-analyst *workflow-analysis-brief

Analyze the need for [feature/improvement]
```

2. **Planning Phase**
```
@bmd-custom-bmm-pm *workflow-planning-prd

Create PRD for [feature]
```

3. **Solutioning Phase**
```
@bmd-custom-bmm-architect *workflow-solutioning-architecture

Design architecture for [feature]
```

4. **Implementation Phase**
```
@bmd-custom-bmm-sm *workflow-implementation-shard

Break down work into manageable stories
```

```
@bmd-custom-bmm-dev *workflow-implementation-story

Implement story: [story name]
```

5. **Quality Assurance**
```
@bmd-custom-bmm-tea *workflow-solutioning-test-architecture

Create test plan for [feature]
```

## Workflow Selection Guide

| Project Size | Recommended Track | Agent to Start |
|-------------|-------------------|----------------|
| **Bug Fix** | Quick Flow | Quick Flow Solo Dev |
| **Small Feature** | Quick Flow | Quick Flow Solo Dev |
| **New Tool Config** | BMad Method | PM → Architect → Dev |
| **Documentation** | Direct Agent | Tech Writer |
| **Major Feature** | BMad Method | Analyst → PM → Architect |
| **Refactoring** | BMad Method | Architect → Dev |

## Tips for Effective BMAD Usage

### 1. Start with the Right Agent
- **Don't know which agent?** Start with BMad Master
- **Documentation task?** Go directly to Tech Writer
- **Quick fix?** Use Quick Flow Solo Dev

### 2. Provide Context
Always give agents context:
```
@bmd-custom-bmm-dev

Context: This is a dotfiles repository for multi-platform use
Task: Add Alacritty terminal configuration
Constraints: Must work on Windows, Linux, and Termux
```

### 3. Use Workflows for Structure
Workflows provide step-by-step guidance:
- `*workflow-quick-flow` - Fast path
- `*workflow-planning-prd` - Create requirements
- `*workflow-implementation-story` - Build feature

### 4. Chain Agents for Complex Tasks
Pass output from one agent to the next:
1. PM creates PRD
2. Architect designs solution (references PRD)
3. Developer implements (references architecture)
4. Tech Writer documents (references implementation)

### 5. Iterate and Refine
BMAD supports iteration:
- Ask agents to review their own work
- Request improvements
- Get second opinions from different agents

## Example: Adding Alacritty Configuration

**Real-world example of full workflow:**

```
# Step 1: Initialize (if first time)
@bmd-custom-core-bmad-master *workflow-init

# Step 2: Quick assessment
@bmd-custom-bmm-analyst
Analyze: Should we add Alacritty terminal configuration?
Consider: cross-platform support, user needs, maintenance

# Step 3: Create plan
@bmd-custom-bmm-pm *workflow-planning-prd
Feature: Alacritty terminal configuration
Platforms: Windows, Linux
Requirements: [list requirements]

# Step 4: Design
@bmd-custom-bmm-architect *workflow-solutioning-architecture
Design Alacritty config structure following dotfiles patterns

# Step 5: Implement
@bmd-custom-bmm-dev *workflow-implementation-story
Implement Alacritty configuration based on architecture

# Step 6: Document
@bmd-custom-bmm-tech-writer
Create comprehensive documentation for Alacritty setup
Include: installation, configuration, customization, troubleshooting

# Step 7: Test
@bmd-custom-bmm-tea
Verify installation works on all platforms
```

## Agent Personalities

Each agent has a distinct personality:
- **BMad Master**: Guiding and coordinating
- **Developer**: Pragmatic and solution-focused
- **Tech Writer**: Clear and educational
- **Architect**: Strategic and structured
- **PM**: User-focused and business-aware

## BMAD in Daily Workflow

### Morning: Documentation Review
```
@bmd-custom-bmm-tech-writer
Review yesterday's changes and update documentation
```

### During Development: Quick Fixes
```
@bmd-custom-bmm-quick-flow-solo-dev *workflow-quick-flow
Fix: [describe issue]
```

### Planning Session: New Features
```
@bmd-custom-bmm-pm *workflow-planning-prd
Plan next sprint features
```

### End of Day: Code Review
```
@bmd-custom-bmm-architect
Review today's changes for architecture consistency
```

## Resources

### BMAD Documentation
- [Official BMAD Repository](https://github.com/bmad-code-org/BMAD-METHOD)
- [BMAD Quick Start](https://github.com/bmad-code-org/BMAD-METHOD#-get-started-in-3-steps)
- [BMAD Discord Community](https://discord.gg/gk8jAdXWmj)

### Local BMAD Files
- Agents: `.github/agents/`
- Config: `_bmad/_config/`
- Module: `_bmad/bmm/`

## Troubleshooting BMAD

### Agent Not Responding
- Check agent name is spelled correctly
- Ensure using `@` prefix
- Verify agent exists in `.github/agents/`

### Workflow Command Not Working
- Workflows start with `*workflow-`
- Use tab completion if available
- Check workflow exists for that agent

### Need Different Agent
Run `*workflow-init` with BMad Master to see all agents and workflows

## Next Steps

1. **Try Quick Flow**: Use Quick Flow Solo Dev for your next small task
2. **Explore Agents**: Test different agents to learn their strengths
3. **Read Docs**: Check `_bmad/bmm/docs/` for comprehensive guides
4. **Join Community**: Connect with other BMAD users on Discord

---

**Ready to Build More and Architect Dreams?** Start with `@bmd-custom-core-bmad-master *workflow-init`

# DiffFlowz Editable Git Review Checklist

Run in a disposable Git repository with two modified files and one staged file.

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
|-------------|---------|----------|----------|----------|--------|----------|------------------|-------|----------|
| DF-01 | Neovim + Difftastic | Run `:DiffFlowz` with two working-tree changes. | yes | The inline review opens and combines both files in one rendered view. | NOT_RUN | | | | |
| DF-02 | Neovim + Git | Open a changed file buffer from the repo and save an edit outside the diff view. | yes | The file contains the edit; Git index is unchanged. | NOT_RUN | | | | |
| DF-03 | Neovim + Git | Run `:DiffFlowz` in a clean repository. | yes | A clear notification appears and no review session opens. | NOT_RUN | | | | |
| DF-04 | Neovim + Difftastic | Run `:DiffFlowzStaged` with an index-only change. | yes | The staged inline diff opens. | NOT_RUN | | | | |
| DF-05 | Neovim + Neogit | Open Neogit and use its diff popup after DiffFlowz is installed. | yes | Neogit uses the local inline backend without a viewer error. | NOT_RUN | | | | |

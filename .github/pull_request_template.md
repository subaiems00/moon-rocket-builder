name: Pull request
description: Open a PR against moon-rocket-builder
title: "[phase-N] Short description"
labels: []
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        Thanks for opening a PR! Please fill in the sections below.
  - type: dropdown
    id: phase
    attributes:
      label: Which phase does this affect?
      options:
        - Phase 2 — gameplay
        - Phase 3 — visuals
        - Phase 4 — feel
        - Phase 5 — polish
        - Multiple / cross-cutting
        - Docs only
    validations:
      required: true
  - type: checkboxes
    id: checklist
    attributes:
      label: Self-review
      description: Confirm before requesting review.
      options:
        - label: I ran the project locally and tested my change.
        - label: I read CONTRIBUTING.md and the project conventions.
        - label: I updated CHANGELOG.md (if user-visible).
        - label: I added/updated docs/phase-N.md (if user-visible).
  - type: textarea
    id: what
    attributes:
      label: What does this PR change?
      description: One paragraph summary.
    validations:
      required: true
  - type: textarea
    id: why
    attributes:
      label: Why?
      description: What problem does this solve, or what fun does it add?
  - type: textarea
    id: testing
    attributes:
      label: How did you test it?
      description: Manual steps, screenshots, or CI logs.

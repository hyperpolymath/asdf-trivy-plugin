;; SPDX-License-Identifier: AGPL-3.0-or-later
;; STATE.scm - Current project state

(state
  (metadata
    (version "1.0.0")
    (schema-version "1.0")
    (created "2026-01-08")
    (updated "2026-01-08")
    (project "asdf-trivy-plugin")
    (repo "https://github.com/hyperpolymath/asdf-trivy-plugin"))

  (project-context
    (name "asdf-trivy-plugin")
    (tagline "asdf plugin for Trivy vulnerability scanner")
    (tech-stack "bash" "shellcheck"))

  (current-position
    (phase "active")
    (overall-completion 80)
    (components
      (list-all "complete")
      (download "complete")
      (install "complete")
      (help "complete"))
    (working-features
      "version listing"
      "binary download"
      "installation"
      "version switching"))

  (route-to-mvp
    (milestone "1.0"
      (items
        "Core plugin functionality"
        "CI/CD pipeline"
        "Documentation")))

  (blockers-and-issues
    (critical)
    (high)
    (medium)
    (low))

  (critical-next-actions
    (immediate)
    (this-week)
    (this-month)))

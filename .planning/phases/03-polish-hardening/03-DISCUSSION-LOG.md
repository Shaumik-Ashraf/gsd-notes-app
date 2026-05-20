# Phase 3: Polish & Hardening - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-20
**Phase:** 3-polish-hardening
**Areas discussed:** UI polish scope, Mailer for password recovery, Security hardening, Deployment with Kamal and Docker

---

## UI Polish Scope

### Visual quality

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal/functional | Clean spacing, readable typography. Matches existing sign-in card. | |
| Simple but polished | Consistent design language, color accents, button styles, more finished. | ✓ |
| You decide | Claude picks style consistent with what already exists. | |

**User's choice:** Simple but polished — Apple-inspired, black and white color palette.

---

### Notes table row/action design

| Option | Description | Selected |
|--------|-------------|----------|
| Row click opens note, icons in last column | Clicking anywhere on row navigates. Edit/delete icons in dedicated Actions column. | ✓ |
| Title link, separate action buttons per row | Title is a link. Edit/Delete are small buttons in a separate column. | |
| You decide | Claude picks row/action pattern. | |

**User's choice:** Row click opens note, icons in last column.

---

### Body editor UX

| Option | Description | Selected |
|--------|-------------|----------|
| Plain textarea with label | Styled textarea, no JS editor. 'Write markdown here' label/placeholder. | ✓ |
| Side-by-side textarea + live preview | Two-pane editor with Stimulus-driven preview. | |
| You decide | Claude picks editor style. | |

**User's choice:** Plain textarea with label.

---

### Note show page actions placement

| Option | Description | Selected |
|--------|-------------|----------|
| Top-right action bar with buttons | Edit and Delete buttons in top-right. Delete requires confirmation. | ✓ |
| Bottom of the page below content | Actions appear at the bottom after body and attachment. | |
| You decide | Claude places actions. | |

**User's choice:** Top-right action bar.

---

### Nav bar design

| Option | Description | Selected |
|--------|-------------|----------|
| App name 'Notes' text logo, left-aligned | Wordmark on the left, sign-out link on the right. | ✓ |
| No logo, just nav links | Sign-out link in corner, no branding. | |
| You decide | Claude designs nav bar. | |

**User's choice:** "Notes" wordmark left-aligned.

---

### "New Note" button

| Option | Description | Selected |
|--------|-------------|----------|
| Top-right of page, dark filled button | Solid dark fill. Matches Apple's primary action button pattern. | ✓ |
| Inline with the page heading | Button sits next to the title/heading. | |
| You decide | Claude places it. | |

**User's choice:** Top-right, dark filled button.

---

## Mailer for Password Recovery

### Enable ActionMailer in Phase 3?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — configure for production | Wire up a real delivery provider. | |
| No — keep as-is (console only) | Webmaster resets via Rails console. | |
| Document only | Add TODO. Don't configure. | ✓ |

**User's choice (freeform):** Document with the intention of various possible production setups — such as using sendmail or using Gmail SMTP.

---

### Where should documentation live?

| Option | Description | Selected |
|--------|-------------|----------|
| CLAUDE.md | Already the AI/contributor guide. | |
| Separate DEPLOYMENT.md or SETUP.md | Dedicated ops/deployment guide. | |
| config/environments/production.rb comments | Inline comments in the production config. | |

**User's choice (freeform):** Add a DEPLOYMENT.md file AND comments in config/environments/production.rb.

---

## Security Hardening

### Content Security Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — enable strict CSP | Same-origin scripts, no inline JS, no eval. | ✓ |
| No — leave commented out | CSP adds complexity. Defer. | |
| Enable but permissive | Report-only mode or loose rules first. | |

**User's choice:** Yes — enable strict CSP.

---

### Public error pages

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — style to match app | Update all public/*.html with Apple aesthetic. | ✓ |
| No — keep Rails defaults | Generic is fine. | |
| 404 only | Style just 404, leave 500 as default. | |

**User's choice:** Yes — style all error pages to match.

---

### Additional HTTP security headers

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — add standard secure headers | HSTS (production only), X-Frame-Options, X-Content-Type-Options. | ✓ |
| CSP only | Just the CSP already decided. | |
| You decide | Claude picks standard header set. | |

**User's choice:** Yes — add standard secure headers.

---

## Deployment with Kamal and Docker

### Deployment goal

| Option | Description | Selected |
|--------|-------------|----------|
| Review and document Kamal/Docker config | Audit config/deploy.yml and Dockerfile, add DEPLOYMENT.md. Not a live deploy. | ✓ |
| Make it deployable end-to-end | Ensure Docker build works, Kamal config complete, verifiable. | |
| Actually deploy to a server | Deploy as part of Phase 3 completion. | |

**User's choice:** Review and document the Kamal/Docker config.

---

### What should documentation cover?

| Option | Description | Selected |
|--------|-------------|----------|
| Walkthrough: credentials, registry, server config, first deploy | Step-by-step DEPLOYMENT.md guide. | ✓ |
| Just inline config/deploy.yml comments | Comments in the existing config file only. | |
| Both | DEPLOYMENT.md walkthrough plus inline config/deploy.yml comments. | |

**User's choice:** Walkthrough in DEPLOYMENT.md.

---

## Claude's Discretion

- Exact CSS values within the black-and-white Apple aesthetic (border widths, font sizes, spacing scale)
- Specific icon choice for edit/delete in the table column
- Title truncation character limit (targeting ~60-80 chars with CSS ellipsis)
- Which Rack middleware approach for HTTP security headers

## Deferred Ideas

None — discussion stayed within phase scope.

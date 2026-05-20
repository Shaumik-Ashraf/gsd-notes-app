# Phase 3 D-SEC-03 baseline HTTP security headers applied to every Rails response.
Rails.application.config.action_dispatch.default_headers.merge!(
  "X-Frame-Options" => "SAMEORIGIN",
  "X-Content-Type-Options" => "nosniff",
  "Referrer-Policy" => "strict-origin-when-cross-origin",
  "X-Permitted-Cross-Domain-Policies" => "none"
)

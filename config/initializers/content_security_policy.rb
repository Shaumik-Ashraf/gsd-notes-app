# Strict same-origin CSP per Phase 3 D-SEC-01. Turbo + Stimulus are served via importmap from :self.
# Do not add unsafe-inline, unsafe-eval, or :https — Turbo/Stimulus work without them.
# Skipped in test: headless Chrome enforces script-src and blocks the importmap inline script.
Rails.application.configure do
  next if Rails.env.test?

  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self
    policy.connect_src :self
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :self
  end
end

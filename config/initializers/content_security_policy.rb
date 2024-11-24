# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https

    if Rails.env.development?
      # Allow @vite/client to hot reload javascript changes in development
      policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }"

      # Allow WebSocket connections for hot module reloading
      policy.connect_src :self, "ws://#{ ViteRuby.config.host_with_port }", "http://#{ ViteRuby.config.host_with_port }"
      # Allow hot reload style changes
      policy.style_src *policy.style_src, :unsafe_inline

      # Allow styles from self, https, and Vite development server
      policy.style_src :self, :https, :unsafe_inline, "http://#{ ViteRuby.config.host_with_port }"
    end


    # You may need to enable this in production as well depending on your setup.
    policy.script_src *policy.script_src, :blob if Rails.env.test?
  end
end

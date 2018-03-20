Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  # config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  #
  # production環境でのprecompile済みのassetsはフロントのnginx(reverseproxyではなくこのコンテナのnginx)で
  # ハンドルしたほうが効率がいいが、現状development環境でもnginx経由なので一旦railsでassetsも配信する
  config.public_file_server.enabled = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Action Cable endpoint configuration
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  config.logger = ActiveSupport::TaggedLogging.new(
      Logger.new(config.paths['log'].first, 'daily')
  )

  # logger を変更した場合は自力でログレベルを反映させる必要がある。
  # 例： config.logger.level = Logger::INFO
  config.logger.level = Logger.const_get config.log_level.upcase

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  config.cache_store = :redis_store, "redis://#{ENV['REDIS_HOST']}:6379/0"

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "app_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  #config.active_record.dump_schema_after_migration = false

  # SMTP
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp


  # 非同期処理側で落ちた場合、Rails起動時に気付けないので、
  # ここでチェックしてしまう
  check_env = -> (env_key) do
    if ENV[env_key].blank?
      raise("error! #{env_key} not set")
    end
  end

  check_env.call("SMTP_HOST")
  check_env.call("SMTP_PORT")
  check_env.call("SMTP_USER_NAME")
  check_env.call("SMTP_PASSWORD")

  # port番号は数字のみ許可
  if ENV["SMTP_PORT"] !~ /\A\d+\z/
    raise("error! SMTP_PORT is invalid. (#{ENV["SMTP_PORT"]})")
  end

  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_HOST'],
    port: ENV['SMTP_PORT'].to_i,
    user_name: ENV['SMTP_USER_NAME'],
    password: ENV['SMTP_PASSWORD']
  }

  # TODO パラーメータかするか、カスタムのメールviewでその時のドメインを動的に設定出来るようにする
  config.action_mailer.default_url_options = { 
    host: 'reminder.neogenia.co.jp'
  }
end

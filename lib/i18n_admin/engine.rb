module I18nAdmin
  class Engine < ::Rails::Engine
    isolate_namespace I18nAdmin

    initializer 'i18n_admin.configure_i18n_backend' do
      # TODO: remove this when we have a better way to check if the translations table exists
      # begin
      #   I18nAdmin::TranslationsSet.select('1').inspect
      #   true
      # rescue StandardError
      #   false
      # end
      translations_installed = true

      unless defined?(::Rake::SprocketsTask)
        table_existence = ActiveRecord::Base.connection.table_exists? 'i18n_admin_translations_sets'
        if translations_installed && table_existence
          I18n.backend = I18n::Backend::Chain.new(
            I18nAdmin::HstoreBackend.new,
            I18n.backend
          )
        end
      end
    end

    initializer 'i18n_admin.add_assets_to_precompilation', group: :all do |app|
      app.config.assets.precompile += %w[
        'i18n_admin/spinner.gif'
      ]
    end
  end
end

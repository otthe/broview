module Broview
  class ThemeLoader
    # THEMES_DIR = File.expand_path('../../themes', __FILE__)
    THEMES_DIR = File.expand_path('../../themes', __dir__)

    def self.load_theme(theme_name)
      theme_path = File.join(THEMES_DIR, theme_name)

      unless Dir.exist?(theme_path)
        raise "Theme '#{theme_name}' does not exist in #{THEMES_DIR}"
      end

      {
        path: theme_path,
        index_template: File.join(theme_path, 'index.html.erb'),
        css_file: File.join(theme_path, 'styles.css'),
        js_file: File.join(theme_path, 'script.js')
      }
    end
  end
end
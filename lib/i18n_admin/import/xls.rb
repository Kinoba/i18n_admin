module I18nAdmin
  module Import
    class XLS < Import::Base
      # Used to split cells with large content
      PAGINATION_PATTERN = /\(\d+ \/ (\d+)\)$/

      register :xls, self

      attr_reader :file_url, :spreadsheet, :sheet, :tempfile

      def initialize(locale, file_url)
        @file_url = file_url
        @locale = locale
        download_import_file_to_tempfile
        @spreadsheet = Spreadsheet.open(tempfile.path)
        @sheet = spreadsheet.worksheet(0)
      end

      def run
        I18n.with_locale(locale) do
          index = 0

          while (index += 1) < sheet.row_count
            key, value, index = extract_translation_at(index)
            update_translation(key, value)
          end

          save_updated_models
        end
      ensure
        tempfile.close

        errors.empty?
      end

      private

      def extract_translation_at(index)
        key, _, value = sheet.row(index)

        if (pagination = key.match(PAGINATION_PATTERN))
          pages = pagination[1].to_i
          key = key.gsub(PAGINATION_PATTERN, '').strip

          (pages - 1).times do |page|
            index += 1
            value += sheet.row(index).pop.to_s
          end
        end

        [key, value, index]
      end

      def download_import_file_to_tempfile
        resp = HTTParty.get(file_url)

        @tempfile = Tempfile.new
        @tempfile.binmode
        @tempfile.write(resp.body)
        @tempfile.rewind
      end
    end
  end
end

module I18nAdmin
  module Import
    class Job
      include SuckerPunch::Job

      def perform(locale, import_file_id, job_id)
        ActiveRecord::Base.connection_pool.with_connection do
          import_file = ImportFile.find(import_file_id)
          import = Import::XLS.new(locale, import_file.file.url)
          job = I18nAdmin::ImportJob.find(job_id)

          state = import.run ? 'success' : 'error'
          job.update(state: state)
        end
      end
    end
  end
end

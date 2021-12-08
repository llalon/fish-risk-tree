using WebApp.Models;
using WebApp.Services;

namespace WebApp.ViewModels
{
    public class ResultsViewModel
    {
        private IJobRepositoryService _jobRepositoryService;

        public Guid Id { get; set; }
        public string SubmissionIdEntry { get; set; }
        public string JobStatus { get; set; }
        public string JobStartTime { get; set; }
        public string LastCheckTime { get; set; }
        public bool IsCompleted { get; set; }

        private Job _job;

        public ResultsViewModel(IJobRepositoryService jobRepositoryService)
        {
            _jobRepositoryService = jobRepositoryService;

            UpdateJob();
        }

        public void GetResults()
        {
            UpdateJob();

            try
            {
                this.Id = Guid.Parse(SubmissionIdEntry);
            }
            catch (Exception ex)
            {
                this.Id = Guid.Empty;
            }
        }

        public void DownloadResults()
        {
            var bytes = _jobRepositoryService.GetResultsZipBytes(Id);

            if (bytes != null)
            {
                var sz = Convert.ToBase64String(bytes);
                //_downloadFileService.DownloadFile("results.zip", sz, "application/x-zip");

            }
        }

        public void UpdateJob()
        {
            _job = _jobRepositoryService.GetJob(this.Id);
            if (_job == null)
            {
                JobStatus = "Job not found!";
                JobStartTime = "NA";
            }
            else
            {
                JobStatus = _job.Status.ToString();
                JobStartTime = _job.SubmittedOn.ToString();

                if (_job.Status == Models.JobStatus.Completed)
                {
                    IsCompleted = true;
                }
            }
            LastCheckTime = DateTime.Now.ToString();
        }
    }
}

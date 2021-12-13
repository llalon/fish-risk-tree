using WebApp.Models;
using WebApp.Services;

namespace WebApp.ViewModels
{
    public class SubmissionViewModel
    {
        private IJobSubmissionService _jobSubmissionService;

        public string? SubmissionId { get; set; }

        public bool IsSubmitted
        {
            get
            {
                if (String.IsNullOrEmpty(SubmissionId))
                    return false;
                return true;
            }
        }

        public bool IsLoading { get; set; }

        public string Taxon { get; set; } 
        public string Marker { get; set; }
        public string Seed { get; set; }
        public int NumBootstraps { get; set; }
        public bool BootstrapEnabled { get; set; }

        public SubmissionViewModel(IJobSubmissionService jobSubmissionService)
        {
            _jobSubmissionService = jobSubmissionService;

            IsLoading = false;

            NewJob();
        }

        public void SubmitJob()
        {
            IsLoading = true;

            if (!BootstrapEnabled)
            {
                NumBootstraps = 0;
            }


            Job job = new Job()
            {
                Taxon = Taxon,
                Marker = Marker,
                Seed = Seed,
                NumBootstraps = NumBootstraps,
            };

            var id = _jobSubmissionService.Submit(job);

            SubmissionId = id.ToString();

            IsLoading = false;
            
        }

        public void NewJob()
        {
            SubmissionId = null;
            Taxon = "Acipenseridae";
            Marker  = "COI-5P";
            Seed  = "1234";
            NumBootstraps  = 0;
            BootstrapEnabled  = false;
        }

    }
}

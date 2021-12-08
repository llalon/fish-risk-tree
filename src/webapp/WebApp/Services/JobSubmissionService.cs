using WebApp.Models;
using System;
using System.Text.Json;
using System.Diagnostics;

namespace WebApp.Services
{
    public class JobSubmissionService : IJobSubmissionService
    {
        private readonly IJobRepositoryService _jobRepositoryService;

        public JobSubmissionService(IJobRepositoryService jobRepositoryService)
        {
            _jobRepositoryService = jobRepositoryService;
        }

        public Guid Submit(Job job)
        {
            job.Id = Guid.NewGuid();
            job.SubmittedOn = DateTime.Now;

            JobConfig config = new JobConfig()
            {
                Taxon = job.Taxon,
                Marker = job.Marker,
                NumBootstraps = job.NumBootstraps,
                Seed = job.Seed,
                DataDirectory = $"{Constants.OUTPUT_DIR}/{job.Id}"
            };

            // Run workflow here...
            RunJob(config);

            job.Status = JobStatus.Running;
            _jobRepositoryService.AddJob(job);

            return job.Id;
        }

        private void RunJob(JobConfig config)
        {
            // Save config json to file
            Directory.CreateDirectory(config.DataDirectory);

            string jsonString = JsonSerializer.Serialize(config);
            string fileName = "config.json";
            string filePath = $@"{config.DataDirectory}/{fileName}";
            File.WriteAllText(filePath, jsonString);

            // Run pipeline

            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = $"run_pipeline.sh";
            psi.CreateNoWindow = true;
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            psi.UseShellExecute = false;
            psi.RedirectStandardError = false;
            psi.RedirectStandardOutput = false;
            psi.Arguments = filePath;

            // Don't overwrite analsysis in demo mode
            if (Constants.DEMO_MODE)
                psi.FileName = $"cat";
            
            Process process = Process.Start(psi);
        }
    }
}

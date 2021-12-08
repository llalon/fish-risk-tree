using System.IO.Compression;
using WebApp.Models;

namespace WebApp.Services
{
    public class JobRepositoryService : IJobRepositoryService
    {
        private List<Job> _jobs = new List<Job>();

        public void AddJob(Job job)
        {
            _jobs.Add(job);
        }

        public Job GetJob(Guid id)
        {
            if (id == Guid.Empty)
                return null;

            var ret = _jobs.FirstOrDefault(x => x.Id == id);

            if (ret == null)
                return ret;

            // Check status of job.
            var baseDir = $"{Constants.OUTPUT_DIR}/{id.ToString()}";

            ret.Status = JobStatus.Pending;

            try
            {
                if (Directory.Exists($"{baseDir}/raw"))
                {
                    ret.Status = JobStatus.Running;
                }
            }
            catch { }

            try
            {
                var res = new DirectoryInfo($"{baseDir}/processed").EnumerateFiles("*").Any();
                if (res)
                {
                    ret.Status = JobStatus.Completed;
                }
            }
            catch { }


            return ret;
        }

        public Byte[] GetResultsZipBytes(Guid id)
        {
            var job = GetJob(id);

            if (job == null)
                return null;

            var resultsDir = $"{Constants.OUTPUT_DIR}/{job.Id}/processed";
            var zipFilePath = $"{Constants.OUTPUT_DIR}/{job.Id}/results.zip";

            // Don't zip if the folder is empty!!
            if (new DirectoryInfo(resultsDir).EnumerateFiles("*").Any())
                return null;

            // Save zip to job folder
            ZipFile.CreateFromDirectory(resultsDir, zipFilePath);

            // Return as byte array
            return File.ReadAllBytes(zipFilePath);
        }
    }
}

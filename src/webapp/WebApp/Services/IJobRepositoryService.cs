using WebApp.Models;

namespace WebApp.Services
{
    public interface IJobRepositoryService
    {
        Job GetJob(Guid id);
        void AddJob(Job job);

        byte[] GetResultsZipBytes(Guid id);
    }
}

using WebApp.Models;

namespace WebApp.Services
{
    public interface IJobSubmissionService
    {
        Guid Submit(Job job);
    }
}

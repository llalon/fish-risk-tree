namespace WebApp.Models
{
    public class Job
    {
        public Guid Id { get; set; }
        public DateTime SubmittedOn { get; set; }
        public string Taxon { get; set; }
        public string Marker { get; set; }
        public int NumBootstraps { get; set; }
        public string Seed { get; set; }
        public JobStatus Status { get; set; }
    }

    public enum JobStatus
    {
        Pending,
        Running,
        Completed,
        Errored
    }
}

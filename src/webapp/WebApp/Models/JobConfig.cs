namespace WebApp.Models
{
    public class JobConfig
    {
        public string Taxon { get; set; }
        public string Marker { get; set; }
        public int NumBootstraps { get; set; }
        public string DataDirectory { get; set; }
        public string MuscleBinaryPath { get; set; } = "muscle";
        public string RaxmlBinaryPath { get; set; } = "raxmlHPC";
        public string FishIucnFinderBinaryPath { get; set; } = "fish_iucn_finder.pl";
        public string Seed { get; set; }
        public int Threads { get; set; } = 0;

    }
}

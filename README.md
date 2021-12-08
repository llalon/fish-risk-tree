# Fish Risk Tree

A bioinformatics pipeline for generating phylogenetic trees annotated with IUCN risk status for fish taxon.

#### Pipeline Parameters

Provide the runtime parameters to the pipeline as JSON:

```
{
    "Taxon": <See bold systems for available taxon and names>
    "Marker": <See bold systems for available markers>
    "NumBootstraps": <The number of bootstraps to use with raxml. 0 to disable bootstraps>
    "DataDirectory": <The path where all data will be stored in>
    "MuscleBinaryPath": <path to the muscle binary>
    "RaxmlBinaryPath": <path to the RAxML binary>
    "FishIucnFinderBinaryPath": <path to fish_iucn_finder.pl>
    "Seed": <Randomization seed>
    "Threads": <The number of cpu threads to run with. 0 to autodetect>
}
```

#### Running the Pipeline via CLI

To run the pipeline:

```
docker run llalon/fish-risk-tree:latest run_pipeline.sh config.json
```

#### Running the Pipeline via GUI

A web GUI is also provided and can be accessed using docker:

```
docker run -d -p 8080:80 -v out:/out llalon/fish-risk-tree:gui-latest
```

#### Limitations

- Does not support sub species (returns NA)
- Limited to data from Bold Systems

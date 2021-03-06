# Fish Risk Tree

A bioinformatics pipeline for generating phylogenetic trees annotated with IUCN risk status for fish taxon. Tree's with annotations are created using the NHX format.

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

#### Running the Pipeline via CLI (RECOMMENDED)

To run the pipeline, generate a valid configuration file and run using the following:

```
docker run -it --rm -v <PATH TO SAVE TO LOCALLY>:<PATH TO DATA DIRECTORY IN CONFIG> llalon/fish-risk-tree:latest

run_pipeline.sh config.json
```

#### Running the Pipeline via GUI

A web GUI is also provided and can be accessed using docker:

```
docker run -d -p 8080:80 -v out:/out llalon/fish-risk-tree:gui-latest
```

![](img/screenshot.png)

#### Limitations

- Does not support sub species (returns NA)
- Sequence data limited to Bold Systems
- IUCN data limited to FishBase

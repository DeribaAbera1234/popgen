Population Genetics Tool
---

- Population Structure Analysis
- Selection Scan (iHS, EHH)
- LDhat (Model recombination map)
- Fst
- LD
- MAF
- Fws

Design
----
- Spatial Analysis:
   * Data collected from same region
   * There is a continuum in distance between towns
   * spatial analysis on extremes

- Temporal: 
   * Majority of data collected in one year, only a handful (about 4) collected in a different year
   * Temporal analysis not feasible

- Transmission Intensity: 
   * High transmission in the region occurs between March and November
   * Incidence peaks between July and October
   * Analaysis on high Vs low transmission

- Altitude: \*\*\*
   * Low
   * Moderate
   * High
   * Analysis between altitude categories

- Age & Gender: Influence parasitemia via immunity
   * Analize by age group
   * Analize by gender
-----------------------
\*\*\* main analysis category


Data Stratification
----
1. Biallelic core SNPs that pass all filters (VSQLOD>0)
2. Biallelic CDS
3. Biallelic core SNPs that pass all filters and are segregating within the populations (VSQLOD>0 && AC>0)
4. Biallelic core SNPs with high quality (VSQLOD>6 && AC>0)
5. Biallelic core SNPs with high quality and are segregating within the populations (VSQLOD>6 && AC>0)


Data Preparation
----
- Merge chromosome 1-14 into a single file (Pf3D7\_all\_v3.vcf.gz)
- Extract working samples
- Phase datasets (BEAGLE v5.0)

Analaysis Measures/Statistics
----
- Compute recombination map (LDhat)
- Minor Allele Frequency (MAF)
- Linkage disequilibrium pattern (LD)
- Complexity of infection (Fws)
- Population Structure:
   * Principal component analysis (PCA)
   * Fst
- Selection Scan:
   * iHS
   * EHH

- Tajima's D (on segregating sites)


Pipeline
---
Merge single chromosomes into one file
```
./mergePlaf.sh <file> <output>
``` 

Update chromosome and snp IDs so that plink does not spill out errors
```
./updatePlafIDs.sh <merged-vcf>
```

Extract data for analysis as outlined above
```
./extract_data.sh <updated-vcf>
```

Phase extracted data with BEAGLE v5.0
```
./beaglePhase.sh <extracted-vcf> <output-prefix>
```

Convert phased haplotypes in VCF to rehh format (.hap+.map)
```
./phased_vcf2rehh.sh -h 
```

Get help for using the script by typing '-h' on the commandline

Run scan for selection
```
./runScan.sh
```

Just hit 'enter' and the script will guide you through



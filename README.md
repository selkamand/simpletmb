
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simpletmb

<!-- badges: start -->

<!-- badges: end -->

simpleTMB makes it easy to convert **Total Mutation Count** to **Tumour
Mutation Burden** (TMB), measured in mutations per megabase.

It also classifies TMB as high or low using thresholds sensible for
paediatric cancer data.

## When to use simpleTMB

Generally, we recommend researchers use TMB calculators built into their
variant calling pipelines as these can produce coverage-informed
estimations of callable regions (see [Understanding
TMB](#understanding-tmb)).

simpleTMB is a flexible but very basic utility only intended for use
calculating TMB yourself is required because:

1.  You’re analysing diverse sequencing platforms that your pipeline is
    not appropriately accounting for.
2.  You’re analyzing public data from a large variety of different
    sources and only have mutation data (no BAMs) + sequencing assay
    information.
3.  You are analysing a single paediatric cancer patient and are unsure
    what a high-TMB sample should look like.

## Installation

You can install the development version of simpletmb from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("selkamand/simpletmb")
```

## Quick start

``` r
library(simpletmb)

tmb <- mutations_to_tmb(
  total_mutations = 1000, 
  callable_bases = 2.9*10^9 # Size of ungapped hg38 genome
  )
```

## Understanding TMB

At a glance, TMB seems easy to calculate.

$$
TMB = \frac{\text{totalMutations}}{\text{callableRegion}} \times 10^6
$$

**Where**

- **totalMutations** is the total number of mutations identified

- **callableRegion** is the total number of bases where a mutation could
  theoretically have been identified if it was present (measured in
  base-pairs)

However, calculating `callableRegion` is non-trivial. It depends on your
sequencing approach, bioinformatics pipeline and sample quality. Many
approaches will look into the tumour BAM and check for regions with
sufficient coverage to call ([DRAGEN Somatic Callable Regions
Report](https://jp.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/Informatics/Dragen/SomaticCallableReport_fDG.htm)).
They can also exclude hard-to-call regions in which variant-callers are
unlikely to identify mutations.

Even when leveraging BAM-informed approaches, TMBs from panels, exomes
and whole-genomes will still not be comparable. There are two reasons:

1.  The ability to identify subclonal variants depends on tumour purity
    and sequencing depth. Panels have much higher depth of coverage
    relative to exome or whole-genome samples, meaning
    **totalMutations** per-base will be inflated in higher-depth
    platforms. This can be addressed by excluding subclonal variants
    from the count of `totalMutations`, although that comes at the cost
    detecting samples with mismatch repair deficient subclones, so it
    may be worth tolerating the bias or using more complex adjustment
    for depth.

2.  The callable regions of different assays (panels, exomes and
    genomes) can have different mutation rates and therefore lead to
    difficulty estimating comparable TMBs.

The biggest challenge, however, is that there is now a large number of
cancer samples with mutation data available in tabular / variant-call
formats rather than BAMS. These samples often come from different
centers, and sometimes even processed using different bioinformatics
pipelines. This makes BAM- and pipeline-specific approaches harder to
employ.

The saving grace is that biologically important differences in TMB are
quite large. Samples with mismatch repair deficiencies have orders of
magnitude higher TMBs than those that don’t. Variance in TMB driven by
biologically strong signals will likely overwhelm technical biases so
long as normalisation and categorisation of TMBs as high vs low is
reasonably sensible.

simpleTMB is a quick, customisable tool for transforming total mutation
counts to TMBs, but more importantly classifying TMB using thresholds
sensible for paediatric cancer.

## Typical Callable Regions

See `typical_callable_bases()` to retrieve callable bases in **bp**
units as required for `mutations_to_tmb()`

| Strategy | Callable Bases | Definition |
|----|----|----|
| TruSight Oncology 500 panel | 1.94 Mbp | [**Product Specifications**](https://sapac.illumina.com/products/by-type/clinical-research-products/trusight-oncology-500.html) |
| Whole-Genome-Sequencing called against hg38 | 2.9 Gbp | **GRCh38 reference excluding gaps** |
| Twist Bioscience for Illumina Exome 2.5 Exome 2.5 Panel | 37.5 Mbp | [Product Specifications](https://sapac.illumina.com/products/by-type/sequencing-kits/library-prep-kits/dna-prep-exome-enrichment.html) |

#' Normalise mutations to TMB
#'
#' Transform the total number of mutations in a sample to \strong{Total Mutation Burden} (TMB; measured as mutations per megabase)
#' based on the number of theoretically 'callable bases' where a mutation could be detected based on your sequencing strategy.
#' E.g if you sequenced on a panel, callable bases would be the total size covered by the panel.
#' If you did whole-genome, its the number of bases in the whole genome you could theoretically identify a mutation at.
#' It is best-practice to identify the exact number of \strong{callable_bases}
#' based on your sequencing strategy, bioinformatics pipeline and breadth & depth of coverage (extracted from sample BAMs),
#' however we do provide sensible defaults for common sequencing strategies. See [typical_callable_bases()] for details.
#'
#'
#'
#' @param total_mutations number of mutations (count).
#' If comparing samples where depth of sequencing across callable regions could vary
#' (e.g. comparing panels, exomes, or whole-genome data against each other) we highly recommend using only the number of \strong{clonal} mutations.
#' This is because detection of subclonal mutation counts is extremely depth-dependent.
#' Do note, however, that considering only clonal mutations would make it harder to detect samples with MMRd subclones, so its may be worth tolerating the bias.
#' @param callable_bases  number of callable bases. See [typical_callable_bases()] for example values.
#' @param mutations_per specify the unit. By default will return mutations per megabase.
#'
#' @return The TMB (mutations per megabase) normalised based on \code{callable_bases}
#' @export
#'
#' @examples
#'
#' tmb <- mutations_to_tmb(
#'   total_mutations = 500,
#'  callable_bases = 2.9*10^9 # typical number of callable bases for WGS (hg38)
#'  )
#'
#' callable_bases <- typical_callable_bases()
#' tmb <- mutations_to_tmb(
#'   total_mutations = 500,
#'  callable_bases = callable_bases$`TruSight Oncology 500 panel`
#'  )
#'
mutations_to_tmb <- function(total_mutations, callable_bases, mutations_per = c("megabase", "kilobase", "gigabase")){
  assertions::assert_numeric(callable_bases)
  assertions::assert_numeric(total_mutations)
  assertions::assert(
    length(callable_bases) == length(total_mutations) | length(callable_bases)  == 1,
    msg = "{.arg callable_bases} must be either a single number or a vector the same length as {.arg total_mutations} ({length(total_mutations)}). {.arg callable_bases} supplied had {length(callable_bases)} elements")

  mutations_per <- rlang::arg_match(mutations_per)
  lookup <- c("gigabase" = 9, "megabase" = 6, "kilobase" = 3)
  exponent <- lookup[match(mutations_per, names(lookup))]

  if(is.na(exponent)) stop('Support for returning mutations per [', mutations_per, '] has not been implemented')

  unname(total_mutations/callable_bases * 10^exponent)
}


#' Typical number of callable bases for common assays.
#'
#' It is best-practice to identify the exact number of \strong{callable_bases}
#' based on your sequencing strategy, bioinformatics pipeline and breadth & depth of coverage (extracted from sample BAMs).
#' This function describes some sensible defaults for common sequencing strategies that should only be used if more comprehensive methods of estimation are not possible.
#'
#' @return a list where names are sequencing strategy and values are the number of callable bases.
#' @export
#'
#' @examples
#' typical_callable_bases()
typical_callable_bases <- function(){
  c(
    "Whole Genome Sequencing (hg38)" = 2.9*10^9,
    "Twist Bioscience for Illumina Exome 2.5 Exome 2.5 Panel"=  37.5*10^6 ,
    "TruSight Oncology 500 panel" = 1.94*10^6
  ) |> as.list()
}

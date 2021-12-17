library(dplyr)
#library(rwar)
library(drake)
library(MATSS)
library(BBSsize)


run_hpg = T
#max_caps <- c(75, 150, 225, 300, 375, 450, 528)
# for(i in 1:length(max_caps)) {
source(here::here("analyses", "fxns", "hasty_fxns.R"))
#i = 1
datasets <- MATSS::build_bbs_datasets_plan()


working_datasets <- read.csv(here::here("analyses", "supporting_data","ninetypercent_coverage_1988_2018.csv"))


datasets <- datasets[ which(datasets$target %in% working_datasets$matssname), ]


methods <- drake_plan(
  ssims = target(whole_thing(dataset),
                 transform = map(
                   dataset = !!rlang::syms(datasets$target)
                 )),
  all_sims = target(dplyr::bind_rows(ssims),
                    transform = combine(ssims)),
  glms = target(hasty_models(ssims),
                transform = map(ssims)),
  aics = target(hasty_model_aic(glms),
                transform = map(glms)),
  preds = target(hasty_model_predicted_change(glms),
                 transform = map(glms)),
  all_aics = target(dplyr::bind_rows(aics),
                    transform = combine(aics)),
  all_preds = target(dplyr::bind_rows(preds),
                     transform = combine(preds)),
  glms_energy = target(hasty_energy_models(ssims),
                       transform = map(ssims)),
  aics_energy = target(hasty_model_aic(glms_energy),
                       transform = map(glms_energy)),
  preds_energy = target(hasty_model_predicted_change(glms_energy),
                        transform = map(glms_energy)),
  all_aics_energy = target(dplyr::bind_rows(aics_energy),
                           transform = combine(aics_energy)),
  all_preds_energy = target(dplyr::bind_rows(preds_energy),
                            transform = combine(preds_energy)),
  isd_compares = target(fiveyr_compare(dataset),
                        transform = map(
                          dataset = !!rlang::syms(datasets$target)
                        )),
  all_isd_compares = target(dplyr::bind_rows(isd_compares),
                            transform = combine(isd_compares))
)

all = bind_rows(datasets, methods)


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analyses", "caches", "all_hasty_toy.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")

## Run the pipeline
nodename <- Sys.info()["nodename"]
# if(grepl("ufhpc", nodename)) {
#    print("I know I am on the HiPerGator!")
#
#   if(run_hpg) {
library(clustermq)
options(clustermq.scheduler = "multicore"#, clustermq.template = "slurm_clustermq.tmpl")
)
## Run the pipeline parallelized for HiPerGator
system.time(make(all,
                 force = TRUE,
                 cache = cache,
                 verbose = 1,
                 parallelism = "clustermq",
                 jobs = 4,
                 caching = "main",
                 memory_strategy = "autoclean",
                 lock_envir = F,
                 garbage_collection = T))# Important for DBI caches!
#   } else {


#Run the pipeline on multiple local cores
#system.time(make(all, cache = cache,  verbose = 1, memory_strategy = "autoclean", lock_envir = F, jobs = 3, parallelism = "clustermq"))


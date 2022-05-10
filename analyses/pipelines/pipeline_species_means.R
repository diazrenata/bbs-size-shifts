# f/u from defense...what if one does not simulate from a normal distribution, but just uses species' mean body sizes (i.e. sd of 0)? Set up initially to run locally with just a few datasets...

library(dplyr)
library(drake)
library(MATSS)
library(dissBBSsize)


run_hpg = T
max_caps <- c(75, 150, 225, 300, 375, 450, 528)

for(i in 1:length(max_caps)) {
  source(here::here("analyses", "fxns", "is_fxns.R"))
  #i = 1
  datasets <- MATSS::build_bbs_datasets_plan()


  working_datasets <- read.csv(here::here("analyses", "supporting_data","ninetypercent_coverage_1988_2018.csv"))


  #datasets <- datasets[ which(datasets$target %in% working_datasets$matssname[1:2]), ]
  datasets <- datasets[ which(datasets$target %in% working_datasets$matssname)[1:max_caps[i]], ]


  methods <- drake_plan(
    annual_svs = target(get_annual_state_variables(dataset, use_sp_means),
                        transform = map(
                          dataset = !!rlang::syms(datasets$target),
                          use_sp_means = TRUE
                        )),
    all_sims = target(dplyr::bind_rows(annual_svs),
                      transform = combine(annual_svs)),
    glms_b = target(fit_trend_models_biomass(annual_svs),
                    transform = map(annual_svs)),
    aics_b = target(eval_trend_models(glms_b),
                    transform = map(glms_b)),
    preds_b = target(all_models_predicted_change(glms_b),
                     transform = map(glms_b)),
    all_aics_b = target(dplyr::bind_rows(aics_b),
                        transform = combine(aics_b)),
    all_preds_b = target(dplyr::bind_rows(preds_b),
                         transform = combine(preds_b)),
    glms_e = target(fit_trend_models_energy(annual_svs),
                    transform = map(annual_svs)),
    aics_e = target(eval_trend_models(glms_e),
                    transform = map(glms_e)),
    preds_e = target(all_models_predicted_change(glms_e),
                     transform = map(glms_e)),
    all_aics_e = target(dplyr::bind_rows(aics_e),
                        transform = combine(aics_e)),
    all_preds_e = target(dplyr::bind_rows(preds_e),
                         transform = combine(preds_e))#,
    # cs_compares = target(compare_community_structure(dataset, use_sp_means),
    #                      transform = map(
    #                        dataset = !!rlang::syms(datasets$target),
    #                        use_sp_means = T
    #                      )),
    # all_cs_compares = target(dplyr::bind_rows(cs_compares),
    #                          transform = combine(cs_compares))
  )

  all = bind_rows(datasets, methods)


  ## Set up the cache and config
  db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analyses", "caches", "all_sp_means.sqlite"))
  cache <- storr::storr_dbi("datatable", "keystable", db)
  cache$del(key = "lock", namespace = "session")

  ## Run the pipeline
  nodename <- Sys.info()["nodename"]
  # if(grepl("ufhpc", nodename)) {
  #    print("I know I am on the HiPerGator!")
  #
  if(run_hpg) {
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
  } else {


    #Run the pipeline on multiple local cores
    system.time(make(all,
                     force = TRUE,
                     cache = cache,
                     verbose = 1,
                     caching = "main",
                     memory_strategy = "autoclean",
                     lock_envir = F,
                     garbage_collection = T))

  }


  DBI::dbDisconnect(db)
  rm(cache)

}

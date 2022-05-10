
<div class="kable-table">

| currency | model\_formula       |   n |
| :------- | :------------------- | --: |
| biomass  | 1                    | 239 |
| biomass  | timeperiod           | 351 |
| biomass  | timeperiod \* source | 149 |
| energy   | 1                    | 230 |
| energy   | timeperiod           | 456 |
| energy   | timeperiod \* source |  53 |

</div>

## New figs here\!\!\!

# Figure 3. Visualizing decoupling

![](for_jk_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

<div class="kable-table">

| Same\_syndrome                     |   n | total | prop |
| :--------------------------------- | --: | ----: | ---: |
| Different syndromes                | 176 |   739 | 0.24 |
| Same syndromes for both currencies | 563 |   739 | 0.76 |

</div>

Observations…

  - For about 1/4 of routes, the outcome for energy use is different
    from the one for biomass.
  - Usually the slope for energy use is less positive than for biomass.
    This makes sense to me given the \<1 scaling exponent.

#### Sample route with different syndromes

<div class="kable-table">

| matssname        | ratio\_sim\_Biomass | ratio\_sim\_Energy\_use | ratio\_real\_Biomass | ratio\_real\_Energy\_use | modelcomplexity\_Biomass | modelcomplexity\_Energy\_use | winning\_formula\_Biomass | winning\_formula\_Energy\_use | Syndrome\_Biomass | Syndrome\_Energy\_use | Same\_syndrome      |
| :--------------- | ------------------: | ----------------------: | -------------------: | -----------------------: | -----------------------: | ---------------------------: | :------------------------ | :---------------------------- | :---------------- | :-------------------- | :------------------ |
| bbs\_rtrg\_6\_39 |           0.7044827 |               0.6959935 |             1.227789 |                0.8941509 |                        4 |                            2 | timeperiod \* source      | timeperiod                    | Decoupled trends  | Coupled trend         | Different syndromes |

</div>

![](for_jk_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

# Results using 0 standard deviation

<div class="kable-table">

| currency | model\_formula       |   n | total |
| :------- | :------------------- | --: | ----: |
| biomass  | 1                    | 155 |   528 |
| biomass  | timeperiod           | 262 |   528 |
| biomass  | timeperiod \* source | 111 |   528 |
| energy   | 1                    | 160 |   528 |
| energy   | timeperiod           | 329 |   528 |
| energy   | timeperiod \* source |  39 |   528 |

</div>

    ## [1] 0.9943182

![](for_jk_files/figure-gfm/process%20energy%20results%20spmean-1.png)<!-- -->![](for_jk_files/figure-gfm/process%20energy%20results%20spmean-2.png)<!-- -->

# resolve_subsets() - multiple domains and rows

    Code
      elements[grepl(pattern = "with\\.domain$", x = names(elements))]
    Output
                      ADAE.rows.component.with.domain 
      ".mighty_subset(ADAE, \"STUDYID == 'STUDY1'\")" 
                      ADAE.rows.component.with.domain 
      ".mighty_subset(ADAE, \"STUDYID == 'STUDY2'\")" 
                      ADSL.rows.component.with.domain 
                 ".mighty_subset(ADSL, \"AGE > 50\")" 


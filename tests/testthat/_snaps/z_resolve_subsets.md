# resolve_subsets() - multiple domains and rows

    Code
      elements[grepl(pattern = "with\\.domain$", x = names(elements))]
    Output
                ADAE.rows.component.with.domain 
      "ADAE[with(ADAE, STUDYID == 'STUDY1'), ]" 
                ADAE.rows.component.with.domain 
      "ADAE[with(ADAE, STUDYID == 'STUDY2'), ]" 
                ADSL.rows.component.with.domain 
                 "ADSL[with(ADSL, AGE > 50), ]" 


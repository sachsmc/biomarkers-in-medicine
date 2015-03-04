shinyUI(fixedPage(
  
  
  fixedRow(
    
        column(6, 
           plotOutput("density_plot", height = "300px")
           ),
        column(6,
           plotOutput("roc_plot", height = "300px")
           )
    
    
    ), 
  fixedRow(
    column(6, 
           wellPanel(
             selectInput("quality", "Biomarker Quality", 
                         list("Excellent" = "2", 
                              "Very Good" = "1",
                              "Good" = ".5",
                              "Average" = ".25",
                              "Poor" = ".1",
                              "Useless" = "0"
                         )),
             sliderInput("thresh", "Threshold", min = -3, max = 6, value = 0, step = .1, animate = TRUE)
           )
           ),
    column(6,
           htmlOutput("mary")
    )    
    )
  
  ))
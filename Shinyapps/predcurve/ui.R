shinyUI(fixedPage(


  fixedRow(

        column(6,
           plotOutput("density_plot", height = "300px")
           ),
        column(6,
           plotOutput("pred_plot", height = "300px")
           )


    ),
  fixedRow(
    column(6,
           wellPanel(
             selectInput("quality", "Biomarker Quality",
                         list("Excellent" = "8",
                              "Very Good" = "5",
                              "Good" = "4",
                              "Average" = "2",
                              "Poor" = "1",
                              "Useless" = "0.5"
                         )),
             sliderInput("highlow", "Risk threholds", min = 0, max = 1, value = c(.1, .9), round = -2)
           )
           ),
    column(6,
           htmlOutput("mary")
    )
    )

  ))

shinyServer(function(input, output) {

  library(ggplot2)
  library(ggthemes)
  library(predcurver)

  predme <- function(T, D){

    risk <- predict(glm(D ~ T, family = binomial, data = dataset()), type = "response")
    pred <- predcurve(risk)

    pred

  }



  dataset <- reactive({

    D <- rbinom(250, 1, .25)
    T <- rnorm(250, mean = D * as.numeric(input$quality), sd = 1)
    data.frame(D = D, T = T)


  })

  percs <- reactive({

    pdun <- predme()
    percs <- sapply(input$highlow, function(x){

      max(pdun$percentile[pdun$risk <= x])

    })
    percs

  })

  output$density_plot <- renderPlot({

    ggplot(dataset(), aes(x = T, color = ifelse(D == 1, "diseased", "healthy"))) + geom_density() + theme_igray() + scale_color_colorblind("Status") +
      scale_x_continuous("Biomarker value") + geom_vline(xintercept = quantile(dataset()$T, percs()), lty = 2)


  })

  output$pred_plot <- renderPlot({

    ymax1 <- input$highlow[2]
    ymin1 <- input$highlow[1]
    xmax1 <- percs()[2]

    xmin2 <- percs()[1]
    xmax2 <- percs()[2]
    ymax2 <- input$highlow[2]

    duwh <- data.frame(ymax1, ymin1, xmax1, xmin2, xmax2, ymax2)

    ggplot(predme(), aes(x = percentile, y = risk)) +
      geom_rect(data = duwh, aes(x = NULL, y = NULL, ymin = ymin1, ymax = ymax1, xmin = 0, xmax = xmax1), alpha = .2) +
      geom_rect(data = duwh, aes(x = NULL, y = NULL, xmin = xmin2, xmax = xmax2, ymin = 0, ymax = ymax2),  alpha = .2) +
      geom_line() + theme_igray() +
      geom_abline(intercept = mean(predme()$risk), slope = 0, linetype = 2)



  })

  output$mary <- renderUI({


    h5(list(sprintf("Proportion at High risk: %.2f",  1 - percs()[2]), br(),
            sprintf("Proportion at Low risk: %.2f", percs()[1]), br(),
            sprintf("Proportion unclassified: %.2f", abs(diff(percs()))), br(),
            sprintf("Proportion with risk higher than average: %.2f", mean(predme()$risk > mean(predme()$risk)))))

  })

})

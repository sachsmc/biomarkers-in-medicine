shinyServer(function(input, output) {

  library(ggplot2)
  library(ggthemes)

  rocme <- function(T, D){

    c <- sort(T)
    TPF <- sapply(c, function(x) mean(T[D == 1] > x))
    FPF <- sapply(c, function(x) mean(T[D == 0] > x))

    data.frame(cbind(c, TPF, FPF))

  }



  dataset <- reactive({

    D <- rbinom(250, 1, .5)
    T <- rnorm(250, mean = D * as.numeric(input$quality), sd = 1)
    data.frame(D = D, T = T)


  })

  output$density_plot <- renderPlot({


    ggplot(dataset(), aes(x = T, color = ifelse(D == 1, "diseased", "healthy"))) + geom_density() + theme_igray() + scale_color_colorblind("Status") +
      scale_x_continuous("Biomarker value") + geom_vline(xintercept = input$thresh, lty = 2)


  })

  output$roc_plot <- renderPlot({

    tour <- rocme(dataset()$T, dataset()$D)
    tpoint2 <- tour[tour$c >= input$thresh,, drop = FALSE][1,]

    ggplot(tour, aes(x = FPF, y = TPF)) + geom_path() + geom_abline(intercept = 0, slope = 1, lty = 2) + theme_igray() +
      scale_x_continuous("False positive fraction at c") + scale_y_continuous("True positive fraction at c") +
      geom_point(data = tpoint2, aes(x = FPF, y = TPF), color = "green") +
      geom_text(data = tpoint2, aes(x = FPF, y = TPF, label = round(c, 2)), hjust = 0, vjust = 1)

  })

  output$mary <- renderUI({

    tour <- rocme(dataset()$T, dataset()$D)
    tpoint2 <- tour[tour$c >= input$thresh,, drop = FALSE][1,]

    D1 <- subset(dataset(), D == 1)
    D0 <- subset(dataset(), D == 0)
    auc <- mean(outer(D1$T, D0$T, FUN = ">"))

    h5(list(sprintf("Threshold: %.2f", tpoint2[1]), br(),
            sprintf("True positive fraction: %.2f", tpoint2[2]), br(),
            sprintf("False positive fraction: %.2f", tpoint2[3]), br(),
            sprintf("AUC: %.2f", auc)))

  })

})

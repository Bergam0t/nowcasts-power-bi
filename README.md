# nowcasts-power-bi
Nowcast projection model 

Modifying the nowcasting approach of NHS BNSSG ICB to work in Power BI. 

**Nowcasting - open source paper:** https://www.magonlinelibrary.com/doi/full/10.12968/bjhc.2020.0179

> As a near-term forecasting approach, the ‘nowcasts’ predict COVID-19 bed occupancy rates for the following 7 days using trends in recent data. One of the advantages of this method is that each prediction does not require data from any factors other than that being measured. The forecasts are produced using the time series model with the lowest cross-validation error. This may either be a fitted exponential smoothing state space model or a fitted autoregressive integrated moving average (ARIMA) model.
>
> **Nowcasting for improved management of COVID-19 acute bed capacity**
>
>**Richard M Wood**
>
>**British Journal of Healthcare Management 2021 27:2, 1-3**

![FIG_sample](https://github.com/Bergam0t/nowcasts-power-bi/assets/29951987/7a4fc619-9439-4f1c-a8b0-6b76b3a253c2)



# Limitations of the nowcasting approach

> It should be noted that this approach is not without limitations, the clearest of which being the reliance on the past for predicting the future. There are, of course, extraneous factors that underpin the temporal profile of hospital admissions. Community testing data is a useful lead indicator, but has not always been readily available (Griffin, 2020). Epidemiological models provide a truer mechanistic account of transmission dynamics, but are complex and beyond the reach of most healthcare analysts (Bardsley et al, 2019). Any additional insight should be factored into decision making where possible so that no one solution is exclusively relied upon, as should be standard practice when modelling is concerned.
>
> **Nowcasting for improved management of COVID-19 acute bed capacity**
>
>**Richard M Wood**
>
>**British Journal of Healthcare Management 2021 27:2, 1-3**

# Data format

Data must be reshaped into a 'long' format. 

In this case, this means having three columns (with any names)

- one containing dates
- one containing values
- OPTIONAL: one containing an identifier to separate out multiple attributes/measures within the dataset

# Benefits and limitations of the Power BI implementation

R-based custom visuals in Power BI incur a large performance penalty due to the need to spin up a fresh R session for every visual. While some things can be done to minimize the penalty, there is always going to be a much longer load time than for a standard PowerBI visual or a custom one written in Typescript. However, this visual may help with prototyping and proof of concept dashboards.   

![bildo](https://github.com/Bergam0t/nowcasts-power-bi/assets/29951987/2f46f6af-a940-43ae-a5cb-cd8cb6eaf8a7)

 

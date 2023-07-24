source('./r_files/flatten_HTML.r')

############### Library Declarations ###############
libraryRequireInstall("ggplot2");
libraryRequireInstall("plotly");
libraryRequireInstall("dplyr");
libraryRequireInstall("forecast")
####################################################


# Import the mandatory columns
if(exists("value")) value <- value else value <- NULL
if(exists("date")) date <- date else date <- NULL

dataset <- cbind(value, date) 

# Import the optional columns
if(exists("what") && !is.null(what)) dataset <- bind_cols(dataset, what) else dataset <- dataset %>% mutate(what = NA)

colnames(dataset) <- c("value", "date", "what") 

# Test dataset - uncomment to use
# dataset <- read.csv("nowcasts_sample.csv")
# date_list <- seq.Date(from=lubridate::today(), to=(lubridate::today() - lubridate::days(nrow(dataset)-1)), by="-1 day") %>% sort()
# dataset <- dataset %>% bind_cols(date1=date_list) %>% select(-dates) %>% rename(date=date1)
# dataset <- dataset %>% tidyr::gather("what", "value", -date)

dat1 <- dataset %>% 
  mutate(date = as.Date(date)) %>% 
  rename(num=value, measure=what, dates=date)

# p <- DT::datatable(dat1)

################### Actual code ####################

today_date<-Sys.Date()

fitting_window<-30

proj_window<-7

#######################################################################################################################################################

fets<-function(x,h) forecast(ets(x),h=h)
farima<-function(x,h) forecast(auto.arima(x),h=h)

options(warn=-1)

# today_date<-as.Date(today_date,"%Y-%m-%d")

dat2<-lapply(unique(dat1$measure),function(z) {
  tmp0<-dat1[which(dat1$measure==z),]
  
  tmp1<-tmp0 %>%
    filter(dates<=today_date) %>%
    do(tail(.,n=fitting_window))
  
  tmp2<-ts(tmp1$num,start=c(as.numeric(format(tmp1$dates[1],"%Y")),as.numeric(format(tmp1$dates[1],"%j"))))
  
  err_ets<-tsCV(tmp2,fets,h=1)
  ts_ets<-mean(err_ets^2,na.rm=TRUE)
  
  err_arima<-tsCV(tmp2,farima,h=1)
  ts_arima<-mean(err_arima^2,na.rm=TRUE)
  
  if (ts_ets<ts_arima) {
    tmp3<-tmp2 %>%
      ets()
    tmp4<-tmp3 %>%
      forecast(h=proj_window)
    print(paste("fitted ets to",tmp1$measure[1]),quote=FALSE)
  } else {
    tmp3<-tmp2 %>%
      auto.arima()
    tmp4<-tmp3 %>%
      forecast(h=proj_window)
    print(paste("fitted arima to",tmp1$measure[1]," (arima order:",paste(arimaorder(tmp3),collapse=" "),")"),quote=FALSE)
  }
  
  x<-seq.Date(min(tmp1$dates),by=1,length.out=length(c(tmp4$x,tmp4$mean)))
  
  output_df<-data.frame(measure=tmp1$measure[1],dates=x) %>%
  mutate(ycentral=c(tmp4$x,tmp4$mean),
        ylower1=c(tmp4$x,tmp4$lower[,2]),
        ylower2=c(tmp4$x,tmp4$lower[,1]),
        yupper1=c(tmp4$x,tmp4$upper[,2]),
        yupper2=c(tmp4$x,tmp4$upper[,1])
        ) %>% 
        left_join(tmp0 %>% select(-measure),
                  by="dates")
  
  return(output_df)
})

p <- ggplotly(
     dat2 %>%
    bind_rows() %>%
    group_by(measure) %>% 
    mutate(max_date = max(dates, na.rm=TRUE)-proj_window) %>% 
    mutate(ylower1a=ifelse(dates>max_date,round(ylower1,0),NA)) %>%
    mutate(ylower1a=ifelse(as.numeric(dates) %% 2 == as.numeric(today_date) %% 2,NA,ylower1a)) %>%
    mutate(yupper1a=ifelse(dates>max_date,round(yupper1,0),NA)) %>%
    mutate(yupper1a=ifelse(as.numeric(dates) %% 2 == as.numeric(today_date) %% 2,NA,yupper1a)) %>%
    mutate(ycentrala=ifelse(dates>max_date,round(ycentral,0),NA)) %>%
    mutate(ycentrala=ifelse(as.numeric(dates) %% 2 == as.numeric(today_date) %% 2,NA,ycentrala)) %>% 
    ungroup() %>% 
    ggplot(aes(x=dates)) +
    geom_ribbon(aes(ymin=ylower1,ymax=yupper1),fill="steelblue1",alpha=0.4) +
    geom_ribbon(aes(ymin=ylower2,ymax=yupper2),fill="steelblue3",alpha=0.4) +
    geom_line(aes(y=ycentral),colour="dodgerblue4",size=1) +
    facet_wrap(~measure, scales="free_x") +
    geom_text(aes(x=dates,y=as.numeric(ylower1a),label=ylower1a),position=position_dodge(width=0.9),vjust=+1.5,size=2) +
    geom_text(aes(x=dates,y=as.numeric(yupper1a),label=yupper1a),position=position_dodge(width=0.9),vjust=-1,size=2) +
    geom_text(aes(x=dates,y=as.numeric(ycentrala),label=ycentrala),position=position_dodge(width=0.9),vjust=-0.8,size=2) +
    scale_x_date(breaks=scales::pretty_breaks(n=6)) +
    scale_y_continuous(breaks=scales::pretty_breaks(n=6),expand=expansion(mult=c(0,0.15))) +
    coord_cartesian(ylim=c(0,NA)) +
    theme_minimal() +
    theme(axis.title.x=element_blank(),
          #axis.text.x=element_text(angle=45,hjust=1),
          axis.title.y=element_blank())

  )

####################################################

############# Create and save widget ###############
internalSaveWidget(p %>% plotly::partial_bundle(local=FALSE), 'out.html');
####################################################

################ Reduce paddings ###################
ReadFullFileReplaceString('out.html', 'out.html', ',"padding":[0-9]*,', ',"padding":0,')
####################################################

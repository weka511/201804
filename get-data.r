# MIT License
# 
# Copyright (c) 2018 Simon Crase
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

rm(list=ls())

library(plyr)

# Extract data from a Netlogo BehaviourSpace experiment
read.nlogo.experiment<-function(path.name="C:/Users/Weka/201804/Experiments",file.name="take2 experiment-table.csv"){
    my.df <-
      read.table(
        file.path(path.name,file.name),
        header = T,
        sep = ",",
        skip = 6,
        quote = "\"",
        fill = TRUE
      )
    i <- 1
    for (name in colnames(my.df)) {
      new_name <- gsub("\\.", "_", name)
      names(my.df)[i] <- new_name
      i = i + 1
    }
    return (my.df)
  }
  
get.tau <-
  function (path.name="C:/Users/Weka/201804/Experiments",file.name="take2 experiment-table.csv") {
    my.df = read.nlogo.experiment(path.name,file.name)
    return(my.df[my.df$X_step_ == max(my.df$X_step_), ])
  }
  
extract.tau<-function(tau.data,can_borrow=TRUE,randomize_step=TRUE){
  mydata.canborrow <- if (can_borrow) "true" else "false"
  mydata.randomize_step <- if (randomize_step) "true" else "false"
  return (tau.data[tau.data$randomize_step==mydata.randomize_step&tau.data$can_borrow==mydata.canborrow,]) 
}

extract.step.data<-function(netlogo.data,can_borrow=TRUE,randomize_step=TRUE,tau=0,n_predictors=3,n_coefficients=3){
  mydata.canborrow <- if (can_borrow) "true" else "false"
  mydata.randomize_step <- if (randomize_step) "true" else "false"
  return (netlogo.data[netlogo.data$randomize_step==mydata.randomize_step & 
                         netlogo.data$can_borrow==mydata.canborrow &
                         netlogo.data$tau==tau &
                         netlogo.data$n_predictors==n_predictors &
                         netlogo.data$n_coefficients==n_coefficients,
                       ]) 
}

extract.wealth.vs.tau<-function(tau.data,can_borrow=TRUE,randomize_step=TRUE) {
  tau.data<-extract.tau(tau.data,can_borrow,randomize_step)
  tau.data.end<-tau.data[tau.data$X_step_==tau.data$n_ticks,]
  return (aggregate(tau.data.end,by=list(tau.data.end$tau),FUN=mean,na.rm=TRUE))
}

extract.errors.vs.tau<-function(tau.data,tau=0,can_borrow=TRUE,randomize_step=TRUE) {
  tau.data<-extract.tau(tau.data,can_borrow,randomize_step)
  return (tau.data[tau.data$tau==tau,])
}

# Get names of input parameters that have more than one value in experiment file
get.names.of.varying.parameters<-function(data,min_col=2,max_col=17) {
  is.varying<-function(name){
    return (nrow(unique(data[name]))>1)
  }
  return (Filter(is.varying,colnames(data)[min_col:max_col]))
}

# Get total number of combinations of input parameters values
get.n.configurations<-function(data) {
  product = 1
  for (name in get.names.of.varying.parameters(data)) {
    product = product * nrow(unique(data[name]))
  }
  return (product)
}

get.n.repetitions<-function(data){
  return (  length(unique(data$X_run_number_)) / get.n.configurations(data))
}

get.ns<-function(data){
  f<-function(name){toString(unique(data[name]))}
  return (lapply(get.configurations(data),f))
}

get.netlogo.values<-function(data){
  get.param.values<-function(name){
      values<-unique(data[name])[[1]]
      return (paste(values,collapse=", "))
    }
  return (lapply(get.names.of.varying.parameters(data),get.param.values))
}

get.netlogo.params<-function(data){
  return ( data.frame(get.names.of.varying.parameters(data),
                      unlist(get.netlogo.values(data))) )
}

plot.errors<-function(netlogo.data,can_borrow=TRUE,randomize_step=TRUE,tau=0,n_predictors=3,n_coefficients=3) {
  err<-extract.step.data(netlogo.data,can_borrow,randomize_step,tau,n_predictors,n_coefficients)
  rbPal <- colorRampPalette(c('red','blue'))
  err$Col <- rbPal(10)[as.numeric(cut(err$X_run_number_,breaks = 10))]
  plot(err$X_step_,err$mean__sum_squares_error__of_investors,
       xlab = "Step",ylab = "Squared error",pch=1,col=err$Col,
       main=sprintf("n_predictors=%d, n_coefficients=%d",n_predictors,n_coefficients))
}

plot.wealth<-function(netlogo.data,can_borrow=TRUE,randomize_step=TRUE,tau=0,n_predictors=3,n_coefficients=3) {
  err<-extract.step.data(netlogo.data,can_borrow,randomize_step,tau,n_predictors,n_coefficients)
  rbPal <- colorRampPalette(c('red','blue'))
  err$Col <- rbPal(10)[as.numeric(cut(err$X_run_number_,breaks = 10))]
  plot(err$X_step_,err$mean__wealth__of_investors,
       xlab = "Step",ylab = "Wealth",pch=1,col=err$Col,
       main=sprintf("n_predictors=%d, n_coefficients=%d",n_predictors,n_coefficients))
}

plot.outgoings<-function(netlogo.data,can_borrow=TRUE,randomize_step=TRUE,tau=0,n_predictors=3,n_coefficients=3) {
  err<-extract.step.data(netlogo.data,can_borrow,randomize_step,tau,n_predictors,n_coefficients)
  plot(err$X_step_,err$outgoings_POOL_HIGH,
       xlab = "Step",ylab = "Payout",pch=20,col="red",
       main=sprintf("n_predictors=%d, n_coefficients=%d",n_predictors,n_coefficients))
  points(err$X_step_,err$outgoings_POOL_LOW,pch=1,col="yellow")
  points(err$X_step_,err$outgoings_POOL_STABLE,pch=20,col="green")    
}

accumulate.wealth<-function(payoffs,choices,tau=1) {
  my.wealth<-0
  change.count<- -1
  last.choice<- -1
  calculate.wealth<-function(pay){
    assign('my.wealth', my.wealth+pay, inherits=TRUE)
    return (my.wealth)
  }
  count.changes<-function(choice){
    if (choice!=last.choice){
      assign('change.count',change.count+1,inherits = TRUE)
      assign('last.choice',choice,inherits = TRUE)
    }
    return (change.count)
  }
  receipts <- sapply(payoffs,calculate.wealth)
  costs <- sapply(choices,count.changes)
  return ( receipts - tau * costs)
}

plot.individuals<-function(my.details,n=3,my.strategy=0){
  wealths<-subset(my.details,step==max(my.details$step) & strategy==my.strategy,select=c('wealth','who','strategy'))
  wealths<-wealths[order(wealths$wealth),]
  N=length(wealths$wealth)
  n2 <- floor(3*N/4-n/2)
  exemplars<-wealths[c(1:n,n2:(n2+n-1),(N-n+1):N),]
  max.wealth <- round_any(max(wealths$wealth),10,f=ceiling)
  plot(0:100,0:100, xlab = "Step",ylab = "Wealth",type='n',
       xlim=c(0,max(my.details$step)),ylim=c(0,max.wealth),
       main=sprintf('Growth of wealth for strategy=%d',my.strategy))
  colours=c('blue','red')
  for (who in exemplars$who) {
    plot.data<-my.details[my.details$who==who,]
    plot.data$extra<-accumulate.wealth(plot.data$payoffs,plot.data$choices)
    lines(plot.data$step,plot.data$extra,type='l',col=colours[my.strategy+1])
  }
}

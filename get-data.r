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

read.nlogo.experiment<-function(path.name,file.name){
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

# x<-tau.data[tau.data$randomize_step=="true"&tau.data$can_borrow=="true",]


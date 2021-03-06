\name{varSelRF}
\alias{varSelRF}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Variable selection from random forests using OOB error}
\description{
  Using an error metric (OOB by default) as minimization criterion, carry out variable
  elimination from
  random forest, by successively eliminating the least important
  variables (with importance as returned from random forest).
}
\usage{
varSelRF(xdata, Class, 
        error=function(rf){
                       ooo <- rf$confusion[, -dim(rf$confusion)[2]]
                       s.ooo <- sum(ooo)
                       diag(ooo) <- 0
                       sum(ooo)/s.ooo},
         c.sd = 1, mtryFactor = 1, ntree = 5000,
         ntreeIterat = 2000, vars.drop.num = NULL, vars.drop.frac = 0.2,
         whole.range = TRUE, recompute.var.imp = FALSE, verbose = FALSE,
         returnFirstForest = TRUE, fitted.rf = NULL, keep.forest = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{xdata}{A data frame or matrix, with subjects/cases in rows and
    variables in columns. NAs not allowed.}
  \item{Class}{The dependent variable; must be a factor.}
  \item{error}{The error metric; should be a function that takes a randomForest
  object as its only argument and returns the error measure for that forest}
  \item{c.sd}{The factor that multiplies the sd. to decide on stopping
    the tierations or choosing the final solution. See reference for details.}
  \item{mtryFactor}{The multiplication factor of
    \eqn{\sqrt{number.of.variables}} for the number of variables to use for
    the ntry argument of randomForest.}
  \item{ntree}{The number of trees to use for the first forest;
    same as ntree for randomForest.}
  \item{ntreeIterat}{The number of trees to use (ntree of randomForest)
    for all additional forests.}
  \item{vars.drop.num}{The number of variables to exclude at each iteration.}
  \item{vars.drop.frac}{The fraction of variables, from those
  in the previous forest, to exclude at each iteration.}
  \item{whole.range}{If TRUE continue dropping variables until a forest
    with only two variables is built, and choose the best model from the
    complete series of models. If
    FALSE, stop the iterations if the current OOB error becomes larger
    than the initial OOB error (plus c.sd*OOB standard error) or
    if the current OOB error becoems larger than the
    previous OOB error (plus c.sd*OOB standard error).}
  \item{recompute.var.imp}{If TRUE recompute variable importances at
    each new iteration.}
  \item{verbose}{Give more information about what is being done.}
  \item{returnFirstForest}{If TRUE the random forest from the complete
    set of variables is returned.}
  \item{fitted.rf}{An (optional) object of class
    randomForest previously fitted. In this case, the ntree and
    mtryFactor arguments are obtained from the fitted object, not the
    arguments to this function.}
  \item{keep.forest}{Same argument as in randomForest function. If the
    forest is kept, it will be returned as part of the "rf.model"
    component of the output. Beware that setting this to TRUE can lead
 to very large memory consumption.}
}
\details{
  With the default parameters, we examine all forest that result from
  eliminating, iteratively, a fraction, \code{vars.drop.frac}, of the least
  important variables used in the previous iteration. By default,
  \code{vars.frac.drop = 0.2} which allows for relatively fast operation,
  is coherent with the idea of an ``aggressive variable selection''
  approach, and increases the resolution as the number of variables
  considered becomes smaller.  By default, we do not recalculate variable
  importances at each step (\code{recompute.var.imp = FALSE})
  as \cite{Svetnik et al. 2004} mention severe overfitting
  resulting from recalculating variable importances. After fitting all
  forests, we examine the OOB error rates from all the fitted random
  forests. We choose the solution with the smallest number of genes
  whose error rate is within \code{c.sd} standard errors of the minimum error
  rate of all forests. (The standard error is calculated using the 
  expression for a biomial error count [\eqn{\sqrt{p (1-p) * 1/N}}]).
  Setting \code{c.sd = 0} is the same as selecting the set of genes that leads
  to the smallest error rate.  Setting \code{c.sd = 1} is similar to the
  common ``1 s.e.  rule'', used in the classification trees literature;
  this strategy can lead to solutions with
  fewer genes than selecting the solution with the smallest error rate,
  while achieving an error rate that is not different, within sampling
  error, from the ``best solution''.

  The use of \code{ntree = 5000} and \code{ntreeIterat = 2000} is
  discussed in longer detail in the references. Essentially, more
  iterations rarely seem to lead (with 9 different microarray data sets)
  to improved solutions.

  The measure of variable importance used is based on the decrease
  of classification accuracy when values of a variable in a node of a
  tree are permuted randomly (see references); we use the unscaled
  version ---see our paper and supplementary material.

}
\value{An object of class "varSelRF": a list with components:
  \item{selec.history}{A data frame where the selection history is
    stored. The components are:
    \describe{
      \item{Number.Variables}{The number of variables examined.}
      \item{Vars.in.Forest}{The actual variables that were in the forest
	at that stage.}
      \item{OOB}{Out of bag error rate.}
      \item{sd.OOB}{Standard deviation of the error rate.}
    }
  }
  \item{rf.model}{The final, selected, random forest (only if
    \code{whole.range = FALSE}). (If you set whole.range = TRUE, the
    final model always contains exactly two variables. This is unlikely
    to be the forest that interests you).}
  \item{selected.vars}{The variables finally selected.}
  \item{selected.model}{Same as above, but ordered alphabetically and
    concatenated with a "+" for easier display.}
  \item{best.model.nvars}{The number of variables in the finally
    selected model.}
  \item{initialImportance}{The importances of variables, before any
    variable deletion.}
  \item{initialOrderedImportances}{Same as above but ordered in by
    decreasing importance.}
  \item{ntree}{The \code{ntree} argument.}
  \item{ntreeIterat}{The \code{ntreeIterat} argument.}
  \item{mtryFactor}{The \code{mtryFactor} argument.}
  \item{firstForest}{The first forest (before any variable selection) fitted.}
}
\references{

  Breiman, L. (2001) Random forests.
  \emph{Machine Learning}, \bold{45}, 5--32.

  Diaz-Uriarte, R. and Alvarez de Andres,
    S. (2005) Variable selection from random forests: application to gene
    expression
    data. Tech. report.
    \url{http://ligarto.org/rdiaz/Papers/rfVS/randomForestVarSel.html}

 Svetnik, V., Liaw, A. , Tong, C & Wang, T. (2004) Application of
 Breiman's random forest to modeling structure-activity relationships of
 pharmaceutical molecules.  Pp. 334-343 in \emph{F. Roli, J. Kittler, and T. Windeatt}
 (eds.). \emph{Multiple Classier Systems, Fifth International Workshop}, MCS
 2004, Proceedings, 9-11 June 2004, Cagliari, Italy. Lecture Notes in
 Computer Science, vol. 3077.  Berlin: Springer.

}
\author{Ramon Diaz-Uriarte  \email{rdiaz02@gmail.com}}

\seealso{\code{\link[randomForest]{randomForest}},
  \code{\link{plot.varSelRF}},
  \code{\link{varSelRFBoot}}}
\examples{
set.seed(1)
x <- matrix(rnorm(25 * 30), ncol = 30)
colnames(x) <- paste("v", 1:30, sep = "")
x[1:10, 1:2] <- x[1:10, 1:2] + 1
x[1:4, 5] <- x[1:4, 5] - 1.5
x[5:10, 8] <- x[5:10, 8] + 1.4 

cl <- factor(c(rep("A", 10), rep("B", 15)))  
rf.vs1 <- varSelRF(x, cl, ntree = 500, ntreeIterat = 300,
                   vars.drop.frac = 0.2)
rf.vs1
plot(rf.vs1)


#### Using the final, fitted model to predict other data

## Simulate new data
set.seed(2)
x.new <- matrix(rnorm(25 * 30), ncol = 30)
colnames(x.new) <- paste("v", 1:30, sep = "")
x.new[1:10, 1:2] <- x.new[1:10, 1:2] + 1
x.new[1:10, 5] <- x.new[1:10, 5] - 0.5


## Fit with whole.range = FALSE and keep.forest = TRUE
set.seed(3)
rf.vs2 <- varSelRF(x, cl, ntree = 3000, ntreeIterat = 2000,
                   vars.drop.frac = 0.3, whole.range = FALSE,
                   keep.forest = TRUE)


## To obtain predictions from a data set, you must specify the
## same variables as those used in the final model

rf.vs2$selected.vars


predict(rf.vs2$rf.model,
        newdata = subset(x.new, select = rf.vs2$selected.vars))
predict(rf.vs2$rf.model,
        newdata = subset(x.new, select = rf.vs2$selected.vars),
        type = "prob")


## If you had not kept the forest (keep.forest) you could also try
randomForest(y = cl, x = subset(x, select = rf.vs2$selected.vars),
             ntree = rf.vs2$ntreeIterat,
             xtest = subset(x, select = rf.vs2$selected.vars))$test

## but here the forest is built new (with only the selected variables)
## so results need not be the same



## CAUTION: You will NOT want this (these are similar to resubstitution
##   predictions)

predict(rf.vs2$rf.model, newdata = subset(x, select = rf.vs2$selected.vars))

## nor these (read help of predict.randomForest for why these
## predictions are different from those from previous command)

predict(rf.vs2$rf.model)


}
\keyword{tree}% at least one, from doc/KEYWORDS
\keyword{classif}% __ONLY ONE__ keyword per line

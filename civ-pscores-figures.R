library(mvtnorm)

# Functions --------------------------------------------------------------------------

pscores<-function(outcomes,var.outcomes,correlation,beta,type,label)
{
  # package mvtnorm is needed (https://cran.r-project.org/web/packages/mvtnorm/index.html)
  # this function estimates P-scores (presented in this paper https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/s12874-015-0060-8) for i) ranking many outcomes simultaneously ii) taking into account differences of a certain effect across treatments
  # outcomes is an array with all the league tables of the K outcomes we consider
  # var.outcomes is an array with the standard errors of the relative effects shown in the league table
  # correlation is KxK correlation matrix for the outcomes considered
  # beta is a K-vector with the benefits and costs (what we are willing to tolerate for specific benefits). Primary analysis should be that beta is a zero vector
  # type is a K-vector for the type of outcome Harmful=H or Benebicial=B. For harmful outcomes, small values are good whereas for beneficial outcomes, large values are good
  # label is a vector with the lables of the interventions
  p=dim(outcomes)[[1]]

  k=dim(outcomes)[[3]]

  for (h in 1:k)
  {
    if (type[h]=="H")
    {
      outcomes[,,h]=-outcomes[,,h]
    }
  }

  z.table=array(rep(0,p^2*k),c(p,p,k),dimnames=list(label))

  for (h in 1:k)
  {
    for (i in 1:p)
    {
      for (j in 1:p)
      {
        if (i>j)
        {
          z.table[i,j,h]=(outcomes[i,j,h]-beta[h])/sqrt(var.outcomes[i,j,h])
        }
        else if (j>i)
        {
          z.table[i,j,h]=(outcomes[i,j,h]+beta[h])/sqrt(var.outcomes[i,j,h])

        }
      }
    }
  }

  prob=matrix(rep(0,p^2),p,p,dimnames=list(label))

  if (dim(outcomes)[[3]]==1)
  {
    for (i in 1:p)
    {for (j in 1:p)
    {if (i==j)
    {prob[i,j]=0.5}  else if (j>i)
    {prob[i,j]=pnorm(z.table[i,j,1])}
      else
      {prob[i,j]=1-pnorm(z.table[i,j,1])}
    }
    }
  }

  else
  {
    for (i in 1:p)
    {
      for (j in 1:p)
      {
        if (i==j)
        {
          prob[i,j]=0.5
        }
        else if (j>i)
        {
          prob[i,j]=pmvnorm(lower=rep(-Inf,k),upper=c(z.table[i,j,]),mean=rep(0,k),correlation)

        }
        else
        {
          prob[i,j]=pmvnorm(lower=c(z.table[i,j,]),upper=rep(Inf,k),mean=rep(0,k),correlation)
        }
      }
    }
  }
  pscore=(rowSums(prob)-0.5)/(p-1)

}

# Second version - for one outcome, the mean is 0.5
pscores2<-function(outcomes,var.outcomes,correlation,beta,type,label) {
  # package mvtnorm is needed (https://cran.r-project.org/web/packages/mvtnorm/index.html)
  # this function estimates P-scores (presented in this paper https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/s12874-015-0060-8) for i) ranking many outcomes simultaneously ii) taking into account differences of a certain effect across treatments
  # outcomes is an array with all the league tables of the K outcomes we consider
  # var.outcomes is an array with the standard errors of the relative effects shown in the league table
  # correlation is KxK correlation matrix for the outcomes considered
  # beta is a K-vector with the benefits and costs (what we are willing to tolerate for specific benefits). Primary analysis should be that beta is a zero vector
  # type is a K-vector for the type of outcome Harmful=H or Benebicial=B. For harmful outcomes, small values are good whereas for beneficial outcomes, large values are good
  # label is a vector with the lables of the interventions
  p=dim(outcomes)[[1]]

  k=dim(outcomes)[[3]]

  for (h in 1:k)
  {
    if (type[h]=="H")
    {
      outcomes[,,h]=-outcomes[,,h]

    }

  }

  z.table=array(rep(0,p^2*k),c(p,p,k),dimnames=list(label))

  for (h in 1:k)
  {
    for (i in 1:p)
    {
      for (j in 1:p)
      {
        if (i>j)
        {
          z.table[i,j,h]=ifelse(abs(outcomes[i,j,h]) > abs(beta[h]),
                                -outcomes[i,j,h]/sqrt(var.outcomes[i,j,h]),
                                0)
        }
        else if (j>i)
        {
          z.table[i,j,h]=ifelse(abs(outcomes[i,j,h]) > abs(beta[h]),
                                outcomes[i,j,h]/sqrt(var.outcomes[i,j,h]),
                                0)

        }
      }
    }
  }

  prob=matrix(rep(0,p^2),p,p,dimnames=list(label))

  if (dim(outcomes)[[3]]==1)
  {
    for (i in 1:p)
    {for (j in 1:p)
    {if (i==j)
    {prob[i,j]=0.5}  else
    {prob[i,j]=pnorm(z.table[i,j,1])}
    }
    }
  }
  else
  {
    for (i in 1:p)
    {
      for (j in 1:p)
      {
        if (i==j)
        {
          prob[i,j]=0.5
        }
        else if (j > i)
        {
          prob[i,j]=pmvnorm(lower=rep(-Inf,k),upper=c(z.table[i,j,]),mean=rep(0,k),correlation)

        }
        else
        {
          prob[i,j]=pmvnorm(lower=c(z.table[i,j,]),upper=rep(Inf,k),mean=rep(0,k),correlation)
        }
      }
    }
  }
  pscore=(rowSums(prob)-0.5)/(p-1)

}

################## Schizophrenia Lancet paper - inserting data##########################

#Data can be found in Figure 2 (efficacy and acceptability/all-cause discontinuation) and Figure 5 (weight gain) in the publication
#https://www.sciencedirect.com/science/article/pii/S0140673613607333

#Leucht, S., Cipriani, A., Spineli, L., Mavridis, D., Örey, D., Richter, F., Samara, M., Barbui, C., Engel, R. R., Geddes, J. R., Kissling, W., Stapf, M. P., Lässig, B., Salanti, G. and Davis, J. M. (2013). Comparative efficacy and tolerability of 15 antipsychotic drugs in schizophrenia: A multiple-treatments meta-analysis. The Lancet 382, 951-962

p=16

antipsychotic=c("CLO", "AMI", "OLA", "RIS", "PAL" ,"ZOT", "HAL", "QUE", "ARI" ,"SER", "ZIP", "CPZ" ,"ASE" ,"LUR" ,"ILO", "PBO")


############## efficacy - effect size #########################################

# effect size

x=c(-0.22,-0.29,-0.32,-0.38,-0.39,-0.43,-0.44,-0.45,-0.49,-0.49,-0.5 ,-0.5 ,-0.55,-0.55,-0.88,

    -0.07,-0.09,-0.16,-0.17,-0.21,-0.22,-0.23,-0.27,-0.26,-0.27,-0.27,-0.33,-0.33,-0.66,

    -0.03,-0.09,-0.1 ,-0.14,-0.15,-0.16,-0.2 ,-0.2 ,-0.21,-0.21,-0.26,-0.26,-0.59,

    -0.07,-0.08,-0.11,-0.13,-0.13,-0.17,-0.17,-0.18,-0.18,-0.23,-0.24,-0.56,

    0.01,-0.05,-0.06,-0.07,-0.1 ,-0.1 ,-0.11,-0.11,-0.17,-0.17,-0.5 ,

    -0.04,-0.05,-0.06,-0.09,-0.09,-0.1 ,-0.1 ,-0.16,-0.16,-0.49,

    -0.01,-0.02,-0.06,-0.05,-0.05,-0.07,-0.12,-0.12,-0.45,

    -0.01,-0.04,-0.04,-0.05,-0.05,-0.11,-0.11,-0.44,

    -0.04,-0.04,-0.05,-0.05,-0.10,-0.10,-0.43,

    0,-0.01,-0.01,-0.06,-0.07,-0.39,

    -0.01,-0.01,-0.07,-0.07,-0.39,

    0,-0.05,-0.06,-0.38,

    -0.05,-0.06,-0.38,

    0,-0.33,

    -0.33)



efficacy=matrix(rep(0,p^2),p,p,dimnames=list(antipsychotic))

efficacy[lower.tri(efficacy)]=x

efficacy=t(efficacy)

efficacy[lower.tri(efficacy)]=x

################# efficacy 95% CI ########################################

# lower bound for efficacy (95%)

efficacy.lower=c(-0.41,-0.44,-0.47,-0.57,-0.60,-0.58,-0.61,-0.62,-0.68,-0.66,-0.67,-0.69,-0.74,-0.73,-1.03,

                 -0.19,-0.21,-0.32,-0.38,-0.32,-0.36,-0.37,-0.43,-0.41,-0.47,-0.45,-0.50,-0.48,-0.78,

                 -0.10,-0.21,-0.29,-0.21,-0.25,-0.25,-0.33,-0.29,-0.37,-0.34,-0.39,-0.38,-0.65,

                 -0.19,-0.26,-0.18,-0.22,-0.23,-0.31,-0.27,-0.34,-0.32,-0.37,-0.35,-0.63,

                 -0.22,-0.16,-0.19,-0.20,-0.27,-0.24,-0.30,-0.28,-0.33,-0.32,-0.60,

                 -0.21,-0.24,-0.25,-0.31,-0.29,-0.32,-0.32,-0.37,-0.36,-0.66,

                 -0.10,-0.12,-0.19,-0.15,-0.22,-0.20,-0.25,-0.23,-0.51,

                 -0.12,-0.19,-0.16,-0.22,-0.20,-0.25,-0.24,-0.52,

                 -0.19,-0.16,-0.22,-0.20,-0.25,-0.24,-0.52,

                 -0.15,-0.21,-0.19,-0.24,-0.23,-0.52,

                 -0.19,-0.17,-0.22,-0.20,-0.49,

                 -0.20,-0.25,-0.24,-0.54,

                 -0.23,-0.22,-0.51,

                 -0.16,-0.45,

                 -0.43)


# upper bound for efficacy (95%)


efficacy.upper=c(-0.04,-0.14,-0.16,-0.20,-0.19,-0.28,-0.28,-0.28,-0.30,-0.31,-0.33,-0.30,-0.36,-0.38,-0.73,

                 0.05,0.03,0.00,0.04,-0.09,-0.08,-0.08,-0.10,-0.12,-0.08,-0.10,-0.16,-0.18,-0.53,

                 0.04,0.02,0.08,-0.08,-0.06,-0.07,-0.06,-0.10,-0.05,-0.08,-0.13,-0.15,-0.53,

                 0.06,0.11,-0.05,-0.03,-0.03,-0.04,-0.07,-0.02,-0.04,-0.10,-0.12,-0.50,

                 0.20,0.08,0.08,0.08,0.07,0.04,0.08,0.05,0.00,-0.02,-0.39,

                 0.14,0.14,0.14,0.12,0.11,0.11,0.11,0.06,0.04,-0.31,

                 0.08,0.08,0.07,0.04,0.09,0.07,0.01,-0.02,-0.39,

                 0.11,0.10,0.08,0.11,0.09,0.03,0.02,-0.35,

                 0.11,0.09,0.13,0.10,0.05,0.03,-0.34,

                 0.16,0.19,0.17,0.11,0.10,-0.26,

                 0.16,0.14,0.09,0.06,-0.30,

                 0.20,0.14,0.13,-0.23,

                 0.12,0.11,-0.25,

                 0.16,-0.21,

                 -0.22)


var.effic=((efficacy.upper-efficacy.lower)/3.92)^2

var.efficacy=matrix(rep(0,p^2),p,p,dimnames=list(antipsychotic))

var.efficacy[lower.tri(var.efficacy)]=var.effic


var.efficacy<-t(var.efficacy)

var.efficacy[lower.tri(var.efficacy)]=var.effic

############## weight - effect size #########################################

weight=matrix(rep(0,p^2),p,p,dimnames=list(antipsychotic))

# effect size

x=c(0.45,-0.09,0.23,0.27,-0.06,0.57,0.22,0.49,0.12,0.55,0.1,0.42,0.55,0.04,0.65,

    -0.54,-0.22,-0.21,-0.52,0.08,-0.23,0.03,-0.33,0.1,-0.35,-0.03,0.1,-0.42,0.2,

    0.32,0.36,0.03,0.65,0.31,0.57,0.21,0.64,0.19,0.51,0.64,0.12,0.74,

    0.04,-0.3,0.42,-0.01,0.25,-0.11,0.32,-0.13,0.19,0.32,-0.2,0.42,

    -0.34,0.29,-0.05,0.21,-0.15,0.28,-0.17,0.15,0.28,-0.24,0.38,

    0.71,0.28,0.55,0.18,0.61,0.16,0.48,0.62,0.1,0.71,

    -0.34,-0.08,-0.45,-0.01,-0.46,-0.14,-0.01,-0.53,0.09,

    0.26,-0.1,0.33,-0.12,0.2,0.33,-0.19,0.32,

    -0.37,0.07,-0.38,-0.06,0.07,-0.45,0.17,

    0.43,-0.02,0.3,0.43,-0.08,0.53,

    -0.45,-0.13,0,-0.52,0.1,

    0.32,0.45,-0.07,0.55,

    0.13,-0.39,0.23,

    -0.52,0.1,

    0.62)

weight[lower.tri(weight)]=x

weight=t(weight)

weight[lower.tri(weight)]=x

################# weight 95% CI ########################################

# lower bound for weight gain (95%)


weight.lower=c(-0.82,-0.43,-0.57,-0.63,-0.48,-0.9,-0.55,-0.83,-0.48,-0.91,-0.46,-0.79,-0.9,-0.39,-0.99,

               -0.69,-0.37,-0.36,-0.79,-0.27,-0.41,-0.21,-0.53,-0.28,-0.61,-0.24,-0.29,-0.6,-0.35,

               -0.41,-0.48,-0.27,-0.74,-0.41,-0.7,-0.35,-0.76,-0.4,-0.67,-0.77,-0.26,-0.81,

               -0.17,-0.55,-0.43,-0.12,-0.38,-0.27,-0.45,-0.35,-0.36,-0.46,-0.33,-0.5,

               -0.6,-0.42,-0.19,-0.37,-0.34,-0.43,-0.41,-0.34,-0.43,-0.4,-0.48,

               -0.86,-0.53,-0.81,-0.46,-0.88,-0.45,-0.77,-0.88,-0.37,-0.96,

               -0.46,-0.21,-0.59,-0.14,-0.68,-0.31,-0.15,-0.67,-0.17,

               -0.41,-0.26,-0.48,-0.33,-0.38,-0.48,-0.33,-0.53,

               -0.55,-0.21,-0.62,-0.25,-0.23,-0.61,-0.28,

               -0.61,-0.27,-0.51,-0.62,-0.27,-0.68,

               -0.69,-0.32,-0.16,-0.67,-0.22,

               -0.58,-0.69,-0.3,-0.76,

               -0.32,-0.58,-0.39,

               -0.69,-0.21,

               -0.74)

# upper bound for acceptability (95%)


weight.upper<-c(-0.09,0.24,0.12,0.12,0.34,-0.22,0.12,-0.13,0.25,-0.2,0.25,-0.06,-0.19,0.32,-0.31,

                -0.4,-0.07,0,-0.24,0.04,-0.07,0.15,-0.14,0.08,-0.1,0.17,0.08,-0.22,-0.05,

                -0.24,-0.24,0.22,-0.57,-0.2,-0.45,-0.06,-0.52,0.02,-0.35,-0.51,0.01,-0.67,

                0.09,-0.05,-0.23,0.1,-0.12,0.04,-0.19,0.09,-0.02,-0.19,-0.06,-0.33,

                -0.08,-0.16,0.08,-0.06,0.02,-0.13,0.06,0.04,-0.12,-0.08,-0.27,

                -0.39,-0.03,-0.28,0.09,-0.36,0.13,-0.19,-0.35,0.17,-0.47,

                -0.24,0.05,-0.3,0.11,-0.25,0.02,0.12,-0.38,0,

                -0.12,0.06,-0.19,0.09,-0.03,-0.19,-0.03,-0.34,

                -0.19,0.08,-0.15,0.12,0.1,-0.28,-0.05,

                -0.25,0.23,-0.1,-0.26,0.1,-0.38,

                -0.22,0.06,0.16,-0.36,0.02,

                -0.06,-0.22,0.17,-0.34,

                0.05,-0.19,-0.07,

                -0.35,-0.02,

                -0.49)

var.wei=((weight.upper-weight.lower)/3.92)^2

var.weight=matrix(rep(0,p^2),p,p,dimnames=list(antipsychotic))

var.weight[lower.tri(var.weight)]=var.wei

var.weight<-t(var.weight)

var.weight[lower.tri(var.weight)]=var.wei

###################### Example ##########################################

efficacy=array(efficacy,dim=c(dim(efficacy)[1],dim(efficacy)[2],1))
var.efficacy=array(var.efficacy,dim=c(dim(var.efficacy)[1],dim(var.efficacy)[2],1))

beta=seq(0,0.5,0.01)

pscores.efficacy=matrix(rep(0,length(beta)*16),length(beta),16)
pscores.efficacy2=matrix(rep(0,length(beta)*16),length(beta),16)


for (i in 1:length(beta)) {
  pscores.efficacy[i,]<-pscores(efficacy,var.efficacy,0,-beta[i],"H",antipsychotic)
  pscores.efficacy2[i,]<-pscores2(efficacy,var.efficacy,0,-beta[i],"H",antipsychotic)
}

rowMeans(pscores.efficacy)
rowMeans(pscores.efficacy2) # the mean stays 0.5

ex <- data.frame(trt = antipsychotic,
           pscore1 =pscores.efficacy[51,],
           pscore2 = pscores.efficacy2[51,])



print(xtable::xtable(ex, digits = 3), include.rownames = F)

rankings <-apply(pscores.efficacy, 1, rank)
rankings2 <- apply(pscores.efficacy2, 1, rank)


png("univariate.png", width = 10, height = 4, units = "in", res = 300)
par(mfrow = c(1,2),  mar = c(4, 4, 1, 1))

plot(0,0,ylim=c(0,1),type="l",xlim=c(-0.055,max(beta)),xlab="CIV",ylab="P-score (variable mean)", xaxt = "n")
axis(side = 1, labels = T, at = c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5))
lines(beta,pscores.efficacy[1:length(beta),1],col="red")
lines(beta,pscores.efficacy[1:length(beta),2],col="green")
lines(beta,pscores.efficacy[1:length(beta),3],col="blue")
lines(beta,pscores.efficacy[1:length(beta),4],col="purple")
lines(beta,pscores.efficacy[1:length(beta),5],col="pink")
lines(beta,pscores.efficacy[1:length(beta),6])
lines(beta,pscores.efficacy[1:length(beta),7])
lines(beta,pscores.efficacy[1:length(beta),8])
lines(beta,pscores.efficacy[1:length(beta),9])
lines(beta,pscores.efficacy[1:length(beta),10])
lines(beta,pscores.efficacy[1:length(beta),11])
lines(beta,pscores.efficacy[1:length(beta),12])
lines(beta,pscores.efficacy[1:length(beta),13])
lines(beta,pscores.efficacy[1:length(beta),14])
lines(beta,pscores.efficacy[1:length(beta),15])
lines(beta,pscores.efficacy[1:length(beta),16], col = "orange")
lines(beta,rowMeans(pscores.efficacy),type='b')
text(x = -0.04, y = c(pscores.efficacy2[1, 1:5], 0.5, pscores.efficacy[1, 16]), labels = c(antipsychotic[1:5], "mean", antipsychotic[16]))


plot(0,0,ylim=c(0,1),type="l",xlim=c(-0.055,max(beta)),xlab="CIV",ylab="P-score (fixed mean)", xaxt = "n")
axis(side = 1, labels = T, at = c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5))
lines(beta,pscores.efficacy2[1:length(beta),1],col="red")
lines(beta,pscores.efficacy2[1:length(beta),2],col="green")
lines(beta,pscores.efficacy2[1:length(beta),3],col="blue")
lines(beta,pscores.efficacy2[1:length(beta),4],col="purple")
lines(beta,pscores.efficacy2[1:length(beta),5],col="pink")
lines(beta,pscores.efficacy2[1:length(beta),6])
lines(beta,pscores.efficacy2[1:length(beta),7])
lines(beta,pscores.efficacy2[1:length(beta),8])
lines(beta,pscores.efficacy2[1:length(beta),9])
lines(beta,pscores.efficacy2[1:length(beta),10])
lines(beta,pscores.efficacy2[1:length(beta),11])
lines(beta,pscores.efficacy2[1:length(beta),12])
lines(beta,pscores.efficacy2[1:length(beta),13])
lines(beta,pscores.efficacy2[1:length(beta),14])
lines(beta,pscores.efficacy2[1:length(beta),15])
lines(beta,pscores.efficacy2[1:length(beta),16], col = "orange")
lines(beta,rowMeans(pscores.efficacy2),type='b')

text(x = -0.04, y = c(pscores.efficacy2[1, 1:5], 0.5, pscores.efficacy[1, 16]), labels = c(antipsychotic[1:5], "mean", antipsychotic[16]))

dev.off()
# Calculating multivariate P-scores ----------------------------------------------------------

k=2

outcomes<-array(rep(0,p^2*k),c(p,p,k))

outcomes[,,1]<-efficacy
outcomes[,,2]<-weight

var.outcomes<-array(rep(0,p^2*k),c(p,p,k))
var.outcomes[,,1]<-var.efficacy
var.outcomes[,,2]<-var.weight


correlation=matrix(c(1,-0.5,-0.5,1),2,2)

gamma=seq(0,-1,-0.01)
pscores.weight=matrix(rep(0,length(gamma)*16),length(gamma),16)
pscores.weight2=matrix(rep(0,length(gamma)*16),length(gamma),16)

for (i in 1:length(gamma)) {
  pscores.weight[i,]<-pscores(outcomes,var.outcomes,correlation,beta=c(0,-gamma[i]),type=c("H","H"),antipsychotic)
  pscores.weight2[i,]<-pscores2(outcomes,var.outcomes,correlation,beta=c(0,-gamma[i]),type=c("H","H"),antipsychotic)
}

rowMeans(pscores.weight) # when gamma is zero the mean is not 0.5 for either approach...
rowMeans(pscores.weight2)

par(mfrow = c(1,2))

plot(0,0,ylim=c(0,1),type="l",xlim = range(gamma),ylab="p-score (variable mean)",xlab="CIV",main="")
lines(gamma,pscores.weight[1:length(gamma),1],col="red")
lines(gamma,pscores.weight[1:length(gamma),2],col="green")
lines(gamma,pscores.weight[1:length(gamma),3],col="blue")
lines(gamma,pscores.weight[1:length(gamma),4],col="purple")
lines(gamma,pscores.weight[1:length(gamma),5],col="pink")
lines(gamma,pscores.weight[1:length(gamma),6])
lines(gamma,pscores.weight[1:length(gamma),7])
lines(gamma,pscores.weight[1:length(gamma),8])
lines(gamma,pscores.weight[1:length(gamma),9])
lines(gamma,pscores.weight[1:length(gamma),10])
lines(gamma,pscores.weight[1:length(gamma),11])
lines(gamma,pscores.weight[1:length(gamma),12])
lines(gamma,pscores.weight[1:length(gamma),13])
lines(gamma,pscores.weight[1:length(gamma),14])
lines(gamma,pscores.weight[1:length(gamma),15])
lines(gamma,pscores.weight[1:length(gamma),16])
lines(gamma,rowMeans(pscores.weight),type='b')

plot(0,0,ylim=c(0,1),type="l",xlim=range(gamma),ylab="p-score (fixed mean)",xlab="CIV",main="")
lines(gamma,pscores.weight2[1:length(gamma),1],col="red")
lines(gamma,pscores.weight2[1:length(gamma),2],col="green")
lines(gamma,pscores.weight2[1:length(gamma),3],col="blue")
lines(gamma,pscores.weight2[1:length(gamma),4],col="purple")
lines(gamma,pscores.weight2[1:length(gamma),5],col="pink")
lines(gamma,pscores.weight2[1:length(gamma),6])
lines(gamma,pscores.weight2[1:length(gamma),7])
lines(gamma,pscores.weight2[1:length(gamma),8])
lines(gamma,pscores.weight2[1:length(gamma),9])
lines(gamma,pscores.weight2[1:length(gamma),10])
lines(gamma,pscores.weight2[1:length(gamma),11])
lines(gamma,pscores.weight2[1:length(gamma),12])
lines(gamma,pscores.weight2[1:length(gamma),13])
lines(gamma,pscores.weight2[1:length(gamma),14])
lines(gamma,pscores.weight2[1:length(gamma),15])
lines(gamma,pscores.weight2[1:length(gamma),16])
lines(gamma,rowMeans(pscores.weight2),type='b')

# Showing that the condition does not hold in general ----------------------------------------
aij <- c(1,-1)
aji <- -aij

rho <- 0.5
cormat <- matrix(c(1, rho, rho, 1), nrow = 2)

# For univariate case 0 they are equal
pnorm(aij[1])
1-pnorm(aji[1])

# For multivariate case - not equal
pmvnorm(lower = rep(-Inf, length(aij)), upper = aij, corr =cormat)[1]
1-pmvnorm(lower = rep(-Inf, length(aij)), upper = aji, corr =cormat)[1]



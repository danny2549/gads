
# Load the data
tui <- read.csv('../data/FSE-TUI1_X.csv')

colnames(tui)
# plot Closing Price
plot(tui$Close, type='l', main='TUI Close', lwd=1, col='red', ylab='closing')

# plot log
plot(log(tui$Close), type='l', main='TUI Close', lwd=1, col='red', ylab='closing')

# plot diff of the Log of the closing price
plot(diff(log(tui$Close))), type='l', main='TUI Close', lwd=1, col='red', ylab='closing')

hist( diff(log(tui$Close)), breaks = 50, prob = T , ylim= c(0, 35))

lines(density(diff(log(tui$Close))))

# --------------------------------------------------------
# Compare density with Normal distribution
# --------------------------------------------------------
data <- diff(log(tui$Close))

hist( data, breaks = 50, prob = T, ylim = c(0,35))
lines(density(data), col='red', lwd = 2)

# mean and std
mu    <- mean(data)
sigma <- sd(data)

# normal distribution
x <- seq(-0.2,0.2, length=100)
y <- dnorm(x,mu,sigma)

lines(x,y,lwd=2, col='blue')

# QQ plot
qqnorm(data)
# abline(-2,2)

# Kolmogorov Smirnov test for normality (H0: normal distribution)
ks.test(data, 'pnorm', mu, sigma)
# Shapiro Wilk test for normality
shapiro.test(data)

# ------------------------------------------------------
# Moving Average : filter(data,filter = rep(1/n,n))
# ------------------------------------------------------
data <- tui$Close[1000:1500]

tui.5  <- filter(data,filter = rep(1/5,5)  )
tui.25 <- filter(data,filter = rep(1/25,25))
tui.81 <- filter(data,filter = rep(1/81,81))

tui.10  <- filter(data,filter = rep(1/10,10)  )


plot(data, type='n')
points(data, pch=16, cex=0.5)
lines(tui.5, col='red', lwd=2)
lines(tui.25, col='blue', lwd=2)
lines(tui.81, col='green', lwd=2)

# -------------------------------------------------------
# Decomposition with stl
# Beer production in Australia
# https://datamarket.com/data/set/22xr/monthly-beer-production-in-australia-megalitres-includes-ale-and-stout-does-not-include-beverages-with-alcohol-percentage-less-than-115-jan-1956-aug-1995#!ds=22xr&display=line
# -------------------------------------------------------

df <- read.csv('../data/monthly-beer-production-in-austr.csv')

head(df)
dim(df)
# transform the df into a time series
# you have to give it the seasonality periodicity!
beer <- ts(df$production, freq=12)

# Decompose
res <- stl(beer, s.window='periodic')
plot(stl(beer, s.window='periodic'))

# Find periodicity, Yearly means 12
# install.packages('xts')
library(xts)
periodicity(ts(df$production))

# ---------------------------------------------------------------------------
# Exponential Smoothing with Holt Winters
# Holt Winters: Extension of exponential smoothing to trends and seasonality
# ---------------------------------------------------------------------------

?HoltWinters
beer.hw <-  HoltWinters(beer)
beer.hw$fitted[1:10,]

plot(beer.hw)
# Predict next 12 values
predict(beer.hw, n.ahead=12)

plot(beer, xlim=c(1, 50))
lines(predict(beer.hw, n.ahead=96), col='blue')

# ---------------------------------------------------------------------------
# ARIMA Models
# ---------------------------------------------------------------------------

# simulate 

# Simulate an AR(3) with coeffs [0.2,0.3, 0.4]
sim.ar <- arima.sim( list( ar=c(0.2,0.3, 0.4)), n = 1000 )
par(mfrow=c(2,1))
acf(sim.ar, main="ACF of AR(3)")
pacf(sim.ar, main="ACF of AR(3)")



# Simulate an MA(2) with coeffs [0.6, -0.4, 0.2]
sim.ma <- arima.sim(list( ma=c(0.3, -0.4, 0.2)  ), n = 1000)

# 2 by 2 plots of ACF and PACF
par(mfrow=c(2,1))
acf(sim.ma, main="ACF of MA(2)")
pacf(sim.ma, main="PACF of MA(2)")
# PACF
pacf(sim.ar, main="PACF of AR(2)")
pacf(sim.ma, main="PACF of MA(2)")

# Change the order of the models and look at the ACF and PACF

par(mfrow=c(2,1))
acf(beer, main='autocorrelation of beer ts')
pacf(beer, main='partial autocorrelation of beer ts')

# ---------------------------------------------------------------------------
# ARIMA modeling of the Lake Huron Dataset
# ---------------------------------------------------------------------------

data(LakeHuron)
par(mfrow=c(1,1))
plot(LakeHuron)

par(mfrow=c(2,1))
acf(LakeHuron, main="ACF of LakeHuron")
pacf(LakeHuron, main="PACF of LakeHuron")

fit.ar1 <- arima(LakeHuron, order = c(1,0,0))
fit.ar1
par(mfrow=c(1,1))
plot(fit.ar1$residuals, main="Residuals of ARIMA (1,0,0)")
# Are the residuals random or is there a trace of non randomness left?
tsdiag(fit.ar1)

fit.ma1 <- arima(LakeHuron, order = c(0,0,1) )
fit.arma1
par(mfrow=c(1,1))
plot(fit.arma1$residuals, main="Residuals of ARIMA (1,0,1)")
# Are the residuals random or is there a trace of non randomness left?
tsdiag(fit.arma1)

# Box-Pierce and Ljung-Box Tests
Box.test(fit.ma1$residuals, lag=1)
?Box.test

# ---------------------------------------------------------------------------
# ARIMA prediction
# ---------------------------------------------------------------------------

fit <- arima(LakeHuron, order = c(1,0,1))
# predict levels of lake Huron for 8 years
LH.pred <- predict(fit, n.ahead=8)
# compare
LakeHuron
LH.pred

plot(LakeHuron, xlim=c(1875, 1980))
lines(LH.pred$pred, col="red"  )
lines(LH.pred$pred + 2* LH.pred$se , col="red", lty=3  )
lines(LH.pred$pred - 2* LH.pred$se , col="red", lty=3  )



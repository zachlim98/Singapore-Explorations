```python
#import libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
```


```python
#import datasets
dataset = pd.read_csv('suicide_rate.csv')
X = pd.DataFrame(dataset.iloc[:, 8:])
y = dataset.iloc[:, 1].values
```


```python
plt.plot(dataset["Year"],dataset["Suicide_Rate"],color='black')
plt.xlabel('Year')
plt.ylabel('Suicide Rate')
plt.title('Suicide Rate 1990 - 2019')
```

​    
![svg](output_2_1.svg)
​    



```python
x_axis_labels = ["Rainy Days","Bright Sunshine (hr)","Marriage Rate","Visual Arts Displays","Mobile Phone Sub","Divorce Rate","Library Loans","Unemployment Rate","Suicide Rate"]
```


```python
sns.heatmap(X.assign(target = y).corr().round(2), cmap = 'Reds', annot = True, fmt=".2f", xticklabels=x_axis_labels, yticklabels=x_axis_labels).set_title('Correlation matrix', fontsize = 16)
```


​    
![svg](output_4_1.svg)
​    



```python
from sklearn.model_selection import train_test_split
X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size = 0.4, random_state = 42)
```


```python
from sklearn.ensemble import RandomForestRegressor
regressor = RandomForestRegressor(n_estimators = 100, random_state = 42, oob_score=True)
regressor.fit(X_train, y_train)
```


```python
print('R^2 Training Score: {:.2f} \nR^2 OOB Score: {:.2f} \nR^2 Validation Score: {:.2f}'.format(regressor.score(X_train, y_train), 
                                                                                    regressor.oob_score_,
                                                                                    regressor.score(X_valid, y_valid)))
```

    R^2 Training Score: 0.76 
    R^2 OOB Score: -0.67 
    R^2 Validation Score: -0.01

```python
def imp_df(column_names, importances):
    df = pd.DataFrame({'feature': column_names,
                       'feature_importance': importances}) \
           .sort_values('feature_importance', ascending = False) \
           .reset_index(drop = True)
    return df
```


```python
fe_imp = imp_df(X_train.columns, regressor.feature_importances_)
to_labels = ["Visual Arts Displays","Mobile Phone Sub","Unemployment Rate","Bright Sunshine (hr)","Divorce Rate","Rainy Days","Marriage Rate","Library Loans"]
fe_imp.at[0:7,"feature"] = to_labels
```


```python
fe_imp.columns = ['feature', 'feature_importance']
ax = sns.barplot(x = 'feature_importance', y = 'feature', data = fe_imp, orient = 'h', color = 'red')
ax.set(xlabel="Feature Importance",ylabel="Features",title="Feature Importance")
```



```python
import statsmodels.api as sm
T = sm.add_constant(X)
model = sm.OLS(y, T).fit()
predictions = model.predict(T) 
print_model = model.summary()
print(print_model)
```

                                OLS Regression Results                            
    ==============================================================================
    Dep. Variable:                      y   R-squared:                       0.259
    Model:                            OLS   Adj. R-squared:                 -0.023
    Method:                 Least Squares   F-statistic:                    0.9177
    Date:                Tue, 03 Nov 2020   Prob (F-statistic):              0.521
    Time:                        01:11:55   Log-Likelihood:                 6.0693
    No. Observations:                  30   AIC:                             5.861
    Df Residuals:                      21   BIC:                             18.47
    Df Model:                           8                                         
    Covariance Type:            nonrobust                                         
    =========================================================================================
                                coef    std err          t      P>|t|      [0.025      0.975]
    -----------------------------------------------------------------------------------------
    const                     2.7039      2.398      1.128      0.272      -2.283       7.691
    No_Rainy_Days            -0.0029      0.003     -0.893      0.382      -0.010       0.004
    Hours_Bright_Sunshine    -0.1827      0.209     -0.876      0.391      -0.616       0.251
    Crude_Marriage_rate       0.0427      0.167      0.256      0.801      -0.304       0.390
    VA_Rate                  -2.9841      2.040     -1.463      0.158      -7.226       1.257
    MPSub_Rate                0.1135      0.239      0.475      0.640      -0.384       0.611
    Divorce_Rate              0.5460      0.621      0.879      0.389      -0.745       1.837
    LBSub_Rate                0.0763      0.391      0.195      0.847      -0.736       0.889
    Unemploy_Rate             0.0721      0.128      0.563      0.579      -0.194       0.338
    ==============================================================================
    Omnibus:                        0.063   Durbin-Watson:                   2.100
    Prob(Omnibus):                  0.969   Jarque-Bera (JB):                0.259
    Skew:                          -0.069   Prob(JB):                        0.879
    Kurtosis:                       2.566   Cond. No.                     9.77e+03
    ==============================================================================
    
    Notes:
    [1] Standard Errors assume that the covariance matrix of the errors is correctly specified.
    [2] The condition number is large, 9.77e+03. This might indicate that there are
    strong multicollinearity or other numerical problems.



```python

```

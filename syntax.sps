* Encoding: UTF-8.

*Compute frequencies for the variable “life satisfaction” and then recode it into three categories*.
FREQUENCIES VARIABLES=v39
  /STATISTICS=MEDIAN
  /BARCHART PERCENT
  /ORDER=ANALYSIS.

RECODE v39 (SYSMIS=SYSMIS) (1 thru 3=1) (4 thru 7=2) (8 thru Highest=3) INTO satisfaction3.
VARIABLE LABELS  satisfaction3 'life satisfaction in 3 categories'.
VALUE LABELS satisfaction3
1 'Low satisfaction'
2 'Medium satisfaction'
3 'High satisfaction'.
EXECUTE.

FREQUENCIES satisfaction3.


*Additive index constructed to measure justification of behaviors against the public good (dependent variable y)*.
FREQUENCIES VARIABLES=v149 v150 v152 v159
  /STATISTICS=STDDEV MEAN MEDIAN
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

COMPUTE antisocial_behavior=v149 + v150 + v152 + v159.
EXECUTE.

FREQUENCIES antisocial_behavior
 /STATISTICS=STDDEV MEAN MEDIAN
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.


*Additive index normalized to range between 0 and 1*.
*Value 0 indicates no justification of antisocial behaviors, whereas value 1 indicates full justification*.
*Therefore, 0 represents optimal behavior and 1 represents the poorest civic behavior*.
COMPUTE antisocial_behaviorN=(antisocial_behavior-4)/(31-4).
frequencies antisocial_behaviorN antisocial_behavior.

FREQUENCIES VARIABLES=antisocial_behaviorN
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.


*Cronbach’s alpha computed for the additive index, resulting in a reliability coefficient above 0.7*.
RELIABILITY
  /VARIABLES=v149 v150 v152 v159
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.


*Gender dummy variable created: value 1 (male) recoded to 0, and value 2 (female) recoded to 1*. 
FREQUENCIES VARIABLES=v225
  /PIECHART PERCENT
  /ORDER=ANALYSIS.

RECODE v225 (2=1) (SYSMIS=SYSMIS) (ELSE=0) INTO dummy_gender.
VARIABLE LABELS  dummy_gender 'dummy variable for female gender'.
VALUE LABELS dummy_gender 
   0 'Male'
   1 'Female'.
  
FREQUENCIES VARIABLES=dummy_gender.


*Trivariate analysis performed using Compare Means with gender as control variable*.
*Hypothesis tested: individuals with lower life satisfaction tend to justify antisocial behaviors more frequently*. 
*Check if higher mean scores (worse behavior) occur when life satisfaction is lower*.
*Also examine whether males tend to justify antisocial behaviors more than females*.
MEANS TABLES=antisocial_behaviorN BY satisfaction3 BY dummy_gender
  /CELLS=MEAN COUNT STDDEV.


*Education variable recoded into three categories*.
FREQUENCIES VARIABLES=v243_8cat
 /STATISTICS=MEDIAN
  /BARCHART PERCENT
  /ORDER=ANALYSIS.

RECODE v243_8cat (SYSMIS=SYSMIS) (1 thru 3=1) (4 thru 7=2) (8 thru Highest=3) INTO edu3.
VARIABLE LABELS  edu3 'education in three categories'.
VALUE LABELS edu3
    1 'Low education'
    2 'Medium education'
    3 'High education'.

FREQUENCIES VARIABLES=edu3
  /STATISTICS=MEDIAN
  /BARCHART PERCENT
  /ORDER=ANALYSIS.


*Age variable recoded into three categories*.
FREQUENCIES VARIABLES=age
  /STATISTICS=STDDEV MEAN MEDIAN
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

RECODE age (SYSMIS=SYSMIS) (18 thru 34=1) (35 thru 54=2)  (55 thru Highest=3) INTO age3.
VARIABLE LABELS  age3 'age in three categories'.
VALUE LABELS age3
   1 '18-34'
   2 '35-54'
   3 '55+'.

FREQUENCIES VARIABLES=age3
  /STATISTICS=MEDIAN
  /BARCHART PERCENT
  /ORDER=ANALYSIS.


*Dummy variable created for medium education level*.
RECODE edu3 (2=1) (SYSMIS=SYSMIS) (ELSE=0) INTO edu_medium.
VARIABLE LABELS  edu_medium 'Medium education'.
EXECUTE.

FREQUENCIES edu_medium.


*Dummy variable created for high education level*.
RECODE edu3 (3=1) (SYSMIS=SYSMIS) (ELSE=0) INTO edu_high.
VARIABLE LABELS  edu_high 'High education'.
EXECUTE.

FREQUENCIES edu_high.


*Model 1 is a simple bivariate regression*.
*Model 2 includes a multivariate regression*.
*Independent variable (X): life satisfaction*.
*Dependent variable (Y): normalized antisocial behavior*.
*Control variables: education, gender, and political orientation (from left to right)*.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10) TOLERANCE(.0001)
  /NOORIGIN 
  /DEPENDENT antisocial_behaviorN
  /METHOD=ENTER v39
  /METHOD=ENTER edu_medium edu_high dummy_gender v102.


*To perform a trivariate analysis with categorical variables, the dependent variable (Y) is recoded into three categories*.
*The distribution of the dependent variable is skewed, since most respondents do not justify behaviors against the public good*. 
*Arbitrary thresholds are therefore applied following the variable’s asymmetric distribution to avoid small cell counts in the contingency table*.
FREQUENCIES VARIABLES=antisocial_behaviorN
  /STATISTICS=STDDEV MEAN MEDIAN
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

RECODE antisocial_behaviorN (SYSMIS=SYSMIS) (0.00 thru 0.11=1) (0.15 thru 0.41=2) (0.44 thru Highest=3) INTO antisocial_behaviorN3.
VARIABLE LABELS  antisocial_behaviorN3 'antisocial_behaviorN (normalized antisocial behavior) in three categories'.
VALUE LABELS antisocial_behaviorN3
1 'Good behavior'
2 'Moderate behavior'
3 'Poor behavior'.
EXECUTE.

FREQUENCIES VARIABLES=antisocial_behaviorN3
  /STATISTICS=MEDIAN
  /BARCHART PERCENT
  /ORDER=ANALYSIS.


*Trivariate analysis performed with categorical variables*.
*Using the gender dummy variable, assess differences between male and female groups*.
*Test whether the relationship between X and Y has a stronger effect among women than among men*.
*Compute Cramer’s V to evaluate the strength of the relationship, checking the p-value for statistical significance*.
CROSSTABS
  /TABLES=antisocial_behaviorN3 BY satisfaction3 BY dummy_gender
  /FORMAT=AVALUE TABLES
  /STATISTICS=PHI 
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.











# UK Productivity Analysis

###### <i> This project was done using data from a provider who wished to remain confidental in regards to any analysis. The project was completed and results presented before all information relating to the provider was stripped from all documentation and all files were copied to a new repo. </i>

Productivity is key to the development of local businesses and the wider economy. Over the past decade, productivity has slowed down globally with the UK lagging behind some other developed economies.


“<b><i>Productivity</b> is commonly defined as a ratio between the output volume and the volume of inputs. In other words, it measures how efficiently production inputs, such as labour and capital, are being used in an economy to produce a given level of output.”</i> - OECD


Our main business question is generally: How can we improve productivity within Scotland and the UK overall?

Some targeted questions we are interested in for this specific project:

• Does government spending on factors such as mental health, education, and research and development affect productivity in the UK?<br>
• Is there a relationship between government investment and productivity?<br>
• Can you predict productivity based on investment?<br>

All cleaning scripts, analysis, figures and final presentation is included in this repo.

## Approach
Data for this project came from the Equifax Ignite Direct data platform which hosts over 50 open data sources. The data needed cleaned and narrowed down appropriately. All data was given as .csv or excel files. Due to the large volume of data given and the short time frame of the project (a presentation had to be given to the client in 2 weeks), time was needed to sort through the data and decide what files were useful to answer the business questions.

Following this, all data was cleansed and combined where possible. This was to allow analysis to be easier to carry out. Time was then taken to undergo this detailed analysis and format the findings in a presentation format. 

### Findings
All main project findings can be found in the .pdf presentation file included in this project. Below are a couple of graphs created during this to give an idea analysis carried out:

#### Further Education vs Productivity 
![Further Education vs Productivity](https://github.com/TICbhoy94/uk_productivity_analysis/blob/main/presentation/further_education_vs_productivity_uk.png)

From the above graph we see a positive relationship between further education and productivity. This makes sense: the more skilled and educated your workforce, the more likely they'll produce more.

#### Cross Country Infrastructure Investment
![Cross Country Infrastructure Investment](https://github.com/TICbhoy94/uk_productivity_analysis/blob/main/presentation/cross_country_infrastructure_investment_graph.png)

In the above graph the producitivity of the UK is compared against the top 5 most productive nations in reference to each countries' investment into infrastructure. Infrastructure includes investment in railway networks, roads, etc. It is clear to see that there is a postive relationship between productivity and infrastructure investment.

#### Modeling

The brief asked if productivity could be predicted. Two models were developed in an attempt to acheived this: A multi-variable linear regression model and a logistic regression model. Both models produced what looked to be promising results however at closer examination into the properties of the models, neither was suitable as a predictor of the productivity. The main issue was the lack of coherent data. This lead to poor statistical significance values for variables and therefore confidence in the models was low.

### Conclusions

• Productivity is a complex, multi-variable equation with many different elements at play however a basic understanding of how productivity can be improved was acheived. It is clear that government spending on factors such as education, infrastructure and research & development does affect productivity <br>
• Based on the data sources to date, an understanding of investment in mental health services and productivity hasn’t been realised <br>
• Productivity has not been successfully modelled to a satisfactory level in this project although it is believed to be achievable <br> 

### Next steps
• Explore regional data for the UK, specifically Scotland as per the breif. It would be interesting to understand why areas like London are highly productive compared to other areas in the UK (although it will be mostly due to the strength of the financial sector in London, if you were to adjust for this and then compare other factors such as health and education investment) <br>
• Explore additional factors in greater granularity (financial data, commuting data, ease of doing business data, etc.). Time restrictions prevented this from occuring<br>
• Compare more data from different countries and identify shortcomings in our growth strategies. Why are countries like Luxembourg and Norway more productive than the UK? <br>
Investigate the effect mental health has on productivity in more detail. The data provided for this project was limited so more would be required to get a true understanding of mental health and productivity <br>
More feature engineering and model refinement


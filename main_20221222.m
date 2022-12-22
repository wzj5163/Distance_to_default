%% calculate distance 2 default for huanhuan
clear,clc
addpath("data\")
addpath("new_codes\")
raw_data=readtable('st_debt.csv');
% delete NaN data
raw_data1=raw_data(~isnan(raw_data.Close_price) & ~isnan(raw_data.outstandingshares) & (~isnan(raw_data.short_debt) | ~isnan(raw_data.long_debt)),:);
% need only stock_index, market_value & debt
Stock_inx=raw_data1.sktcode;
Market_value=raw_data1.Close_price.*raw_data1.outstandingshares;
Debt=sum([raw_data1.short_debt,0.5*raw_data1.long_debt],2,'omitnan');

Data = table(Stock_inx,Market_value, Debt,'VariableNames',{'Stock_inx','Market_value', 'Debt'});

% output D2D
[SIGMA, DtDSet, ValueSet] = Distance_to_Default(Data,1,0.01);
Data_new=Data;
Data_new.Sigma=SIGMA;Data_new.D2D=DtDSet;Data_new.Asset_value=ValueSet;
Data_new.trade_date=raw_data1.trade_date;
Data_new.trade_date=raw_data1.trade_date;
Data_new.year=raw_data1.year;

% to check if there exists NaN
sum(isnan(SIGMA)) 
% write table
writetable(Data_new,"D2D.csv")








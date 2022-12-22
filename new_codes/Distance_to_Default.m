% calculate distance 2 default
%
% refer to Duffie, D., Saita, L., & Wang, K. (2007). Multi-period corporate default prediction with stochastic covariates. Journal of Financial Economics

function [SIGMA, DtDSet, ValueSet] = Distance_to_Default(Data,T,r)

% global n N
% W = Data.Market_value;
% L = Data.Debt;

n = size(Data,1);
stock_inx = unique(Data.Stock_inx);
N = length(stock_inx);

ValueSet = zeros(n,1); % Collect asset
DtDSet = zeros(n,1);   % collect distance te default
SIGMA =zeros(n,1);     % collect sigma
if nargin < 2
    T = 1;                 % time is one year
    r = 0.1;               % risk-free rate
elseif nargin < 3
    r = 0.1;               % risk-free rate
end


for ii = 1: N

    inx=find(Data.Stock_inx==stock_inx(ii));
    Data_1=Data(inx,:);

    m = size(Data_1,1); %每个公司的数据量
    V0 = Data_1.Market_value + Data_1.Debt;% Given initial value
    %     V_new=[]; % Get new value
    Data_2 = [V0 Data_1.Market_value Data_1.Debt];
    Error = 1000;
    TIMES = 0;

    while Error > 0.001

        %%%%%%%%  Calculate sigma
        ii
        TIMES = TIMES + 1;
        if TIMES > 1000
            break
        end



        sigma = std(log(V0(2:end))-log(V0(1:end-1)));


        %%%%%%%% Calculate d1 & d2
        %         d1 = [];
        %         d2 = [];
        %         for i = 1:m
        %             d1(i) = (log( abs( Data_1(i,1) / Data_1(i,3) ) )+(r+.5*sigma^2)*T)/sigma/T^(.5);
        %         end
        d1 = (log( abs( Data_2(:,1) ./ Data_2(:,3) ) )+(r+.5*sigma^2)*T)/sigma/T^(.5);
        d2 = d1-sigma*T^(.5);
        Norm_d1 = normcdf(d1);
        Norm_d2 = normcdf(d2);

        %%%%%%% Calculate a new value
        for i = 1:m
            if Norm_d1(i) == 0
                Norm_d1(i) = 0.001;
            end
            if Norm_d2(i) == 0
                Norm_d2(i) = 0.001;
            end

        end
        V_new = (Data_2(:,2)+Data_2(:,3)*exp(-r*T).*Norm_d2)./Norm_d1;

        if size(V_new,2) ~= 1
            V_new = V_new';
        end
        %%%%%%%
        Error = max(abs(V_new-V0));
        V0 = V_new;
        Data_2(:,1) = V_new;

    end



    % V0 is the assets' value

    %%%%%%%%%%%%%%%%%%%%%% Calculate distance to default
    sigma = std(log(V0(2:end))-log(V0(1:end-1)));
    mu = mean(log(V0(2:end))-log(V0(1:end-1)));
    DTD = (log(Data_2(:,1)./Data_2(:,3))+(mu-.5*sigma^2)*T)/sigma/T^(.5);

    if size(DTD,2) ~= 1
        DTD = DTD';
    end

    ValueSet(inx) = V0 ;
    DtDSet(inx) = DTD ;
    SIGMA(inx) = sigma ;


end
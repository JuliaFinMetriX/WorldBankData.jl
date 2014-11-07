module TestWDISearchWDI

using Base.Test
using WorldBankDataTd
using Dates

country_data = { { "total"=>4,"per_page"=>"25000","pages"=>1,"page"=>1 },
                 {
                    ["latitude"=>"42.5075","id"=>"AND","iso2Code"=>"AD","incomeLevel"=>["id"=>"NOC","value"=>"High income: nonOECD"],"adminregion"=>["id"=>"","value"=>""],"lendingType"=>["id"=>"LNX","value"=>"Not classified"],"region"=>["id"=>"ECS","value"=>"Europe & Central Asia (all income levels)"],"capitalCity"=>"Andorra la Vella","name"=>"Andorra","longitude"=>"1.5218"],
                    ["latitude"=>"","id"=>"ARB","iso2Code"=>"1A","incomeLevel"=>["id"=>"NA","value"=>"Aggregates"],"adminregion"=>["id"=>"","value"=>""],"lendingType"=>["id"=>"","value"=>"Aggregates"],"region"=>["id"=>"NA","value"=>"Aggregates"],"capitalCity"=>"","name"=>"Arab World","longitude"=>""],
                    ["latitude"=>"24.4764","id"=>"ARE","iso2Code"=>"AE","incomeLevel"=>["id"=>"NOC","value"=>"High income: nonOECD"],"adminregion"=>["id"=>"","value"=>""],"lendingType"=>["id"=>"LNX","value"=>"Not classified"],"region"=>["id"=>"MEA","value"=>"Middle East & North Africa (all income levels)"],"capitalCity"=>"Abu Dhabi","name"=>"United Arab Emirates","longitude"=>"54.3705"],
                    ["latitude"=>"-34.6118","id"=>"ARG","iso2Code"=>"AR","incomeLevel"=>["id"=>"UMC","value"=>"Upper middle income"],"adminregion"=>["id"=>"LAC","value"=>"Latin America & Caribbean (developing only)"],"lendingType"=>["id"=>"IBD","value"=>"IBRD"],"region"=>["id"=>"LCN","value"=>"Latin America & Caribbean (all income levels)"],"capitalCity"=>"Buenos Aires","name"=>"Argentina","longitude"=>"-58.4173"]
                 }
               }
df_country = WorldBankDataTd.parse_country(country_data)

indicator_data = { { "total"=>5,"per_page"=>"25000","pages"=>1,"page"=>1 },
                   { ["sourceOrganization"=>"World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ","id"=>"12.1_TD.LOSSES","topics"=>{},"sourceNote"=>"Transmission and distribution losses (%): Transmission and distribution (T&D) losses measure power lost in the transmission of (high-voltage) electricity from power generators to distributors and in the distribution of (medium- and low-voltage) electricity from distributors to end-users. T&D losses are represented as a percentage of gross electricity production. They include both technical and nontechnical (or commercial) losses. Included in the latter are unmetered, unbilled, and unpaid electricity, including theft, which could be significant in developing countries. Aggregate T&D system indicators may be dominated by factors other than losses. The location of primary energy resources (such as hydro lakes and coal seams) and large loads (cities and industries) may be more significant factors in T&D efficiency indicators than the losses or efficiency of the transmission system itself. Properly separating true losses (and hence the efficiency potential of transmission systems) from exogenous location and scale factors and nontechnical losses would require detailed studies of system-dynamic interactions and real operating requirements that are not practical for global tracking purposes.","name"=>"Transmission and distribution losses (%)","source"=>["id"=>"35","value"=>"Sustainable Energy for All"]],
                     ["sourceOrganization"=>"World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ","id"=>"13.1_INDUSTRY.ENERGY.INTENSITY","topics"=>{},"sourceNote"=>"Energy intensity of industrial sector (MJ/\$2005):  A ratio between energy consumption in industry (including energy industry own use) and industry sector value added measured at purchasing power parity. Energy intensity is an indication of how much energy is used to produce one unit of economic output. Lower ratio indicates that less energy is used to produce one unit of output. ","name"=>"Energy intensity of industrial sector (MJ/\$2005)","source"=>["id"=>"35","value"=>"Sustainable Energy for All"]],
                     ["sourceOrganization"=>"World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ","id"=>"14.1_AGR.ENERGY.INTENSITY","topics"=>{},"sourceNote"=>"Energy intensity of agricultural sector (MJ/\$2005):  A ratio between energy consumption in agricultural sector (including forestry and fishing) and agricultural sector value added measured at purchasing power parity. Energy intensity is an indication of how much energy is used to produce one unit of economic output. Lower ratio indicates that less energy is used to produce one unit of output. ","name"=>"Energy intensity of agricultural sector (MJ/\$2005)","source"=>["id"=>"35","value"=>"Sustainable Energy for All"]],
                     ["sourceOrganization"=>"World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ","id"=>"15.1_OTHER.SECT.ENER.INTENS","topics"=>{},"sourceNote"=>"Energy intensity of other sectors (MJ/\$2005): A ratio between energy consumption in other sectors (including services, residential and transport) and services sector value added measured at purchasing power parity. Energy intensity is an indication of how much energy is used to produce one unit of economic output. Lower ratio indicates that less energy is used to produce one unit of output. ","name"=>"Energy intensity of other sectors (MJ/\$2005)","source"=>["id"=>"35","value"=>"Sustainable Energy for All"]],
                     ["sourceOrganization"=>"World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ","id"=>"16.1_DECOMP.EFFICIENCY.IND","topics"=>{},"sourceNote"=>"The Index is created from the series of year to year Energy Intensity component of the Decomposition Analysis with the DIVISIA LMDI I method. The Significant Period is defined as the period for which the available data is consistent in the energy and value added databases such that all the sectors have energy and value added for those years. The CAGR is calculated over that Significant Period.","name"=>"Divisia Decomposition Analysis - Energy Intensity component Index","source"=>["id"=>"35","value"=>"Sustainable Energy for All"]]
                   }
                 }

df_indicator = WorldBankDataTd.parse_indicator(indicator_data)

WorldBankDataTd.set_country_cache(df_country)

@test search_wdi("countries",:name,r"(Andorr|Arg)"i)[:capital] ==  UTF8String["Andorra la Vella", "Buenos Aires"]
@test search_wdi("countries",:capital,r"(Andorr|Abu)"i)[:iso2c] ==  ASCIIString["AD", "AE"]

WorldBankDataTd.set_indicator_cache(df_indicator)

@test search_wdi("indicators",:description,r"energy intensity of"i)[:name] == UTF8String["Energy intensity of industrial sector (MJ/\$2005)", "Energy intensity of agricultural sector (MJ/\$2005)", "Energy intensity of other sectors (MJ/\$2005)"]
@test search_wdi("indicators",:description,r"transmiss"i)[:indicator] == ASCIIString["12.1_TD.LOSSES"]

end

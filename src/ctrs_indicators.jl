function get_countries()
    if country_cache == false
        set_country_cache(download_countries())
    end
    country_cache
end

function get_indicators()
    if indicator_cache == false
        set_indicator_cache(download_indicators())
    end
    indicator_cache
end

function parse_indicator(json::Array{Any,1})
    indicator = ASCIIString[]
    name = UTF8String[]
    description = UTF8String[]
    source_database = UTF8String[]
    source_databaseId = Int[]
    source_organization = UTF8String[]

    for d in json[2]
        append!(indicator,[d["id"]])
        append!(name,[d["name"]])
        append!(description,[d["sourceNote"]])
        append!(source_database, [d["source"]["value"]])
        push!(source_databaseId, int(d["source"]["id"]))
        append!(source_organization, [d["sourceOrganization"]])
    end

    DataFrame(indicator = indicator, name = name,
              description = description,
              source_database = source_database,
              source_databaseId = source_databaseId,
              source_organization = source_organization)
end

function parse_country(json::Array{Any,1})

    ## never missing
    iso3c = ASCIIString[] # no NAs
    iso2c = ASCIIString[] # no NAs
    name = UTF8String[] # no NAs
    
    capital = DataArray(UTF8String, 0)
    region = DataArray(UTF8String, 0)               # make DataArray? aggr. 
    regionId = DataArray(UTF8String, 0)             # make DataArray -> "NA"
    income = DataArray(UTF8String, 0)               # make DataArray? aggr.
    incomeId = DataArray(UTF8String, 0)             # make DataArray
    lending = DataArray(UTF8String, 0)              # make DataArray? aggr.
    lendingId = DataArray(UTF8String, 0)            # make DataArray

    longitude = DataArray(Float64, 0)            # make it DataArray(Float)
    latitude = DataArray(Float64, 0)             # make it DataArray(Float)
    
    for d in json[2]
        ## never missing values
        append!(iso3c,[d["id"]])
        append!(iso2c,[d["iso2Code"]])
        append!(name,[d["name"]])

        ## append for DataArrays? "" and "NA" to NA
        clean_and_push!(capital,d["capitalCity"])
        clean_and_push!(region,d["region"]["value"])
        clean_and_push!(income,d["incomeLevel"]["value"])
        clean_and_push!(lending,d["lendingType"]["value"])
        clean_and_push!(regionId,d["region"]["id"])
        clean_and_push!(incomeId,d["incomeLevel"]["id"])
        clean_and_push!(lendingId,d["lendingType"]["id"])

        ## numeric values or Void -> NA
        push!(longitude, tofloat(d["longitude"]))
        push!(latitude, tofloat(d["latitude"]))
    end

    ## longitude = [tofloat(i) for i in longitude] # comprehension forces
                                        # NA to NaN if convert(Float,
                                        # NA) is defined
    ## latitude = [tofloat(i) for i in latitude]

    DataFrame(iso3c = iso3c, iso2c = iso2c, name = name,
              region = region, regionId = regionId,
              capital = capital, longitude = longitude,
              latitude = latitude, income = income,
              incomeId = incomeId, lending = lending,
              lendingId = lendingId)
end

function download_indicators()
    dat = download_parse_json("http://api.worldbank.org/indicators?per_page=25000&format=json")

    parse_indicator(dat)
end

function download_countries()
    dat = download_parse_json("http://api.worldbank.org/countries/all?per_page=25000&format=json")

    parse_country(dat)
end

country_cache = false
indicator_cache = false

function set_country_cache(df::AbstractDataFrame)
    global country_cache = df
    if any(isna(country_cache[:iso2c])) # the iso2c code for North Africa is NA
        country_cache[:iso2c][convert(DataArray{Bool,1}, isna(country_cache[:iso2c]))]="NA"
    end
end

function set_indicator_cache(df::AbstractDataFrame)
    global indicator_cache = df
end


using GeoMakie
using GeoStatsBase

# Download the flight data and read it as a dataframe
using HTTP
using CSV

url = "https://opensky-network.org/datasets/metadata/doc8643.csv"
response = HTTP.get(url)
data = CSV.read(IOBuffer(response.body));

# Filter the dataframe to include only flights in the past 24 hours
df = data[(time() - data[:, :last_update_time] .< 24 * 3600), :]

# Create a Makie Scene
scene = Scene(resolution = (800, 600))

# Create a layer for the global map
layer = maplayer()

# Add the map layer to the scene
scene[1] = layer

# Define the initial projection of the scene
proj = Geographic()

# Define the latitudes and longitudes of the flight paths
latitudes = Vector{Float32}()
longitudes = Vector{Float32}()
for row in eachrow(df)
    push!(latitudes, row.latitude)
    push!(longitudes, row.longitude)
end

# Create a Geostats data object for the flight paths
data = GeoData(longitudes, latitudes)
geo_data = GeoDataFrame(data)

# Define the visualization parameters for the flight paths
visual_params = visualparameters(color = RGBA(1, 0, 0, 0.5), linewidth = 1)

# Create a Makie layer for the flight paths
layer = linegeo(geo_data, proj, visual_params)

# Add the flight path layer to the scene
scene[2] = layer

# Show the scene
display(scene)
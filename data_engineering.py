import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

cwd= os.getcwd()

def process_data(filepath):
    raw_player_counts = pd.read_csv(filepath)

    # drop entries which have no playercount info
    player_counts = raw_player_counts.dropna(subset=["Playercount"])
    # convert times to datetime objects
    player_counts["Time"] = pd.to_datetime(player_counts["Time"])

    # groupby creates a lazy object - not a dataframe. Must apply mean() aggregation onto it to get a dataframe.
    # set as_index to False to prevent "Time" becoming an index
    avg_players = player_counts.groupby("Time", as_index=False).mean()

def plot_playercounts(player_counts, window_size):
    plt.plot(avg_players["Time"].iloc[:window_size], avg_players["Playercount"][:window_size])
    plt.show()
    
# the span determines roughly how far back the exponential moving average looks 
# - for larger values it takes into account values farther in the past
ema = avg_players["Playercount"].ewm(span=14).mean()
# also check the standard moving average for comparison
roa = avg_players["Playercount"].rolling(window=8).mean()

plt.plot(avg_players["Time"].iloc[:window_size], avg_players["Playercount"][:window_size], label='raw data', alpha=0.4)
plt.plot(avg_players["Time"].iloc[:window_size], ema.iloc[:window_size], label='exponential moving average')
plt.plot(avg_players["Time"].iloc[:window_size], roa.iloc[:window_size], label='rolling average')
plt.legend()
plt.show()
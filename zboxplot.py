import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Mean ± std values from your LaTeX table (ms)
latency_table = {
    "Task Plan": {
        "STT": (1020, 150),
        "Intent": (45, 10),
        "Agent": (1120, 210),
        "DB": (15, 5),
        "TTS": (0, 0),
    },
    "Scene Query": {
        "STT": (1020, 150),
        "Intent": (45, 10),
        "Agent": (850, 120),
        "DB": (10, 5),
        "TTS": (350, 50),
    },
}

# ---------- BAR CHART WITH ERROR BARS ----------
stages = ["STT", "Intent", "Agent", "DB", "TTS"]
agents = list(latency_table.keys())

x = np.arange(len(stages))  # stage positions
width = 0.35  # bar width

fig, ax = plt.subplots(figsize=(8, 6))
for i, agent in enumerate(agents):
    means = [latency_table[agent][s][0] for s in stages]
    stds = [latency_table[agent][s][1] for s in stages]
    ax.bar(x + i * width, means, width, yerr=stds, label=agent, capsize=5)

ax.set_xticks(x + width / 2)
ax.set_xticklabels(stages)
ax.set_ylabel("Latency (ms)")
ax.set_title("Latency per Processing Stage (mean ± std)")
ax.legend()
plt.grid(axis="y", linestyle="--", alpha=0.7)
plt.tight_layout()
plt.savefig("latency_bar_error.png", dpi=300)
plt.show()

# ---------- STACKED BAR CHART (percent contribution) ----------
avg_contrib = {
    agent: {stage: latency_table[agent][stage][0] for stage in stages}
    for agent in agents
}
df = pd.DataFrame(avg_contrib).T
df_percent = df.div(df.sum(axis=1), axis=0) * 100

df_percent.plot(kind="bar", stacked=True, figsize=(8, 6), colormap="tab20c")
plt.ylabel("Percentage Contribution (%)")
plt.title("Relative Contribution of Latency Components")
plt.legend(title="Stage", bbox_to_anchor=(1.05, 1), loc="upper left")
plt.grid(axis="y", linestyle="--", alpha=0.7)
plt.tight_layout()
plt.savefig("latency_stacked_percent.png", dpi=300)
plt.show()

import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import savgol_filter
import numpy as np


def plot_freq(filename, title):
    # === Загрузка ===
    df = pd.read_csv(filename)

    # === Очистка данных ===
    df["TIME(ns)"] = pd.to_numeric(df["TIME(ns)"], errors="coerce")
    df["FREQ(Hz)"] = pd.to_numeric(df["FREQ(Hz)"], errors="coerce")

    df = df.dropna().reset_index(drop=True)
    df = df[df["FREQ(Hz)"] != 0]
    df = df[np.isfinite(df["FREQ(Hz)"])]

    # === Средняя частота после 200000000 ns ===
    df_mean_section = df[df["TIME(ns)"] > 200000000]
    mean_freq = df_mean_section["FREQ(Hz)"].mean()

    # Если участок пустой — взять среднее по всему графику
    if np.isnan(mean_freq):
        mean_freq = df["FREQ(Hz)"].mean()

    # === Сглаживание Savitzky–Golay ===
    window_size = 101
    poly_order = 3

    if window_size >= len(df):
        window_size = len(df) // 2 * 2 + 1
        if window_size < 5:
            window_size = 5

    df["FREQ_smooth"] = savgol_filter(
        df["FREQ(Hz)"],
        window_length=window_size,
        polyorder=poly_order
    )

    # === График ===
    plt.figure(figsize=(14, 6))

    plt.plot(
        df["TIME(ns)"],
        df["FREQ(Hz)"],
        alpha=0.3,
        label="Original"
    )

    plt.plot(
        df["TIME(ns)"],
        df["FREQ_smooth"],
        linewidth=2,
        label="Smoothed"
    )

    # === Линия среднего значения ===
    plt.axhline(
        y=mean_freq,
        color="red",
        linewidth=2,
        linestyle="--",
        label=f"Mean = {mean_freq:.2f}"
    )

    # === Выделение участка ===
    plt.axvspan(
        0,
        8,
        facecolor="yellow",
        alpha=0.3,
        hatch="...",
        edgecolor="gold"
    )

    plt.title(title)
    plt.xlabel("Time (us)")
    plt.ylabel("Frequency (MHz)")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()


# ==========================================================
# Построение пяти графиков
# ==========================================================

plot_freq(
    r"C:\Projects\All digital phase-locked loops\Int_N_ADPLL_NCO_PNCP_freq_log.txt",
    "Int-N ADPLL (NCO PNCP)"
)

plot_freq(
    r"C:\Projects\All digital phase-locked loops\Frac_N_ADPLL_DCO_freq_log.txt",
    "Frac-N ADPLL (DCO)"
)





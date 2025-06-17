# OSP-Shiny-Tool: Open Systems Pharmacology Data Explorer

This repository contains a demonstration of a modular Shiny application for exploring Open Systems Pharmacology (OSP) Suite data. Developed with a focus on pharmaceutical research and GxP-compliant R practices, this project showcases capabilities in R package development, modular Shiny app design, and continuous integration.

## Project Structure

* `OSPExplorerApp/`: Contains the main Shiny application, structured with modules for data loading, visualization, and more.
* `ospapputils/`: An R package providing utility functions for data handling, preparation, and potentially advanced analytics, designed to support the Shiny application.
* `.github/workflows/`: Holds GitHub Actions workflows for continuous integration (e.g., R CMD check for the `ospapputils` package).

## Features (Current - Done By now)

* **Modular Shiny Application:** Basic structure with separate modules for data input and visualization.
* **Mock OSP Data Loading:** Ability to load mock PBPK/QSP simulation and observed clinical data.
* **Basic Visualization:** Concentration-time plot with filtering options by data type and study.
* **R Package (`ospapputils`):** Initial package structure with a function to generate mock data.
* **Unit Testing:** Basic `testthat` unit tests for the `ospapputils` package.
* **CI/CD:** Basic GitHub Actions workflow to run `R CMD check` on `ospapputils` upon push/pull request.

## How to Run

1.  Clone this repository:
    `git clone https://github.com/nautilus69/OSP_Demo.git`
2.  Navigate to the Shiny app directory:
    `cd OSP_Demo/OSPExplorerApp`
3.  Ensure `ospapputils` is installed (you might need to install `devtools` first, then run `devtools::install("../ospapputils")` from the `OSPExplorerApp` directory).
4.  Run the app in R:
    ```R
    # From RStudio, navigate to OSPExplorerApp and open app.R, then click 'Run App'.
    # Alternatively, from terminal:
    # R -e "shiny::runApp('OSPExplorerApp')"
    ```

## Planned Enhancements (TODO)

* **Enhanced Data Comparison:** Incorporate tools for individual/population overlays and goodness-of-fit metrics.
* **Interactive Plotting:** Integrate `plotly` for interactive data exploration.
* **Sophisticated Data Upload/Validation:** Improve robustness of file uploads and add data validation checks within `ospapputils`.
* **GxP Documentation:** Add a simple validation section or a conceptual framework for validation within the project.
* **Containerization:** Introduce a Dockerfile for reproducible deployment.

###Performance test automation scripts for WSO2 ML 1.1.0
* Enable CSV reporting for [WSO2 Carbon Metrics](https://github.com/wso2/carbon-metrics) by making the following change in `<ML_HOME>/repository/conf/metrics.xml`.

        <CSV>
            <Enabled>true</Enabled>
            <Location>${carbon.home}/repository/logs/metrics/</Location>
            <!-- Polling Period in seconds.
                This is the period for polling metrics from the metric registry and
                update CSV files in the given location -->
            <PollingPeriod>60</PollingPeriod>
        </CSV>
* Copy the content of this directory (`perf-test`) into `<ML_HOME>/samples`.
* Run `run-tests.sh` script using `./run-tests.sh`.
* Performance test results will be saved in CSV files `perf-results-model-building.csv` and `perf-results-prediction.csv` under `samples` directory.

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model_monitoring.R
\name{ModelMonitor}
\alias{ModelMonitor}
\title{ModelMonitor Class}
\description{
Sets up Amazon SageMaker Monitoring Schedules and baseline suggestions. Use this class when
             you want to provide your own container image containing the code you'd like to run, in order
             to produce your own statistics and constraint validation files.
             For a more guided experience, consider using the DefaultModelMonitor class instead.
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-new}{\code{ModelMonitor$new()}}
\item \href{#method-run_baseline}{\code{ModelMonitor$run_baseline()}}
\item \href{#method-create_monitoring_schedule}{\code{ModelMonitor$create_monitoring_schedule()}}
\item \href{#method-update_monitoring_schedule}{\code{ModelMonitor$update_monitoring_schedule()}}
\item \href{#method-start_monitoring_schedule}{\code{ModelMonitor$start_monitoring_schedule()}}
\item \href{#method-stop_monitoring_schedule}{\code{ModelMonitor$stop_monitoring_schedule()}}
\item \href{#method-delete_monitoring_schedule}{\code{ModelMonitor$delete_monitoring_schedule()}}
\item \href{#method-baseline_statistics}{\code{ModelMonitor$baseline_statistics()}}
\item \href{#method-suggested_constraints}{\code{ModelMonitor$suggested_constraints()}}
\item \href{#method-latest_monitoring_statistics}{\code{ModelMonitor$latest_monitoring_statistics()}}
\item \href{#method-latest_monitoring_constraint_violations}{\code{ModelMonitor$latest_monitoring_constraint_violations()}}
\item \href{#method-describe_latest_baselining_job}{\code{ModelMonitor$describe_latest_baselining_job()}}
\item \href{#method-describe_schedule}{\code{ModelMonitor$describe_schedule()}}
\item \href{#method-list_executions}{\code{ModelMonitor$list_executions()}}
\item \href{#method-attach}{\code{ModelMonitor$attach()}}
\item \href{#method-print}{\code{ModelMonitor$print()}}
\item \href{#method-clone}{\code{ModelMonitor$clone()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-new"></a>}}
\if{latex}{\out{\hypertarget{method-new}{}}}
\subsection{Method \code{new()}}{
Initializes a ``Monitor`` instance. The Monitor handles baselining datasets and
             creating Amazon SageMaker Monitoring Schedules to monitor SageMaker endpoints.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$new(
  role = NULL,
  image_uri = NULL,
  instance_count = 1,
  instance_type = "ml.m5.xlarge",
  entrypoint = NULL,
  volume_size_in_gb = 30,
  volume_kms_key = NULL,
  output_kms_key = NULL,
  max_runtime_in_seconds = NULL,
  base_job_name = NULL,
  sagemaker_session = NULL,
  env = NULL,
  tags = NULL,
  network_config = NULL
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{role}}{(str): An AWS IAM role. The Amazon SageMaker jobs use this role.}

\item{\code{image_uri}}{(str): The uri of the image to use for the jobs started by
the Monitor.}

\item{\code{instance_count}}{(int): The number of instances to run
the jobs with.}

\item{\code{instance_type}}{(str): Type of EC2 instance to use for
the job, for example, 'ml.m5.xlarge'.}

\item{\code{entrypoint}}{([str]): The entrypoint for the job.}

\item{\code{volume_size_in_gb}}{(int): Size in GB of the EBS volume
to use for storing data during processing (default: 30).}

\item{\code{volume_kms_key}}{(str): A KMS key for the job's volume.}

\item{\code{output_kms_key}}{(str): The KMS key id for the job's outputs.}

\item{\code{max_runtime_in_seconds}}{(int): Timeout in seconds. After this amount of
time, Amazon SageMaker terminates the job regardless of its current status.
Default: 3600}

\item{\code{base_job_name}}{(str): Prefix for the job name. If not specified,
a default name is generated based on the training image name and
current timestamp.}

\item{\code{sagemaker_session}}{(sagemaker.session.Session): Session object which
manages interactions with Amazon SageMaker APIs and any other
AWS services needed. If not specified, one is created using
the default AWS configuration chain.}

\item{\code{env}}{(dict): Environment variables to be passed to the job.}

\item{\code{tags}}{([dict]): List of tags to be passed to the job.}

\item{\code{network_config}}{(sagemaker.network.NetworkConfig): A NetworkConfig
object that configures network isolation, encryption of
inter-container traffic, security group IDs, and subnets.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-run_baseline"></a>}}
\if{latex}{\out{\hypertarget{method-run_baseline}{}}}
\subsection{Method \code{run_baseline()}}{
Run a processing job meant to baseline your dataset.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$run_baseline(
  baseline_inputs,
  output,
  arguments = NULL,
  wait = TRUE,
  logs = TRUE,
  job_name = NULL
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{baseline_inputs}}{([sagemaker.processing.ProcessingInput]): Input files for the processing
job. These must be provided as ProcessingInput objects.}

\item{\code{output}}{(sagemaker.processing.ProcessingOutput): Destination of the constraint_violations
and statistics json files.}

\item{\code{arguments}}{([str]): A list of string arguments to be passed to a processing job.}

\item{\code{wait}}{(bool): Whether the call should wait until the job completes (default: True).}

\item{\code{logs}}{(bool): Whether to show the logs produced by the job.
Only meaningful when wait is True (default: True).}

\item{\code{job_name}}{(str): Processing job name. If not specified, the processor generates
a default job name, based on the image name and current timestamp.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-create_monitoring_schedule"></a>}}
\if{latex}{\out{\hypertarget{method-create_monitoring_schedule}{}}}
\subsection{Method \code{create_monitoring_schedule()}}{
Creates a monitoring schedule to monitor an Amazon SageMaker Endpoint.
             If constraints and statistics are provided, or if they are able to be retrieved from a
             previous baselining job associated with this monitor, those will be used.
             If constraints and statistics cannot be automatically retrieved, baseline_inputs will be
             required in order to kick off a baselining job.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$create_monitoring_schedule(
  endpoint_input,
  output,
  statistics = NULL,
  constraints = NULL,
  monitor_schedule_name = NULL,
  schedule_cron_expression = NULL
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{endpoint_input}}{(str or sagemaker.model_monitor.EndpointInput): The endpoint to monitor.
This can either be the endpoint name or an EndpointInput.}

\item{\code{output}}{(sagemaker.model_monitor.MonitoringOutput): The output of the monitoring
schedule.}

\item{\code{statistics}}{(sagemaker.model_monitor.Statistic or str): If provided alongside
constraints, these will be used for monitoring the endpoint. This can be a
sagemaker.model_monitor.Constraints object or an S3 uri pointing to a constraints
JSON file.}

\item{\code{constraints}}{(sagemaker.model_monitor.Constraints or str): If provided alongside
statistics, these will be used for monitoring the endpoint. This can be a
sagemaker.model_monitor.Constraints object or an S3 uri pointing to a constraints
JSON file.}

\item{\code{monitor_schedule_name}}{(str): Schedule name. If not specified, the processor generates
a default job name, based on the image name and current timestamp.}

\item{\code{schedule_cron_expression}}{(str): The cron expression that dictates the frequency that
this job runs at. See sagemaker.model_monitor.CronExpressionGenerator for valid
expressions. Default: Daily.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-update_monitoring_schedule"></a>}}
\if{latex}{\out{\hypertarget{method-update_monitoring_schedule}{}}}
\subsection{Method \code{update_monitoring_schedule()}}{
Updates the existing monitoring schedule.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$update_monitoring_schedule(
  endpoint_input = NULL,
  output = NULL,
  statistics = NULL,
  constraints = NULL,
  schedule_cron_expression = NULL,
  instance_count = NULL,
  instance_type = NULL,
  entrypoint = NULL,
  volume_size_in_gb = NULL,
  volume_kms_key = NULL,
  output_kms_key = NULL,
  arguments = NULL,
  max_runtime_in_seconds = NULL,
  env = NULL,
  network_config = NULL,
  role = NULL,
  image_uri = NULL
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{endpoint_input}}{(str or sagemaker.model_monitor.EndpointInput): The endpoint to monitor.
This can either be the endpoint name or an EndpointInput.}

\item{\code{output}}{(sagemaker.model_monitor.MonitoringOutput): The output of the monitoring
schedule.}

\item{\code{statistics}}{(sagemaker.model_monitor.Statistic or str): If provided alongside
constraints, these will be used for monitoring the endpoint. This can be a
sagemaker.model_monitor.Constraints object or an S3 uri pointing to a constraints
JSON file.}

\item{\code{constraints}}{(sagemaker.model_monitor.Constraints or str): If provided alongside
statistics, these will be used for monitoring the endpoint. This can be a
sagemaker.model_monitor.Constraints object or an S3 uri pointing to a constraints
JSON file.}

\item{\code{schedule_cron_expression}}{(str): The cron expression that dictates the frequency that
this job runs at.  See sagemaker.model_monitor.CronExpressionGenerator for valid
expressions.}

\item{\code{instance_count}}{(int): The number of instances to run
the jobs with.}

\item{\code{instance_type}}{(str): Type of EC2 instance to use for
the job, for example, 'ml.m5.xlarge'.}

\item{\code{entrypoint}}{(str): The entrypoint for the job.}

\item{\code{volume_size_in_gb}}{(int): Size in GB of the EBS volume
to use for storing data during processing (default: 30).}

\item{\code{volume_kms_key}}{(str): A KMS key for the job's volume.}

\item{\code{output_kms_key}}{(str): The KMS key id for the job's outputs.}

\item{\code{arguments}}{([str]): A list of string arguments to be passed to a processing job.}

\item{\code{max_runtime_in_seconds}}{(int): Timeout in seconds. After this amount of
time, Amazon SageMaker terminates the job regardless of its current status.
Default: 3600}

\item{\code{env}}{(dict): Environment variables to be passed to the job.}

\item{\code{network_config}}{(sagemaker.network.NetworkConfig): A NetworkConfig
object that configures network isolation, encryption of
inter-container traffic, security group IDs, and subnets.}

\item{\code{role}}{(str): An AWS IAM role name or ARN. The Amazon SageMaker jobs use this role.}

\item{\code{image_uri}}{(str): The uri of the image to use for the jobs started by
the Monitor.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-start_monitoring_schedule"></a>}}
\if{latex}{\out{\hypertarget{method-start_monitoring_schedule}{}}}
\subsection{Method \code{start_monitoring_schedule()}}{
Starts the monitoring schedule.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$start_monitoring_schedule()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-stop_monitoring_schedule"></a>}}
\if{latex}{\out{\hypertarget{method-stop_monitoring_schedule}{}}}
\subsection{Method \code{stop_monitoring_schedule()}}{
Stops the monitoring schedule.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$stop_monitoring_schedule()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-delete_monitoring_schedule"></a>}}
\if{latex}{\out{\hypertarget{method-delete_monitoring_schedule}{}}}
\subsection{Method \code{delete_monitoring_schedule()}}{
Deletes the monitoring schedule.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$delete_monitoring_schedule()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-baseline_statistics"></a>}}
\if{latex}{\out{\hypertarget{method-baseline_statistics}{}}}
\subsection{Method \code{baseline_statistics()}}{
Returns a Statistics object representing the statistics json file generated by the
             latest baselining job.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$baseline_statistics(file_name = STATISTICS_JSON_DEFAULT_FILE_NAME)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{file_name}}{(str): The name of the .json statistics file}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
sagemaker.model_monitor.Statistics: The Statistics object representing the file that
             was generated by the job.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-suggested_constraints"></a>}}
\if{latex}{\out{\hypertarget{method-suggested_constraints}{}}}
\subsection{Method \code{suggested_constraints()}}{
Returns a Statistics object representing the constraints json file generated by the
             latest baselining job
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$suggested_constraints(
  file_name = CONSTRAINTS_JSON_DEFAULT_FILE_NAME
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{file_name}}{(str): The name of the .json constraints file}

\item{\code{sagemaker.model_monitor.Constraints:}}{The Constraints object representing the file that
was generated by the job.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-latest_monitoring_statistics"></a>}}
\if{latex}{\out{\hypertarget{method-latest_monitoring_statistics}{}}}
\subsection{Method \code{latest_monitoring_statistics()}}{
Returns the sagemaker.model_monitor.Statistics generated by the latest monitoring
             execution.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$latest_monitoring_statistics(
  file_name = STATISTICS_JSON_DEFAULT_FILE_NAME
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{file_name}}{(str): The name of the statistics file to be retrieved. Only override if
generating a custom file name.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
sagemaker.model_monitoring.Statistics: The Statistics object representing the file
             generated by the latest monitoring execution.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-latest_monitoring_constraint_violations"></a>}}
\if{latex}{\out{\hypertarget{method-latest_monitoring_constraint_violations}{}}}
\subsection{Method \code{latest_monitoring_constraint_violations()}}{
Returns the sagemaker.model_monitor.ConstraintViolations generated by the latest
             monitoring execution.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$latest_monitoring_constraint_violations(
  file_name = CONSTRAINT_VIOLATIONS_JSON_DEFAULT_FILE_NAME
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{file_name}}{(str): The name of the constraint violdations file to be retrieved. Only
override if generating a custom file name.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
sagemaker.model_monitoring.ConstraintViolations: The ConstraintViolations object
             representing the file generated by the latest monitoring execution.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-describe_latest_baselining_job"></a>}}
\if{latex}{\out{\hypertarget{method-describe_latest_baselining_job}{}}}
\subsection{Method \code{describe_latest_baselining_job()}}{
Describe the latest baselining job kicked off by the suggest workflow.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$describe_latest_baselining_job()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-describe_schedule"></a>}}
\if{latex}{\out{\hypertarget{method-describe_schedule}{}}}
\subsection{Method \code{describe_schedule()}}{
Describes the schedule that this object represents.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$describe_schedule()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
dict: A dictionary response with the monitoring schedule description.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-list_executions"></a>}}
\if{latex}{\out{\hypertarget{method-list_executions}{}}}
\subsection{Method \code{list_executions()}}{
Get the list of the latest monitoring executions in descending order of "ScheduledTime".
             Statistics or violations can be called following this example:
             Example:
             >>> my_executions = my_monitor.list_executions()
             >>> second_to_last_execution_statistics = my_executions[-1].statistics()
             >>> second_to_last_execution_violations = my_executions[-1].constraint_violations()
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$list_executions()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
[sagemaker.model_monitor.MonitoringExecution]: List of MonitoringExecutions in
             descending order of "ScheduledTime".
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-attach"></a>}}
\if{latex}{\out{\hypertarget{method-attach}{}}}
\subsection{Method \code{attach()}}{
Sets this object's schedule name to point to the Amazon Sagemaker Monitoring Schedule
             name provided. This allows subsequent describe_schedule or list_executions calls to point
             to the given schedule.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$attach(monitor_schedule_name, sagemaker_session = NULL)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{monitor_schedule_name}}{(str): The name of the schedule to attach to.}

\item{\code{sagemaker_session}}{(sagemaker.session.Session): Session object which
manages interactions with Amazon SageMaker APIs and any other
AWS services needed. If not specified, one is created using
the default AWS configuration chain.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-print"></a>}}
\if{latex}{\out{\hypertarget{method-print}{}}}
\subsection{Method \code{print()}}{
Printer.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$print(...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{...}}{(ignored).}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-clone"></a>}}
\if{latex}{\out{\hypertarget{method-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ModelMonitor$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}

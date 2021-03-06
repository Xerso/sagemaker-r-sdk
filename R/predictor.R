# NOTE: This code has been modified from AWS Sagemaker Python: https://github.com/aws/sagemaker-python-sdk/blob/master/src/sagemaker/predictor.py

#' @include utils.R
#' @include fw_utils.R
#' @include model.R
#' @include fw_utils.R
#' @include session.R
#' @include vpc_utils.R
#' @include analytics.R
#' @include serializers.R
#' @include deserializers.R

#' @import paws
#' @import R6
#' @import utils

#' @title RealTimePredictor Class
#' @description Make prediction requests to an Amazon SageMaker endpoint.
#' @export
RealTimePredictor = R6Class("RealTimePredictor",
  public = list(

    #' @field endpoint
    #'        Name of the Amazon SageMaker endpoint
    endpoint = NULL,

    #' @field sagemaker_session
    #'        A SageMaker Session object
    sagemaker_session = NULL,

    #' @field serializer
    #'        Class to convert data into raw to send to endpoint
    serializer = NULL,

    #' @field deserializer
    #'        Class to convert raw data back from the endpoint
    deserializer = NULL,

    #' @field content_type
    #'        Format to of data to send endpoint
    content_type = NULL,

    #' @field accept
    #'        Format returning from endpoint
    accept = NULL,

    #' @field .endpoint_config_name
    #'        Endpoint configuration name
    .endpoint_config_name = NULL,

    #' @field .model_names
    #'        Model names being used at endpoint
    .model_names = NULL,

    #' @description Initialize a ``RealTimePredictor``.
    #'              Behavior for serialization of input data and deserialization of
    #'              result data can be configured through initializer arguments. If not
    #'              specified, a sequence of bytes is expected and the API sends it in the
    #'              request body without modifications. In response, the API returns the
    #'              sequence of bytes from the prediction result without any modifications.
    #' @param endpoint (str): Name of the Amazon SageMaker endpoint to which
    #'              requests are sent.
    #' @param sagemaker_session (sagemaker.session.Session): A SageMaker Session
    #'              object, used for SageMaker interactions (default: NULL). If not
    #'              specified, one is created using the default AWS configuration
    #'              chain.
    #' @param serializer (callable): Accepts a single argument, the input data,
    #'              and returns a sequence of bytes. It may provide a
    #'              ``content_type`` attribute that defines the endpoint request
    #'              content type. If not specified, a sequence of bytes is expected
    #'              for the data. (default: ``csv_serializer``)
    #' @param deserializer (callable): Accepts two arguments, the result data and
    #'              the response content type, and returns a sequence of bytes. It
    #'              may provide a ``content_type`` attribute that defines the
    #'              endpoint response's "Accept" content type. If not specified, a
    #'              sequence of bytes is expected for the data. (default: ``csv_deserializer``)
    initialize = function(endpoint,
                          sagemaker_session=NULL,
                          serializer=csv_serializer,
                          deserializer=csv_deserializer){

      self$endpoint = endpoint
      self$sagemaker_session = sagemaker_session %||% Session$new()
      self$serializer = if(inherits(serializer, "BaseSerializer") || is.null(serializer)) serializer else stop("Please use a R6 Serializer Class.", call. = F)
      self$deserializer = if(inherits(deserializer, "BaseDeserializer") || is.null(deserializer)) deserializer else stop("Please use a R6 Deserializer Class.", call. = F)
      self$content_type = serializer$CONTENT_TYPE
      self$accept = deserializer$ACCEPT
      self$.endpoint_config_name = private$.get_endpoint_config_name()
      self$.model_names = private$.get_model_names()
    },

    #' @description Return the inference from the specified endpoint.
    #' @param data (object): Input data for which you want the model to provide
    #'              inference. If a serializer was specified when creating the
    #'              RealTimePredictor, the result of the serializer is sent as input
    #'              data. Otherwise the data must be sequence of bytes, and the
    #'              predict method then sends the bytes in the request body as is.
    #' @param initial_args (list[str,str]): Optional. Default arguments for boto3
    #'              ``invoke_endpoint`` call. Default is NULL (no default
    #'              arguments).
    #' @param target_model (str): S3 model artifact path to run an inference request on,
    #'              in case of a multi model endpoint. Does not apply to endpoints hosting
    #'              single model (Default: NULL)
    #' @param target_variant (str): The name of the production variant to run an inference
    #'              request on (Default: NULL). Note that the ProductionVariant identifies the model
    #'              you want to host and the resources you want to deploy for hosting it. Currently not implemented.
    #' @return object: Inference for the given input. If a deserializer was specified when creating
    #'              the RealTimePredictor, the result of the deserializer is
    #'              returned. Otherwise the response returns the sequence of bytes
    #'              as is.
    predict = function(data,
                       initial_args=NULL,
                       target_model=NULL,
                       target_variant=NULL){
      # get sagemaker runtime object from paws
      sagemaker_runtime = paws::sagemakerruntime(config = self$sagemaker_session$paws_credentials$credentials)
      request_args = private$.create_request_args(data, initial_args, target_model, target_variant)

      response = sagemaker_runtime$invoke_endpoint(EndpointName = request_args$EndpointName,
                                                   Body = request_args$Body,
                                                   ContentType = request_args$ContentType,
                                                   Accept = request_args$Accept,
                                                   CustomAttributes = request_args$CustomAttributes,
                                                   TargetModel = request_args$TargetModel)
      return(private$.handle_response(response))
    },

    #' @description Delete the Amazon SageMaker endpoint backing this predictor. Also
    #'              delete the endpoint configuration attached to it if
    #'              delete_endpoint_config is True.
    #' @param delete_endpoint_config (bool, optional): Flag to indicate whether to
    #'              delete endpoint configuration together with endpoint. Defaults
    #'              to True. If True, both endpoint and endpoint configuration will
    #'              be deleted. If False, only endpoint will be deleted.
    delete_endpoint = function(delete_endpoint_config=TRUE){
      if(delete_endpoint_config)
        private$.delete_endpoint_config()

      self$sagemaker_session$delete_endpoint(self$endpoint)
    },

    #' @description Deletes the Amazon SageMaker models backing this predictor.
    delete_model = function(){
      request_failed = FALSE
      failed_models = list()
      for (model_name in self$.model_names){
        tryCatch(self$sagemaker_session$delete_model(model_name),
                 error = function(e) {
                   request_failed = TRUE
                   failed_models[[model_name]] = request_failed})
      }

      if (any(unlist(request_failed)))
        stop("One or more models cannot be deleted, please retry. \n",
        sprintf("Failed models: %s", paste0(failed_models[failed_models == FALSE], collapse = ", ")))
    },

    #' @description Updates the DataCaptureConfig for the Predictor's associated Amazon SageMaker Endpoint
    #'              to enable data capture. For a more customized experience, refer to
    #'              update_data_capture_config, instead.
    enable_data_capture = function(){
      self$update_data_capture_config(
        data_capture_config=DataCaptureConfig$new(
          enable_capture=TRUE, sagemaker_session=self$sagemaker_session)
        )
    },

    #' @description Updates the DataCaptureConfig for the Predictor's associated Amazon SageMaker Endpoint
    #'              to disable data capture. For a more customized experience, refer to
    #'              update_data_capture_config, instead.
    disable_data_capture = function(){
      self$update_data_capture_config(
        data_capture_config=DataCaptureConfig$new(
          enable_capture=FALSE, sagemaker_session=self$sagemaker_session))
    },

    #' @description Updates the DataCaptureConfig for the Predictor's associated Amazon SageMaker Endpoint
    #'              with the provided DataCaptureConfig.
    #' @param data_capture_config (sagemaker.model_monitor.DataCaptureConfig): The
    #'              DataCaptureConfig to update the predictor's endpoint to use.
    update_data_capture_config = function(data_capture_config = NULL){
      endpoint_desc = self$sagemaker_session$sagemaker$describe_endpoint(
                        EndpointName=self$endpoint)

      new_config_name = name_from_base(base=self$endpoint)

      data_capture_config_dict = NULL
      if (!is.null(data_capture_config))
        data_capture_config_dict = data_capture_config$to_request_list()

      self$sagemaker_session$create_endpoint_config_from_existing(
              existing_config_name=endpoint_desc$EndpointConfigName,
              new_config_name=new_config_name,
              new_data_capture_config_dict=data_capture_config_dict)

      self$sagemaker_session$update_endpoint(
                  endpoint_name=self$endpoint, endpoint_config_name=new_config_name)
    },

    #' @description Generates ModelMonitor objects (or DefaultModelMonitors) based on the schedule(s)
    #'              associated with the endpoint that this predictor refers to.
    #'@return [sagemaker.model_monitor.model_monitoring.ModelMonitor]: A list of
    #'              ModelMonitor (or DefaultModelMonitor) objects.
    list_monitor = function(){
      monitoring_schedules_list = self$sagemaker_session$list_monitoring_schedules(
        endpoint_name=self$endpoint)
      if (islistempty(monitoring_schedules_list$MonitoringScheduleSummaries)){
        writeLines(sprintf("No monitors found for endpoint. endpoint: %s",self$endpoint))
        return(list())}

      monitors = list()
      for (schedule_dict in monitoring_schedules_list$MonitoringScheduleSummaries){
        schedule_name = schedule_dict$MonitoringScheduleName
        schedule = self$sagemaker_session$describe_monitoring_schedule(
                        monitoring_schedule_name=schedule_name)

        image_uri = schedule$MonitoringScheduleConfig$MonitoringJobDefinition$MonitoringAppSpecification$ImageUri
         if (endsWith(image_uri,"/sagemaker-model-monitor-analyzer")){
          monitors = c(monitors, DefaultModelMonitor$new()$attach(monitor_schedule_name=schedule_name,
                                                      sagemaker_session=self$sagemaker_session))
        } else {
          monitors = c(monitors, ModelMonitor$new()$attach(
              monitor_schedule_name=schedule_name,
              sagemaker_session=self$sagemaker_session))
        }
      }

      return(monitors)
    }
  ),
  private = list(
    .handle_response = function(response){
      response_body = response$Body
      content_type = response$ContentType %||% "application/octet-stream"
      if (!is.null(self$deserializer)){
        # It's the deserializer's responsibility to close the stream
        return(self$deserializer$deserialize(response_body, content_type))}
      return(response_body)
    },

    .create_request_args = function(data, initial_args=NULL, target_model=NULL, target_variant=NULL){
      args = if (!islistempty(initial_args)) initial_args else list()
      if (!("EndpointName" %in% names(args))){
        args$EndpointName = self$endpoint}

      if (!("ContentType" %in% names(args))){
        args$ContentType = self$content_type %||% self$serializer$CONTENT_TYPE}

      if (!("Accept" %in% names(args))){
        args$Accept = paste(self$accept %||% self$deserializer$ACCEPT, collapse = ",")
        }

      if (!is.null(target_model)){
        args$TargetModel = target_model}

      if (!is.null(target_variant)){
        args$TargetVariant = target_variant}

      if (!is.null(self$serializer)){
        data = self$serializer$serialize(data)}

      args$Body = data
      return(args)
    },

    # Delete the Amazon SageMaker endpoint configuration
    .delete_endpoint_config = function(){
      self$sagemaker_session$delete_endpoint_config(self$.endpoint_config_name)
    },

    .get_endpoint_config_name = function(){
      endpoint_desc = self$sagemaker_session$sagemaker$describe_endpoint(
            EndpointName=self$endpoint)
      endpoint_config_name = endpoint_desc$EndpointConfigName
      return(endpoint_config_name)
    },

    .get_model_names = function() {
      endpoint_config = self$sagemaker_session$sagemaker$describe_endpoint_config(
            EndpointConfigName=self$.endpoint_config_name)
      production_variants = endpoint_config$ProductionVariants
      return (sapply(production_variants, function(x) x$ModelName))
    }
  )
)


#' @title S3 method that wraps RealTimePredictor Class
#' @description Predicted values returned from endpoint
#' @param object a sagemaker model
#' @param newdata data for model to predict
#' @param serializer method class to serializer data to sagemaker model. Requires to be
#'              a class inherited from \link{Serializer}. (Default: \link{csv_serializer})
#' @param deserializer method class to deserializer return data streams from sagemaker model.
#'              Requires to be a class inherited from \link{Deserializer}.
#'              (Default: \link{csv_deserializer})
#' @param ... arguments passed to ``RealTimePredictor$predict``
#' @export
predict.RealTimePredictor <- function(object, newdata, serializer = csv_serializer, deserializer = csv_deserializer, ...){
  stopifnot(is.null(serializer) || inherits(serializer,"BaseSerializer"),
            is.null(deserializer) || inherits(deserializer,"BaseDeserializer"))

  obj = object$clone()
  obj$serializer = serializer
  obj$deserializer = deserializer
  obj$predict(newdata, ...)
}

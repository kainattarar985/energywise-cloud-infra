import json
import os
import boto3

SAGEMAKER_ENDPOINT_NAME = os.environ["SAGEMAKER_ENDPOINT_NAME"]

runtime = boto3.client("sagemaker-runtime")


# Must match the exact column order the model was trained on.
FEATURE_ORDER = [
    "hour",                # 0-23
    "day_of_week",         # 0=Mon .. 6=Sun
    "season",              # 0=winter, 1=spring, 2=summer, 3=fall
    "temperature_c",       # outdoor temperature in Celsius
    "occupancy",           # 0 or 1
    "prev_day_usage_kwh",  # previous day's usage in kWh
]


def handler(event, context):
    """
    Expects a JSON body with the six fields in FEATURE_ORDER, e.g.:
    {"hour": 14, "day_of_week": 2, "season": 0, "temperature_c": 5.3,
     "occupancy": 1, "prev_day_usage_kwh": 22.4}

    Converts it to the CSV row format the built-in SageMaker XGBoost
    container expects, invokes the endpoint, and returns the predicted
    energy consumption in kWh.
    """
    try:
        body = json.loads(event.get("body") or "{}")

        missing = [f for f in FEATURE_ORDER if f not in body]
        if missing:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"error": f"Missing fields: {missing}"}),
            }

        csv_row = ",".join(str(body[f]) for f in FEATURE_ORDER)

        response = runtime.invoke_endpoint(
            EndpointName=SAGEMAKER_ENDPOINT_NAME,
            ContentType="text/csv",
            Body=csv_row,
        )

        prediction = response["Body"].read().decode("utf-8").strip()

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"predicted_energy_kwh": float(prediction)}),
        }

    except Exception as exc:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(exc)}),
        }

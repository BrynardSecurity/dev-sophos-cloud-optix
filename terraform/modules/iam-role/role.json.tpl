{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::195990147830:root"
    },
    "Condition": {
      "StringEquals": {
        "sts:ExternalId": "${external_id}"
      }
    },
    "Action": [
      "sts:AssumeRole"
    ]
  }]
}

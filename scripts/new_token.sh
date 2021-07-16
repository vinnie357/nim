function new_token {
  # new_token
  # get a new oauth bearer token
  token=$(gcloud auth print-identity-token)
  header="bearer "$token
  echo $header
}

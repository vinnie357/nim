function pre_commit {
  git add .
  pre-commit run -a -v
}

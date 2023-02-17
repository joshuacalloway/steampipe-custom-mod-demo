dashboard "test2" {
  title = "Public S3 buckets failing Control: 8 S3 Block Public Access setting should be enabled at the bucket level"
  container {
    card {
      sql = <<-EOQ
select
  -- Required Columns
  count(*)
from
  fosprod.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)

EOQ
      width = 2
    }
  }
  table {
    title = "FosProd"
    sql - <<EOQ
select
  -- Required Columns
  name,
  case
    when
      block_public_acls
      and block_public_policy
      and ignore_public_acls
      and restrict_public_buckets
    then
      'ok'
    else
      'alarm'
  end status,
  case
    when
      block_public_acls
      and block_public_policy
      and ignore_public_acls
      and restrict_public_buckets
    then name || ' blocks public access.'
    else name || ' does not block public access.'
  end reason,
  -- Additional Dimensions
  region,
  account_id
from
  fosprod.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)
EOQ
  }
}

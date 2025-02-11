dashboard "unused_securitygroups" {
  title = "Unused / Orphaned VPC Security Groups"
  container {
    card {
      type = "alert"
      sql = <<-EOQ
with associated_sg as (
  select
    sg ->> 'GroupId' as sg_id,
    sg ->> 'GroupName' as sg_name
  from
    parilux.aws_ec2_network_interface,
    jsonb_array_elements(groups) as sg
)
select count(*) as Parilux
from
  parilux.aws_vpc_security_group s
  left join associated_sg a on s.group_id = a.sg_id
where
  a.sg_id is null
EOQ
      width = 2
    }
    card {
      type = "alert"
      sql = <<-EOQ
with associated_sg as (
  select
    sg ->> 'GroupId' as sg_id,
    sg ->> 'GroupName' as sg_name
  from
    fosprod.aws_ec2_network_interface,
    jsonb_array_elements(groups) as sg
)
select count(*) as FosProd
from
  fosprod.aws_vpc_security_group s
  left join associated_sg a on s.group_id = a.sg_id
where
  a.sg_id is null
EOQ
      width = 2
    }
  }
  table {
    title = "Parilux"
    sql = <<EOQ
with associated_sg as (
  select
    sg ->> 'GroupId' as sg_id,
    sg ->> 'GroupName' as sg_name
  from
    parilux.aws_ec2_network_interface,
    jsonb_array_elements(groups) as sg
)
select
  s.group_name,
  s.description,
  s.arn,
  s.vpc_id,
  s.region,
  s.account_id
from
  parilux.aws_vpc_security_group s
  left join associated_sg a on s.group_id = a.sg_id
where
  a.sg_id is null
    EOQ
  }
  table {
    title = "FosProd"
    sql = <<EOQ
with associated_sg as (
  select
    sg ->> 'GroupId' as sg_id,
    sg ->> 'GroupName' as sg_name
  from
    fosprod.aws_ec2_network_interface,
    jsonb_array_elements(groups) as sg
)
select
  s.group_name,
  s.description,
  s.arn,
  s.vpc_id,
  s.region,
  s.account_id
from
  fosprod.aws_vpc_security_group s
  left join associated_sg a on s.group_id = a.sg_id
where
  a.sg_id is null
    EOQ
  }
}


query "count_fosprod_s3buckets" {
      sql = <<-EOQ
select
  count(*) as FosProd
from
  fosprod.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)
EOQ
}

query "count_parilux_s3buckets" {
      sql = <<-EOQ
select
  count(*) as Parilux
from
  parilux.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)
EOQ
}


dashboard "public_s3buckets" {
  title = "Public S3 buckets failing Control: 8 S3 Block Public Access setting should be enabled at the bucket level"
  container {
    card {
      type = "alert"
      sql = query.count_fosprod_s3buckets.sql
      width = 2
    }
    card {
      type = "alert"
      sql = query.count_parilux_s3buckets.sql
      width = 2
    }
  }
  table {
    title = "FosProd"
    sql = query.list_fosprod_s3buckets.sql
  }
  table {
    title = "Parilux"
    sql = query.list_parilux_s3buckets.sql
  }
}
query "list_parilux_s3buckets" {
  sql = <<-EOQ
select
  -- Required Columns
  name,
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
  parilux.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)
EOQ
}
query "list_fosprod_s3buckets" {
  sql = <<-EOQ
select
  -- Required Columns
  name,
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

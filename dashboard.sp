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


dashboard "public_s3buckets" {
  title = "Public S3 buckets failing Control: 8 S3 Block Public Access setting should be enabled at the bucket level"
  container {
    card {
      type = "alert"
      sql = <<-EOQ
select
  -- Required Columns
  count(*) as FosProd
from
  fosprod.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)
EOQ
      width = 2
    }
    card {
      type = "alert"
      sql = <<-EOQ
select
  -- Required Columns
  count(*) as Parilux
from
  parilux.aws_s3_bucket
where (not block_public_acls or not block_public_policy or not ignore_public_acls or not restrict_public_buckets)
EOQ
      width = 2
    }
  }
  table {
    title = "FosProd"
    sql = <<EOQ
with ingress_unauthorized_ports as (
  select
    group_id,
    count(*)
  from
    fosprod.aws_vpc_security_group_rule
  where
    type = 'ingress'
    and cidr_ipv4 = '0.0.0.0/0'
    and (from_port is null or from_port not in (443))
  group by group_id
)
select
  -- Required Columns
  sg.group_id,
  case
    when ingress_unauthorized_ports.count > 0 then sg.title || ' having unrestricted incoming traffic other than default ports from 0.0.0.0/0 '
    else sg.title || ' allows unrestricted incoming traffic for authorized default ports (443).'
  end as reason,
  sg.description,
  sg.region,
  sg.account_id
from
  fosprod.aws_vpc_security_group as sg
  left join ingress_unauthorized_ports on ingress_unauthorized_ports.group_id = sg.group_id
where ingress_unauthorized_ports.count > 0;
EOQ
  }
  table {
    title = "Parilux"
    sql = <<EOQ
  case
with ingress_unauthorized_ports as (
  select
    group_id,
    count(*)
  from
    fosprod.aws_vpc_security_group_rule
  where
    type = 'ingress'
    and cidr_ipv4 = '0.0.0.0/0'
    and (from_port is null or from_port not in (443))
  group by group_id
)
select
  -- Required Columns
  sg.group_id,
  case
    when ingress_unauthorized_ports.count > 0 then sg.title || ' having unrestricted incoming traffic other than default ports from 0.0.0.0/0 '
    else sg.title || ' allows unrestricted incoming traffic for authorized default ports (443).'
  end as reason,
  sg.description,
  sg.region,
  sg.account_id
from
  parilux.aws_vpc_security_group as sg
  left join ingress_unauthorized_ports on ingress_unauthorized_ports.group_id = sg.group_id
where ingress_unauthorized_ports.count > 0;
EOQ
  }
}

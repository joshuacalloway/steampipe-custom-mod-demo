dashboard "test" {
  title = "Unused / Orphaned VPC Security Groups"
  container {
    card {
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

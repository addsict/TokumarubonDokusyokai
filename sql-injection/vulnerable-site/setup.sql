create table bank_account (
    username varchar(128) primary key,
    balance integer
) engine=innodb default charset=utf8;

insert into bank_account values ('addsict', 10000);
insert into bank_account values ('laysakura', 10000);
insert into bank_account values ('murooka', 10000);
insert into bank_account values ('nozoe', 10000);

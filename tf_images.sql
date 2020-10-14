create table tf_images (`email_attachment_parent_filename` string,
`email_headers_sent_date` string,
`email_headers_from_0` string,
`mime_type` string,
`uuid` string,
`email_attachment_parent_uuid` string,
`path` string,
`email_headers_subject` string,
`email_attachment_count` string,
`filename` string,
`email_headers_to_0` string,
`email_headers_message-id` string,
`label_1` string,
`probability_1` string,
`label_2` string,
`probability_2` string,
`label_3` string,
`probability_3` string,
`label_4` string,
`probability_4` string,
`label_5` string,
`probability_5` string
);

create view tf_labels as 
select concat_ws(' ',label_1,label_2,label_3,label_4,label_5) as labels from stabu.tf_images;


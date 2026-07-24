import {
  id = "i-0c8de323e1707f19d"
  to = aws_instance.my_existing_instance
}

resource "aws_instance" "my_existing_instance" {
  ami = "ami-0fb110df4c5094d21"
  instance_type = "m7i-flex.large"
  key_name = "my_key"
  tags = {
    Name = "DevOps"
  }
}
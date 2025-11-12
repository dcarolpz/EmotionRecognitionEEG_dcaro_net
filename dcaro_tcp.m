% dcaro tcp/ip test
clear
clc

t = tcpclient('localhost',4000);
data = uint8(4);
write(t,data)

% It works.
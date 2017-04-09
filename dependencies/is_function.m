function out = is_function(fn)
% Aim: wrapper function to test whether the input argument
%     is a function or not.

fn = any(exist(fn)==[2,3,5])

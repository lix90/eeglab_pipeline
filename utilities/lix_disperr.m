% disp error message

function lix_disperr(err)

disp(err(:).message);
disp({err.stack.file});
disp({err.stack.name});
disp({err.stack.line});
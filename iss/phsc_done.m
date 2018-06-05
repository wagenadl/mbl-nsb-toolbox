function phsc_done(h, x)

f = iget(h, 'parent');
iset(f, '*completed', 1);
iresume

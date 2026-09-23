function [ s ] = DiscretizeState( x, statelist )
%DiscretizeState check which entry in the state list is more close to x and
%return the index of that entry.


x = x(:)';  % Asegura que x sea una fila
distances = sqrt(sum((statelist - x).^2, 2));
[d, s] = min(distances);


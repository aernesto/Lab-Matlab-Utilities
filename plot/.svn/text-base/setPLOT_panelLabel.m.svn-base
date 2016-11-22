function setPLOT_panelLabel(ax, label)
% function setPLOT_panelLabel(ax, label)

if nargin < 1 || isempty(ax)
    ax = gca;
end

if nargin < 2 || isempty(label)
    label = 'A';
elseif ~ischar(label)
    label = char(64+label);
end

axes(ax);
xl = get(ax, 'XLim');
yl = get(ax, 'YLim');

if strcmp(get(ax, 'YScale'), 'linear')
    h=text(xl(1),yl(1)+(yl(2)-yl(1))*1.1, label);
else
    h=text(xl(1),10.^(log10(yl(2))+(log10(yl(2))-log10(yl(1))).*0.1), label);
end
set(h,'FontSize',14,'FontWeight','bold');

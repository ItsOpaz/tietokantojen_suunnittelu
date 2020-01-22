-- kampanjan laskun kokonaissumma

select sum(hinta) from laskurivi,lasku,mainoskampanja as m
where lasku.kampanjaid = m.kampanjaid and m.kampanjaid = 3;
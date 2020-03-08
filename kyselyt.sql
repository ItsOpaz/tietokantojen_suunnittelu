-- kampanjan laskun kokonaissumma

-- kampanjan yhteyshenkilö

-- kampanjan mainokset

-- mainoksen kokonaisesitysika

select  mk.nimi, m.nimi, esitys.pvm, esitys.kloaika, k.sukupuoli, k.ika, k.maa, k.paikkakunta from mainos m, mainoskampanja mk, yhdiste_kampanja yk, esitys, kuuntelija k where
m.kampanjaid = mk.kampanjaid and mk.kampanjaid = yk.kampanjaid and m.mainosid = 1;

select  mk.nimi as kampanja, m.nimi as mainos, ma.nimi as mainostaja, e.pvm, e.kloaika, k.sukupuoli, k.ika, k.maa, k.paikkakunta from
mainos m inner join mainoskampanja mk on m.kampanjaid = mk.kampanjaid
inner join yhdiste_kampanja yk on yk.kampanjaid = m.kampanjaid
inner join esitys e on e.mainosid = m.mainosid
inner join kuuntelija k on k.nimimerkki = e.kuuntelijatunnus
left join mainostaja ma on ma.vat = yk.mainostajaid
where m.mainosid = 1
;

select  mk.nimi as kampanja, m.nimi as mainos, ma.nimi as mainostaja from
mainos m inner join mainoskampanja mk on m.kampanjaid = mk.kampanjaid
inner join yhdiste_kampanja yk on yk.kampanjaid = m.kampanjaid
left join mainostaja ma on ma.vat = yk.mainostajaid
where m.mainosid = 1
;
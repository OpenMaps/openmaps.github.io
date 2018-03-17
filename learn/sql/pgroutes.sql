alter table public.nairobi_roads add column source integer;
alter table public.nairobi_roads add column target integer;
select pgr_createTopology('public.nairobi_roads', 0.0001, 'geom', 'gid');

SELECT * from pgr_dijkstra(
    'SELECT "gid" as id, 
    "source"::integer as source, 
    "target"::integer as target, 
    "pglength"::double precision as cost 
    FROM public.nairobi_roads',
    3000, 7000, false, false
  );
  
  ----or
SELECT seq, id1 AS node, id2 AS edge, cost
from pgr_dijkstra(
    'SELECT "gid" as id, 
    "source"::integer as source, 
    "target"::integer as target, 
    "pglength"::double precision as cost 
    FROM public.nairobi_roads',
    3000, 7000, false, false
  ) as di
JOIN public.nairobi_roads pt
  ON di.id2 = pt.gid ;

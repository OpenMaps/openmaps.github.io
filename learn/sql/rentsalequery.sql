SELECT
	hse_status.status AS status, 
	hse_status.type AS property_type, 
	keja.terms AS rent_terms, 
	keja.min_price,
	keja.max_price,
	keja.bedrums as Bedrooms,
	keja.comments,
	keja.lat as Latitude,
	keja.llong as Longitude,
	contacts.agent_no as Mobile,
	contacts.agent_email as Email,
	contacts.owner_no as Mobile,
	contacts.owner_email as Email,
	pics.imag as Image,
	pics.clips as Virtual_Reality
	
FROM
	openkeja.keja, 
	openkeja.hse_status, 
	openkeja.contacts,
	openkeja.pics
	
WHERE
	hse_status.status_id = keja.status_id
	and
	contacts.contacts_id = keja.contacts_id 
	AND
	pics.pics_id = keja.pics_id;

delimiter |

create procedure proc_process_invoice(
	in salesperson_id integer,
	in inv_id integer,
	in quantity integer,
	inout in_stock integer,
	inout remain integer,
	inout price decimal(10,2),
	inout discount decimal(10,2),
	inout pre_tax decimal(10,2),
	inout tax decimal (10,2),
	inout subtotal decimal (10,2),
	inout comment text
	)
	begin
	select x.in_stock, x.price into in_stock, price from inventory as x
		where inventory_id = inv_id;
	if (in_stock - quantity >=0 ) then /*--okay to complete transaction*/
		set discount = if (quantity >= 12, 10, 0);
		set pre_tax = (price*quantity)*(1-(discount/100));
		set tax = pre_tax*0.085;
		set subtotal = pre_tax + tax;
		set remain = in_stock - quantity;
		update inventory set in_stock = remain where inventory_id = inv_id;
	else  /*--not enough of this in stock*/
		set remain = in_stock;
		set comment = 'Insufficient stock';
	end if;
end|


create trigger `before_update_invoice`
before update on `invoice`
for each row
begin
	call proc_process_invoice(
		new.salesperson_id,
		new.inventory_id,
		new.quantity,
		new.in_stock,
		new.remain,
		new.price,
		new.discount,
		new.pre_tax,
		new.tax,
		new.subtotal,
		new.comment);
end|

create or replace view invoice_view as select
	concat( se.first_name,'',se.last_name) as Salesperson,
	inv.description as Item,
	iv.quantity as Quantity,
	iv.in_stock as `In Stock`,
	iv.remain as Remain,
	iv.price as Price,
	iv.discount as `Discount %`,
	iv.pre_tax as Pretax,
	iv.tax as Tax,
	iv.subtotal as Subtotal,
	iv.comment as Comment
	from invoice as iv
	left join inventory as inv on iv.inventory_id = inv.inventory_id
	left join salespeople as se on iv.salesperson_id = se.salesperson_id;
	
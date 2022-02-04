USE LAB11_DB
GO

CREATE UNIQUE NONCLUSTERED INDEX category_name_index ON Categories (name)
GO

CREATE UNIQUE CLUSTERED INDEX orders_info_index ON orders_info_view (user_id, proceed_date)

CREATE NONCLUSTERED  INDEX orders_price_index ON orders_info_view (price DESC, size DESC) include (user_id)
GO
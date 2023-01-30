# load data lake
use kimia_farma;
select * from pelanggan;
select * from penjualan;
select * from barang;

# membuat schema untuk divisi SBU MARKETING DAN SALES FARMA
create schema if not exists sales_farma;

# membuat base table bernama Invoice_basetable sebagai data warehouse, disimpan di schema sales_farma
# Tabel base merupakan tabel dari hasil penggabungan 3 tabel 
create table sales_farma.Invoice_baseTable as (
select 
pen.id_invoice,
pen.id_customer, 
pen.id_barang, 
pel.id_cabang_sales, 
bar.kode_lini, 
pen.tanggal, 
pel.nama,
pel.grup,
pel.cabang_sales,
bar.nama_barang,
pen.jumlah_barang, 
pen.harga,
pen.unit,
(jumlah_barang * pen.harga) as total_harga_per_barang,
pen.mata_uang,
bar.tipe,
bar.lini
from penjualan pen
left join pelanggan pel
on pen.id_customer = pel.id_customer
left join barang bar
on pen.id_barang = bar.kode_barang);

# menggunakan schema sales_farma
use sales_farma;
select * from invoice_basetable;

# membuat aggregate table bernama penjualan_harian sebagai data mart
# disimpan dalam schema sales_farma
# aggregate table merupakan turunan dari base table dimana data dikelompokkan berdasarkan:
# tanggal, id_customer dan id_invoice 
create table sales_farma.penjualan_harian_aggregateTable as (
select id_invoice, tanggal,
id_customer, nama, cabang_sales,
id_barang, grup,
count(distinct id_barang) total_barang, sum(total_harga_per_barang) total_pembelian
from invoice_basetable
group by 1,2,3,4,5,6,7
order by 1);

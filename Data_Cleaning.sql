select * from Nashville_Housing; # checking the entire data
set SQL_Safe_updates = 0; #Enabling updates
-- ------Date update-----
UPDATE Nashville_Housing 
SET SaleDate = (date_format(str_to_date(SaleDate,'%M %d, %Y'), '%Y-%m-%d'));

select SaleDate, date_format(str_to_date(SaleDate,'%M %d, %Y'), '%Y-%m-%d') 
from Nashville_Housing;

-- ------propertyAddress transformation-----
select PropertyAddress 
from Nashville_Housing;

select substring_index(PropertyAddress, ' ', 1)
as street_number, substring_index(PropertyAddress, ',', 1 )
as street_name, substring_index(PropertyAddress, ',', -1 )
as City, substring_index(street_name, ' ', -2 )
from Nashville_Housing;
#first inserting a city column 
Alter table Nashville_Housing  
add City varchar(20);
#Now populating the city column with the substring from PropertyAddress
update Nashville_Housing
set City = substring_index(PropertyAddress, ',', -1 );

#first inserting a street_number column 
Alter table Nashville_Housing  
add Street_Number varchar(20);
#Now populating the Street_number column with the substring from PropertyAddress
update Nashville_Housing
set Street_Number = substring_index(PropertyAddress, ' ', 1);

#first inserting a street column, note we only need this to extract street_name from it 
Alter table Nashville_Housing  
add Street varchar(40);
#Now populating the Street_number column with the substring from PropertyAddress
update Nashville_Housing
set Street = substring_index(PropertyAddress, ',', 1 )

#first inserting a street_name column 
Alter table Nashville_Housing  
add Street_Name varchar(40);
#Now populating the Street_number column with the substring from PropertyAddress
update Nashville_Housing
set Street_Name = substring_index(Street, ' ', -3 );

select * from Nashville_Housing;

-- ---this only works in MS SQL Server --select parsename(replace(OwnerAddress, ',','.') from Nashville_Housing;

select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, 
ifnull(a.PropertyAddress, b.PropertyAddress) 
from Nashville_Housing a join Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress = '';

update a  
set PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress) 
from Nashville_Housing a join Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress = '';

select distinct(SoldAsVacant) from Nashville_Housing;
-- ----converting all SoldAsVacant with N and Y to Yes and No------
select
Case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
from Nashville_Housing;

Update Nashville_Housing set SoldAsVacant = 
Case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End;

-- -----Removing Duplicates----

With RowNumCTE as (select *, 
Row_Number() over (partition BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by
UniqueID) RowNum
from Nashville_Housing)
select * from RowNumCTE where RowNum>1
order by PropertyAddress;




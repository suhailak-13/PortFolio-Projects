
/*
DATA CLEANING 
*/
select *
from PortfoliaProject..NashvilleHousing;

-----------------------------------------------------------

-- 


select SaleDate,convert(date,SaleDate)
from PortfoliaProject..NashvilleHousing;

Update PortfoliaProject..NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate); -- tried converting it into date directly didn't worked

alter table NashvilleHousing
Add SaleDateConverted Date;

select *
from PortfoliaProject..NashvilleHousing;

Update PortfoliaProject..NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate); 

select SaleDateConverted,SaleDate
from PortfoliaProject..NashvilleHousing;

---------------------------------------------------------------------------------------

-- Populating Property address

select *
from PortfoliaProject..NashvilleHousing
where PropertyAddress is null; -- shows all the property address when it is null


select *
from PortfoliaProject..NashvilleHousing
order by OwnerName;-- to check some coorelation couldn't find any

select *
from PortfoliaProject..NashvilleHousing
order by ParcelID;-- this gives is the corelation to fill all those null property address as the parcel is used to deliver


select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress) as checking_address -- isnull provides to fill all the values in property address 
from PortfoliaProject..NashvilleHousing A
join PortfoliaProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null 



update A
set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from PortfoliaProject..NashvilleHousing A
join PortfoliaProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null



select *
from PortfoliaProject..NashvilleHousing
where PropertyAddress is null; -- returns 0 rows now

--------------------------------------------------------------------------------

-- Breaking out Property and Owner Address into Address,City,State

select *
from PortfoliaProject..NashvilleHousing;

select PropertyAddress
from PortfoliaProject..NashvilleHousing;


select LegalReference,
SUBSTRING(LegalReference,1,CHARINDEX('-',LegalReference))
from PortfoliaProject..NashvilleHousing;

select LegalReference,
SUBSTRING(LegalReference,1,CHARINDEX('-',LegalReference)-1)
from PortfoliaProject..NashvilleHousing;


select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address -- Charindex is just going to the column and removing the values after the comma
from PortfoliaProject..NashvilleHousing;

select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address -- -1 is to just remove the comma
from PortfoliaProject..NashvilleHousing;

select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as City
from PortfoliaProject..NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfoliaProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1); 

alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfoliaProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)); 

select PropertyAddress,PropertySplitAddress,PropertySplitCity
from PortfoliaProject..NashvilleHousing

select OwnerAddress
from PortfoliaProject..NashvilleHousing;

select OwnerAddress,
PARSENAME(OwnerAddress,1)
from PortfoliaProject..NashvilleHousing;

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from PortfoliaProject..NashvilleHousing;-- this shows in the order of state,city,address

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfoliaProject..NashvilleHousing;

alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfoliaProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3); 

alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfoliaProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2); 

alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfoliaProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1); 

select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from PortfoliaProject..NashvilleHousing;

--------------------------------------------------------------------------------

--convertijing Y to Yes and N to No isn SOld as Vacnt
--

select * from PortfoliaProject..NashvilleHousing;


select SoldAsVacant
from PortfoliaProject..NashvilleHousing;

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfoliaProject..NashvilleHousing
group by SoldAsVacant
order by 2; 

/*

o/p of the above table
Y    52
N	399
Yes	4623
No	51403
*/

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
	end
from PortfoliaProject..NashvilleHousing

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
	end
from PortfoliaProject..NashvilleHousing
where SoldAsVacant in ('Y','N')

update PortfoliaProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
	end;

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfoliaProject..NashvilleHousing
group by SoldAsVacant
order by 2; 

/*
o/p now
Yes	4675
No	51802	
*/

--------------------------------------------------
-- Removing Duplicates


select *
from PortfoliaProject..NashvilleHousing;

select *,ROW_NUMBER() over(partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from PortfoliaProject..NashvilleHousing;

with RowNumCTE as(
select *,ROW_NUMBER() over(partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from PortfoliaProject..NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num >1
Order by PropertyAddress; -- anything with row_num>1 is a duplicate 104 duplicates found

with RowNumCTE as(
select *,ROW_NUMBER() over(partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from PortfoliaProject..NashvilleHousing
--order by ParcelID
)
delete from RowNumCTE
where row_num >1;

with RowNumCTE as(
select *,ROW_NUMBER() over(partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from PortfoliaProject..NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num >1
Order by PropertyAddress;-- 0 records found

---------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfoliaProject..NashvilleHousing;

-- removing columns as i see fit not required for any further use
-- OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

Alter table PortfoliaProject..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate;

select *
from PortfoliaProject..NashvilleHousing;

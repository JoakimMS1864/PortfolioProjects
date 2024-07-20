select*
from dbo.NashvilleHousing

-- Converting Date format

Select SaleDateConverted, Convert(Date, Saledate)
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

-- Populate property address data

Select *
From dbo.NashvilleHousing
--where propertyaddress is null
order by parcelID

Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
From dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
From dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

-- Breaking out address into individual columns (Address, City, State)

Select propertyaddress
From dbo.NashvilleHousing
--where propertyaddress is null
--order by parcelID

select
substring(propertyaddress,1, charindex(',', propertyaddress)-1) as address, 
substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) as address
from dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertysplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertysplitAddress = substring(propertyaddress,1, charindex(',', propertyaddress)-1)

Alter Table NashvilleHousing
Add PropertysplitCity nvarchar(255);

Update NashvilleHousing
Set PropertysplitCity = substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress))

select owneraddress
from dbo.NashvilleHousing

select
parsename(replace(owneraddress,',','.'),3) as Streetname
,parsename(replace(owneraddress,',','.'),2) as City
,parsename(replace(owneraddress,',','.'),1) as US_State
from dbo.NashvilleHousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(owneraddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnersplitCity = parsename(replace(owneraddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = parsename(replace(owneraddress,',','.'),1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from dbo.NashvilleHousing

-- Changing Y & N to Yes & No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   end
from dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   end

-- Removing duplicates

with RowNumCTE as (
select*,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) Row_Num
from dbo.NashvilleHousing
--order by ParcelID
)
select*
from RowNumCTE
where Row_Num > 1
order by PropertyAddress


-- Deleting unsused Columns

select*
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table dbo.NashvilleHousing
drop column SaleDate
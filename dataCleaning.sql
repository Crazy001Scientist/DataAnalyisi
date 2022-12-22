

select *
FROM [data_cleaning].[dbo].[NashvilleHousing]

-- standardize date format
select SaleDateConverted
FROM [data_cleaning].[dbo].[NashvilleHousing]


Update NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table [data_cleaning].[dbo].[NashvilleHousing]
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


--populate property address data
select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, 
isnull(a.PropertyAddress, b.PropertyAddress)
FROM [data_cleaning].[dbo].[NashvilleHousing] a
join [data_cleaning].[dbo].[NashvilleHousing] b
   on a.ParcelID = b.ParcelID
   and a.ParcelID <> b.ParcelID
where a.PropertyAddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM [data_cleaning].[dbo].[NashvilleHousing] a
join [data_cleaning].[dbo].[NashvilleHousing] b
   on a.ParcelID = b.ParcelID
   and a.ParcelID <> b.ParcelID
where a.PropertyAddress is null


--breaking out address into individual columns (address, city, state)
select PropertyAddress, PropertySplitAddress, PropertyCityAddress
FROM [data_cleaning].[dbo].[NashvilleHousing]

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as state
FROM [data_cleaning].[dbo].[NashvilleHousing]


alter table [data_cleaning].[dbo].[NashvilleHousing]
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertyAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table [data_cleaning].[dbo].[NashvilleHousing]
add PropertyCityAddress nvarchar(255);

Update NashvilleHousing
set PropertyCityAddress = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

--Owner address
select OwnerAddress, OwnerPropertySplitAddress, OwnerPropertyCityAddress,
OwnerPropertyStateAddress
FROM [data_cleaning].[dbo].[NashvilleHousing]

alter table [data_cleaning].[dbo].[NashvilleHousing]
add OwnerPropertySplitAddress nvarchar(255),
OwnerPropertyCityAddress nvarchar(255),
OwnerPropertyStateAddress nvarchar(255);

Update NashvilleHousing
set OwnerPropertySplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
set OwnerPropertyCityAddress = parsename(replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
set OwnerPropertyStateAddress = parsename(replace(OwnerAddress, ',', '.'), 1)


--change Y and N to Yes and NO in "sold as Vacant" field
select SoldAsVacant,
case 
     when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end
FROM [data_cleaning].[dbo].[NashvilleHousing]

update NashvilleHousing
set SoldAsVacant = 
case 
     when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end

--remove duplicates
with RowNumCTE as(
select *,
    ROW_NUMBER() over (
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				    UniqueID
					) row_num

FROM [data_cleaning].[dbo].[NashvilleHousing]
)

delete
from RowNumCTE
where row_num > 1

--delete unused columns
select *
FROM [data_cleaning].[dbo].[NashvilleHousing]

alter table [data_cleaning].[dbo].[NashvilleHousing]
drop column OwnerAddress, TaxDistrict, PropertyAddress

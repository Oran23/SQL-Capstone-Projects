/* 

Cleaning Data in SQL Queries

*/

select * from portfolio_project_1..NashvilleHousing

--Standardise Date Format

select SaleDateConverted, convert(date,SaleDate)
from portfolio_project_1..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

--------------------------------------------------------------

-- Populate Property Address Data

select *
from portfolio_project_1..NashvilleHousing 
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio_project_1..NashvilleHousing a
join portfolio_project_1..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio_project_1..NashvilleHousing a
join portfolio_project_1..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------

-- Breaking Out Address Into Indivdaual Columns (Address, City, State)

select PropertyAddress
from portfolio_project_1..NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address
,substring(PropertyAddress, charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from portfolio_project_1..NashvilleHousing

Alter table portfolio_project_1..NashvilleHousing
add PropertySplitAddress nvarchar(255)

update portfolio_project_1..NashvilleHousing
set PropertySplitAddress= substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) 


Alter table portfolio_project_1..NashvilleHousing
add PropertySplitCity nvarchar(255)

update portfolio_project_1..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) 

select *
from portfolio_project_1..NashvilleHousing


select OwnerAddress
from portfolio_project_1..NashvilleHousing

select 
parsename(replace(OwnerAddress, ',', '.'),3)
,parsename(replace(OwnerAddress, ',', '.'),2)
,parsename(replace(OwnerAddress, ',', '.'),1)
from portfolio_project_1..NashvilleHousing 


Alter table portfolio_project_1..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update portfolio_project_1..NashvilleHousing
set OwnerSplitAddress= parsename(replace(OwnerAddress, ',', '.'),3)

Alter table portfolio_project_1..NashvilleHousing
add OwnerSplitCity nvarchar(255)

update portfolio_project_1..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),2)

Alter table portfolio_project_1..NashvilleHousing
add PropertySplitState nvarchar(255)

update portfolio_project_1..NashvilleHousing
set PropertySplitState = parsename(replace(OwnerAddress, ',', '.'),1)

--- Change Y and N to yes and no in "SoldAsVacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from portfolio_project_1..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case  when SoldAsVacant= 'Y' then 'Yes'
		when SoldAsVacant= 'N' then 'No'
		else SoldAsVacant
		end
from portfolio_project_1..NashvilleHousing

update portfolio_project_1..NashvilleHousing
set SoldAsVacant= case  when SoldAsVacant= 'Y' then 'Yes'
		when SoldAsVacant= 'N' then 'No'
		else SoldAsVacant
		end
		
	--------------------------------------------
	
-------- Remove Duplicates
 
 with RowNumCTE as(
 select *,
 row_number() over(
 partition by   parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by
				uniqueid
				) row_num
from portfolio_project_1..NashvilleHousing
--order by ParcelID
)

select * 
from RowNumCTE
where row_num > 1

---------------------------------------------------------

-- Delete Unused Columns

select *
from portfolio_project_1..NashvilleHousing

alter table portfolio_project_1..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table portfolio_project_1..NashvilleHousing
drop column saledate

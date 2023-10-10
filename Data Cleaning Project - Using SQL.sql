/*

Cleaning data using SQL queries

*/

select * from PortfolioProject..NashvilleHousing
----------------------------------------------------------------

--Extract Day data from SaleDate col and put it in a seperate col

Alter table PortfolioProject..NashvilleHousing
Add SaleDay int

update NashvilleHousing
set SaleDay =DAY(SaleDate)

select SaleDay
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------
--Populate Property Address Data where its null
--ParcelId is same for few properties where one has address and other doesnot have. So we can use this to generate address

--Query to find property address with null values
select NH1.ParcelID, NH1.PropertyAddress, Nh2.ParcelID, Nh2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
from PortfolioProject..NashvilleHousing NH1
inner join NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID and NH1.UniqueID <> NH2.UniqueID
Where NH1.PropertyAddress is null

--Query to update the property addess null values rows
Update NH1
Set PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
from PortfolioProject..NashvilleHousing NH1
inner join NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID and NH1.UniqueID <> NH2.UniqueID
Where NH1.PropertyAddress is null

-------------------------------------------------------------------------

--Query to Extract Address and State from PropertyAddress

Select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as State
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Varchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table PortfolioProject..NashvilleHousing
Add PropertySplitState varchar(255)

Update PortfolioProject..NashvilleHousing
set PropertySplitState = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

---------------------------------------------------------------------------

--Query to Extract Address,State & City from OwnerAddress

select OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress, ',','.'),2) as State,
PARSENAME(Replace(OwnerAddress, ',','.'),1) as City
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress varchar(255),
	OwnerSplitState varchar(255),
	OwnerSplitCity varchar(255)


Update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3), OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),2),
OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),1)

--------------------------------------------------------------------------

-- Convert SoldasVacant to String and Change 0 to No and 1 to Yes 

select soldasvacant, count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by soldasvacant

Alter table PortfolioProject..NashvilleHousing
alter column soldasvacant varchar(25)

Select soldasvacant,
Case soldasvacant
	When '0' then 'No'
	When '1' then 'Yes'
End
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant = Case soldasvacant
	When '0' then 'No'
	When '1' then 'Yes'
End

--------------------------------------------------------------------------

--Find Duplicate rows

With CTE_DuplicateRows as(
select *,
ROW_NUMBER() over (Partition By Parcelid, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueId) As Row_Num
from PortfolioProject..NashvilleHousing)
select * from 
CTE_DuplicateRows
Where Row_Num>1

--------------------------------------------------------------------------

--Remove unused columns
--Just a demo, we can use this to delete cols in views. Not recommended to delete cols from original DB

ALter table PortfolioProject..NashvilleHousing
Drop column TaxDistrict, Acreage
/* 

Cleaning Data in SQL Queries 
Skills Used: Join, ISNULL, Parsename, Substring, Case, Partition, CTE, Update and Alter

*/

Select *
From PortfolioProject..NashvilleHousing 

-----------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate2, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing 

Alter table NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
Set SaleDate2 = Convert(Date, SaleDate)


--------------------------------------------------------------------------------------

-- Populate Property Address Data


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a 
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
	-- Address and ParcelID are unique so if address is null but has same ParcelID as not null address
	-- then set null to corresponding address for that same ParcelID
	-- UniqueID is different for each row so we do not want to have duplicates
where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing as a 
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is not null


----------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


--Using Substring for Property Address Split

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(250);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(250);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, Len(PropertyAddress))



-- Using Parsename for Owner Address Split
Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(250);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(250);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(250);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field using Case

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
				when SoldAsVacant = 'N' then 'No'
				Else SoldAsVacant
				End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

-------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (not standard practice, done just for Portfolio) using CTE, Row_Number(), Partition and Delete

With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID) row_num
	-- Duplicate data from the specified partition yields row number greater than 1

From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns using 'Drop Column'

Alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Alter table NashvilleHousing
Drop Column SaleDate



Select *
From PortfolioProject..NashvilleHousing

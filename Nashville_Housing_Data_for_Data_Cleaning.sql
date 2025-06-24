/*
DATA CLEANING

*/

use PortfolioProject ;

Select * from NashvilleHousing

--Fixing the SaleDate
 Select SaleDate from NashvilleHousing

 Alter table NashvilleHousing
 Add Dateconverted date

 Update NashvilleHousing
 SET DateConverted = CONVERT(Date,SaleDate)



 --Populating property address data where there is no value
 --Joining table with the same table to find PropertyAddress with No value but same parcelID and populate it after
 Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  from PortfolioProject.dbo.NashvilleHousing a
 Join PortfolioProject.dbo.NashvilleHousing b
 On a.ParcelID = b.ParcelID
 and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

Update a
Set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
  from PortfolioProject.dbo.NashvilleHousing a
 Join PortfolioProject.dbo.NashvilleHousing b
 On a.ParcelID = b.ParcelID
 and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

Select * from NashvilleHousing
where PropertyAddress is NULL



--MAking adress look clean
Select PropertyAddress from NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from NashvilleHousing

 Alter table NashvilleHousing
 Add PropertySplitAddress nvarchar(255)

 Update NashvilleHousing
 SET PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


  Alter table NashvilleHousing
 Add PropertySplitCity nvarchar(255)

 Update NashvilleHousing
 SET PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


 Select * from NashvilleHousing


 --Splitting OwnerAdress using ParseName
 Select
 PARSENAME(Replace(OwnerAddress,',','.'),3) ,
 PARSENAME(Replace(OwnerAddress,',','.'),2) ,
PARSENAME(Replace(OwnerAddress,',','.'),1)

 from NashvilleHousing

  Alter table NashvilleHousing
 Add OwnerSplitAddress nvarchar(255)

 Update NashvilleHousing
 SET OwnerSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'),3)


  Alter table NashvilleHousing
 Add OwnerSplitCity nvarchar(255)

 Update NashvilleHousing
 SET OwnerSplitCity =PARSENAME(Replace(OwnerAddress,',','.'),2)

   Alter table NashvilleHousing
 Add OwnerSplitState nvarchar(255)

 Update NashvilleHousing
 SET OwnerSplitState =PARSENAME(Replace(OwnerAddress,',','.'),1)


 --Changing Y into Yes and N into No in SoldAsVacant Field

 Select Distinct(SoldAsVacant)
 from NashvilleHousing

 --Using Case statement
 
 Select SoldAsVacant
,Case when SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
      Else SoldAsVacant
      End
from NashvilleHousing

Update NashvilleHousing
Set
SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
      Else SoldAsVacant
      End  
      


      ---Removing Duplicates
     With ROwNumCTE As
     (Select *,
      ROW_NUMBER() Over(
      Partition by ParcelID, 
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   Order by UniqueID)row_num
                   From NashvilleHousing
                   )

                  /*Delete from ROwNumCTE
                   Where row_num>1
                   --order by PropertyAddress*/

                   Select * from ROwNumCTE
                   Where row_num>1

                   --Deleting Unused columns

                   Select * from NashvilleHousing
                   Alter table NashvilleHousing
                   Drop Column
                   OwnerAddress, taxDistrict,PropertyAddress, SaleDate
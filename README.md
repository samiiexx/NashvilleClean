# NashvilleClean

The raw data was cleaned and the following was done to clean the data:

Null PropertyAddress was populated and split into PropertySplitAddress & PropertySplitCity using the Substring method.
OwnerAddress was split into OwnerSplitAddress, OwnerSplitCity & OwnerSplitState using the Parse method.
Y & N in SoldAsVacant was changed to Yes & No.
All duplicates were removed.

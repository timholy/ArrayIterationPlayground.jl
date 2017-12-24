const IterIndex = Union{Int,UnitRange{Int},Colon}

# isindex == true  => want the indexes (keys) of the array
# isindex == false => want the values of the array
# isstored == true  => visit only stored entries
# isstored == false => visit all indexes
struct ArrayIndexingWrapper{A, I<:Tuple{Vararg{IterIndex}}, isindex, isstored}
    data::A
    indexes::I
end

# Internal type for storing instantiated index iterators but returning
# array values
struct ValueIterator{A<:AbstractArray,I}
    data::A
    iter::I
end

struct SyncedIterator{I,F<:Tuple{Vararg{Function}}}
    iter::I
    itemfuns::F
end

const ArrayOrWrapper  = Union{AbstractArray,ArrayIndexingWrapper}
const AllElements{A,I,isindex} = Union{AbstractArray,ArrayIndexingWrapper{A,I,isindex,false}}
const StoredElements{A,I,isindex} = ArrayIndexingWrapper{A,I,isindex,true}

# storageorder has to be type-stable because it controls the output of
# sync, which is used in iteration
abstract type StorageOrder end
struct FirstToLast <: StorageOrder end
struct OtherOrder{p} <: StorageOrder end
struct NoOrder <: StorageOrder end  # combination of reshape+permutedims=>undefined

# For iterating over the *values* of an array in column-major order
struct FirstToLastIterator{N,AA}
    parent::AA
    itr::CartesianRange{N}
end

# Contiguous ranges
abstract type Contiguity end
struct Contiguous <: Contiguity end
struct NonContiguous <: Contiguity end
struct MaybeContiguous <: Contiguity end  # intermediate type used in assessing contiguity

# Contiguous cartesian ranges. Sometimes needed for LinearSlow arrays.
struct ContigCartIterator{N}
    arrayrange::CartesianRange{N}
    columnrange::CartesianRange{N}
end

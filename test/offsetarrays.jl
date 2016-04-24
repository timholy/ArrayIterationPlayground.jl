# A type to test unconventional indexing ranges

module OAs  # OffsetArrays

import ArrayIterationPlayground: inds

immutable OA{T,N,AA<:AbstractArray} <: AbstractArray{T,N}
    parent::AA
    offsets::NTuple{N,Int}
end

OA{T,N}(A::AbstractArray{T,N}, offsets::NTuple{N,Int}) = OA{T,N,typeof(A)}(A, offsets)

Base.parent(A::OA) = A.parent
Base.size(A::OA) = size(parent(A))
inds(A::OA, d) = (1:size(parent(A),d))+A.offsets[d]
Base.eachindex(A::OA) = CartesianRange(inds(A))

Base.getindex(A::OA, inds::Int...) = parent(A)[offset(A.offsets, inds)...]
Base.setindex!(A::OA, val, inds::Int...) = parent(A)[offset(A.offsets, inds)...] = val

offset{N}(offsets::NTuple{N,Int}, inds::NTuple{N,Int}) = _offset((), offsets, inds)
_offset(out, ::Tuple{}, ::Tuple{}) = out
@inline _offset(out, offsets, inds) = _offset((out..., inds[1]-offsets[1]), Base.tail(offsets), Base.tail(inds))

end

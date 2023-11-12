
package ds

import "core:intrinsics"
import "core:runtime"

/*
    Closure table implementation.
    
    This file implements a tree storage for simple types that looks something
    like this:
    
    depth    parent   child                     0       <-- not stored
    -----    ------   -----                  __/ \
        0         0       1                 / /   \
        0         0       2               1   2    5    <-- depth=0
        1         2       3                __/
        1         2       4               / / 
        0         0       5              3  4           <-- depth=1
    
    The idea is that we store the parent-child relationships in the table
    together with the depth. Looping over all the ancestors recursively becomes
    trivial and doesn't involve actual recursion.
*/

@(private)
Clorec :: struct($T: typeid) {
    parent: T,
    child:  T,
    depth:  i16,
}

Clotab :: struct($T: typeid) {
    recs: [dynamic]Clorec(T),
}

Clotab_Iter :: struct {
    index: int,
    depth: i16,
    // This takes no space, it's sole purpose is to
    // abuse zero-initialization.
    ok:    b16,
}

clotab_create :: proc(ct: ^Clotab($T), allocator := context.allocator, loc := #caller_location) {
    ct.recs = make_dynamic_array([dynamic]Clorec(T), allocator, loc)
}

clotab_delete :: proc(ct: ^Clotab($T), loc := #caller_location) {
    delete_dynamic_array(ct.recs, loc)
}

clotab_root :: proc(ct: ^Clotab($T)) -> T {
    return T{}
}

clotab_insert :: proc(ct: ^Clotab($T), parent: T, child: T, loc := #caller_location) {
    // Check whether we're inserting at parent or at tree root.
    if parent != {} {
        parent_idx := Maybe(int){}
        parent_dpt := i16(-1)
        // Find the specified parent and it's tree depth.
        for rec, idx in ct.recs {
            if rec.child == parent {
                parent_idx = idx
                parent_dpt = rec.depth
            }
        }
        if parent_idx == nil {
            panic("Inserting at unknown parent.", loc)
        }
        // Scan the table until we find the next parent.
        idx := parent_idx.?
        for idx < len(ct.recs) && ct.recs[idx].depth == parent_dpt {
            idx += 1
        }
        // Insert a new record at the found index.
        inject_at(&ct.recs, idx, Clorec(T) {
            parent = parent,
            child  = child,
            depth  = parent_dpt + 1,
        })
    } else {
        append(&ct.recs, Clorec(T) {
            parent = parent,
            child  = child,
            depth  = 1,
        })
    }
}

clotab_parent :: proc(ct: ^Clotab($T), child: T) -> T {
    for rec in ct.recs {
        if rec.child == child {
            return rec.parent
        }
    }
    return clotab_root(ct)
}

clotab_remove :: proc(ct: ^Clotab($T), node: T, loc := #caller_location) {
    // Find the index of the node.
    first_idx_maybe: Maybe(int) = nil
    depth := i16(0)
    for rec, idx in ct.recs {
        if rec.child == node {
            first_idx_maybe = idx
            depth = rec.depth
        }
    }
    if first_idx_maybe == nil {
        panic("Removing element not in the tree", loc)
    }
    first_idx := first_idx_maybe.?
    // Scan entries until we reach the next node at the same
    // depth.
    last_idx := first_idx + 1
    for last_idx < len(ct.recs) && ct.recs[last_idx].depth > depth {
        last_idx += 1
    }
    // Remove all elements between the first and last index.
    removed_count := last_idx - first_idx
    copy(ct.recs[first_idx:len(ct.recs)-removed_count], ct.recs[last_idx:])
    (^runtime.Raw_Dynamic_Array)(&ct.recs).len -= removed_count
}

clotab_iterate_preorder :: proc(
    ct:     ^Clotab($T),
    iter:   ^Clotab_Iter,
    start:  T,
    loc:  = #caller_location) -> (Clorec(T), int, bool)
{
    if !iter.ok {
        iter.ok = true
        if (start != T{}) {
            for rec, idx in ct.recs {
                if rec.child == start {
                    iter.index = idx+1
                    iter.depth = rec.depth
                    return rec, idx, true
                }
            }
            panic("Couldn't find iteration start", loc)
        } else {
            iter.index = 1
            iter.depth = 0
            return ct.recs[0], 0, true
        }
    }
    if iter.index < len(ct.recs) && ct.recs[iter.index].depth > iter.depth {
        defer iter.index += 1
        return ct.recs[iter.index], iter.index, true
    }
    return {}, 0, false
}

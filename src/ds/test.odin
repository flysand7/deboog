
package ds

import "core:testing"

@test
test_closure_table :: proc(t: ^testing.T) {
    tbl: Clotab(int)
    clotab_create(&tbl)
    clotab_insert(&tbl, clotab_root(&tbl), 1)
    clotab_insert(&tbl, 1, 3)
    clotab_insert(&tbl, 3, 4)
    clotab_insert(&tbl, 3, 5)
    clotab_insert(&tbl, clotab_root(&tbl), 2)
    clotab_insert(&tbl, 2, 6)
        
    testing.expect(t, tbl.recs[2].child == 5)
    clotab_remove(&tbl, 5)
    testing.expect(t, tbl.recs[2].child == 4)
}

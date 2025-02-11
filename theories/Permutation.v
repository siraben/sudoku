(* This program is free software; you can redistribute it and/or      *)
(* modify it under the terms of the GNU Lesser General Public License *)
(* as published by the Free Software Foundation; either version 2.1   *)
(* of the License, or (at your option) any later version.             *)
(*                                                                    *)
(* This program is distributed in the hope that it will be useful,    *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of     *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *)
(* GNU General Public License for more details.                       *)
(*                                                                    *)
(* You should have received a copy of the GNU Lesser General Public   *)
(* License along with this program; if not, write to the Free         *)
(* Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA *)
(* 02110-1301 USA                                                     *)


(**********************************************************************
    Permutation.v

    Definition and properties of permutations

    Definition: permutation

                                    Laurent.Thery@inria.fr (2006)
 **********************************************************************)
Require Export List.
Require Export ListAux.
From Coq Require Export Permutation.

Section permutation.
Variable A : Set.

Hint Constructors Permutation : core.

(**************************************
 A transposition is a permutation
 **************************************)

Theorem perm_transposition :
  forall a b (l1 l2 l3 : list A),
    Permutation (l1 ++ a :: l2 ++ b :: l3) (l1 ++ b :: l2 ++ a :: l3).
Proof.
  intros a b l1 l2 l3.
  apply Permutation_app; auto.
  change
    (Permutation ((a :: nil) ++ l2 ++ (b :: nil) ++ l3)
                 ((b :: nil) ++ l2 ++ (a :: nil) ++ l3)) in |- *.
  repeat rewrite <- app_ass.
  apply Permutation_app; auto.
  apply perm_trans with ((b :: nil) ++ (a :: nil) ++ l2); auto.
  apply Permutation_app_comm; auto.
  repeat rewrite app_ass.
  apply Permutation_app; auto.
  apply Permutation_app_comm; auto.
Qed.

(**************************************
 An element of a list can be put on top of the list to get a permutation
 **************************************)

Theorem in_permutation_ex :
  forall a l, In a l -> exists l1 : list A, Permutation (a :: l1) l.
Proof.
  intros a l; elim l; simpl in |- *; auto.
  intros H; case H; auto.
  intros a0 l0 H [H0| H0].
  exists l0; rewrite H0; auto.
  case H; auto; intros l1 Hl1; exists (a0 :: l1).
  apply perm_trans with (a0 :: a :: l1); auto.
Qed.

(**************************************
 Take a list and return tle list of all pairs of an element of the
 list and the remaining list
 **************************************)

Fixpoint split_one (l : list A) : list (A * list A) :=
  match l with
  | nil => nil (A:=A * list A)
  | a :: l1 =>
    (a, l1)
      :: map (fun p : A * list A => (fst p, a :: snd p)) (split_one l1)
  end.

(**************************************
 The pairs of the list are a permutation
 **************************************)

Theorem split_one_permutation :
  forall (a : A) (l1 l2 : list A),
    In (a, l1) (split_one l2) -> Permutation (a :: l1) l2.
Proof.
  intros a l1 l2; generalize a l1; elim l2; clear a l1 l2; simpl in |- *; auto.
  intros a l1 H1; case H1.
  intros a l H a0 l1 [H0| H0].
  injection H0; intros H1 H2; rewrite H2, H1; auto.
  generalize H H0; elim (split_one l); simpl in |- *; auto.
  intros H1 H2; case H2.
  intros a1 l0 H1 H2 [H3| H3]; auto.
  injection H3; intros H4 H5; (rewrite <- H4, <- H5).
  apply perm_trans with (a :: fst a1 :: snd a1); auto.
  apply perm_skip.
  apply H2; auto.
  case a1; simpl in |- *; auto.
Qed.

(**************************************
 All elements of the list are there
 **************************************)

Theorem split_one_in_ex :
  forall (a : A) (l1 : list A),
    In a l1 -> exists l2 : list A, In (a, l2) (split_one l1).
Proof.
  intros a l1; elim l1; simpl in |- *; auto.
  intros H; case H.
  intros a0 l H [H0| H0]; auto.
  exists l; left; f_equal; auto.
  case H; auto.
  intros x H1; exists (a0 :: x); right; auto.
  apply
    (in_map (fun p : A * list A => (fst p, a0 :: snd p)) (split_one l) (a, x));
    auto.
Qed.

(**************************************
 An auxillary function to generate all permutations
 **************************************)

Fixpoint all_permutations_aux (l : list A) (n : nat) {struct n} :
  list (list A) :=
  match n with
  | O => nil :: nil
  | S n1 =>
    flat_map
      (fun p : A * list A =>
         map (cons (fst p)) (all_permutations_aux (snd p) n1)) (
        split_one l)
  end.
(**************************************
 Generate all the permutations
 **************************************)

Definition all_permutations (l : list A) := all_permutations_aux l (length l).

(**************************************
 All the elements of the list are permutations
 **************************************)

Lemma all_permutations_aux_permutation :
  forall (n : nat) (l1 l2 : list A),
    n = length l2 -> In l1 (all_permutations_aux l2 n) -> Permutation l1 l2.
Proof.
  intros n; elim n; simpl in |- *; auto.
  intros l1 l2; case l2.
  simpl in |- *; intros H0 [H1| H1].
  rewrite <- H1; auto.
  case H1.
  simpl in |- *; intros; discriminate.
  intros n0 H l1 l2 H0 H1.
  case in_flat_map_ex with (1 := H1).
  clear H1; intros x; case x; clear x; intros a1 l3 (H1, H2).
  case in_map_inv with (1 := H2).
  simpl in |- *; intros y (H3, H4).
  rewrite H4; auto.
  apply perm_trans with (a1 :: l3); auto.
  apply perm_skip; auto.
  apply H with (2 := H3).
  apply eq_add_S.
  apply trans_equal with (1 := H0).
  change (length l2 = length (a1 :: l3)) in |- *.
  apply Permutation_length; auto.
  apply Permutation_sym; apply split_one_permutation; auto.
  apply split_one_permutation; auto.
Qed.

Theorem all_permutations_permutation :
  forall l1 l2 : list A, In l1 (all_permutations l2) -> Permutation l1 l2.
Proof.
  intros l1 l2 H; apply all_permutations_aux_permutation with (n := length l2);
    auto.
Qed.

(**************************************
 A permutation is in the list
 **************************************)

Lemma permutation_all_permutations_aux :
  forall (n : nat) (l1 l2 : list A),
    n = length l2 -> Permutation l1 l2 -> In l1 (all_permutations_aux l2 n).
Proof.
  intros n; elim n; simpl in |- *; auto.
  intros l1 l2; case l2.
  intros H H0; rewrite (Permutation_nil (Permutation_sym H0)); auto with datatypes.
  simpl in |- *; intros; discriminate.
  intros n0 H l1; case l1.
  intros l2 H0 H1;
    rewrite (Permutation_nil H1) in H0;
    discriminate.
  clear l1; intros a1 l1 l2 H1 H2.
  case (split_one_in_ex a1 l2); auto.
  apply Permutation_in with (1 := H2); auto with datatypes.
  intros x H0.
  apply in_flat_map with (b := (a1, x)); auto.
  apply in_map; simpl in |- *.
  apply H; auto.
  apply eq_add_S.
  apply trans_equal with (1 := H1).
  change (length l2 = length (a1 :: x)) in |- *.
  apply Permutation_length; auto.
  apply Permutation_sym; apply split_one_permutation; auto.
  apply Permutation_cons_inv with (a := a1).
  apply perm_trans with (1 := H2).
  apply Permutation_sym; apply split_one_permutation; auto.
Qed.

Theorem permutation_all_permutations :
  forall l1 l2 : list A, Permutation l1 l2 -> In l1 (all_permutations l2).
Proof.
  intros l1 l2 H; unfold all_permutations in |- *;
    apply permutation_all_permutations_aux; auto.
Qed.

(**************************************
 Permutation is decidable
 **************************************)

Definition permutation_dec :
  (forall a b : A, {a = b} + {a <> b}) ->
  forall l1 l2 : list A, {Permutation l1 l2} + {~ Permutation l1 l2}.
  intros H l1 l2.
  case (In_dec (list_eq_dec H) l1 (all_permutations l2)).
  intros i; left; apply all_permutations_permutation; auto.
  intros i; right; contradict i; apply permutation_all_permutations; auto.
Defined.

(* A more efficient version *)
Definition permutation_dec1 :
  (forall a b : A, {a = b} + {a <> b}) ->
  forall l1 l2 : list A, {Permutation l1 l2} + {~ Permutation l1 l2}.
intros dec; fix perm 1; intros l1; case l1.
intros l2; case l2.
left; auto.
intros a l3; right; intros H; generalize (Permutation_length H);
 discriminate.
intros a l3 l2.
case (In_dec1 dec a l2); intros H1.
case H1.
intros x; case x; simpl.
intros l4 l5 Hl4l5.
case (perm l3 (l4 ++ l5)); intros H2.
left; subst.
apply perm_trans with ((a::l5) ++ l4); auto.
simpl; apply perm_skip; auto.
apply perm_trans with (1 := H2); auto.
apply Permutation_app_comm.
apply Permutation_app_comm.
right; contradict H2.
apply Permutation_cons_inv with a.
apply perm_trans with (1 := H2).
rewrite Hl4l5.
apply perm_trans with ((a::l5) ++ l4); auto.
apply Permutation_app_comm.
simpl; apply perm_skip; auto.
apply Permutation_app_comm.
right; contradict H1.
apply Permutation_in with (1 := H1); auto with datatypes.
Defined.

End permutation.

(**************************************
   Hints
 **************************************)

Global Hint Resolve Permutation_app : core.
Global Hint Resolve Permutation_app_comm : core.

(**************************************
   Implicits
 **************************************)

Arguments permutation_dec1 [A].

(**************************************
  Permutation  of a map can be inverted
 *************************************)

Lemma Permutation_map_ex_aux :
  forall (A B : Set) (f : A -> B) l1 l2 l3,
    Permutation l1 l2 ->
    l1 = map f l3 -> exists l4, Permutation l4 l3 /\ l2 = map f l4.
Proof.
  intros A B f l1 l2 l3 H H0.
  assert (exists l4 : list A, l2 = map f l4 /\ Permutation l4 l3).
  {
    rewrite H0 in H.
    apply Permutation_sym in H.
    epose proof (Permutation_map_inv f _ H).
    destruct H1; auto.
    now exists x.
  }
  destruct H1.
  now exists x.
Qed.

Theorem Permutation_map_ex :
  forall (A B : Set) (f : A -> B) l1 l2,
    Permutation (map f l1) l2 ->
    exists l3, Permutation l3 l1 /\ l2 = map f l3.
Proof.
  intros A0 B f l1 l2 H; apply Permutation_map_ex_aux with (l1 := map f l1);
    auto.
Qed.

(**************************************
   Permutation is compatible with flat_map
 **************************************)

Theorem permutation_flat_map :
  forall (A B : Set) (f : A -> list B) l1 l2,
    Permutation l1 l2 -> Permutation (flat_map f l1) (flat_map f l2).
Proof.
  intros A B f l1 l2 H; elim H; simpl in |- *; auto.
  intros a b l; auto.
  repeat rewrite <- app_ass.
  apply Permutation_app; auto.
  intros k3 l4 l5 H0 H1 H2 H3; apply perm_trans with (1 := H1); auto.
Qed.

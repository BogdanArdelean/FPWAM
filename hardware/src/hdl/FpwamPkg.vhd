package FpwamPkg is
  -- Possible address inputs for memory (eg: MA_H_t => Memory Address from register H)
  type mem_addr_input_t is (MA_H_t, MA_Hplus1_t, MA_deref_unit_t, MA_untag_deref_t, MA_bind_unit_t, MA_trail_unit_t,
                            MA_unify_unit_a_t, MA_unify_unit_b_t, MA_stack_addr_t. MA_S_t);
  -- Possible input sources for memory
  type mem_port_input_t is (MI_H_t, MI_tag_unit_t, MI_constant_t, MI_GPR_t, MI_bind_unit_t, MI_trail_unit_t, MI_unify_unit_a_t,
                            MI_unify_unit_b_t, MI_mem_port1_t, MI_mem_port2_t);
  -- Possible input sources for H register
  type h_input_t        is (HI_p1_t, HI_p2_t);
  -- Possible input sources for S register
  type s_input_t        is (SI_untag_deref_p1_t, SI_p1_t);
  -- Possible input sources for P register
  type p_input_t        is (PI_pinstr_size_t);
  -- Possible input sources for General Purpose Registers
  type GPR_input_t      is (GPRI_tag_unit_t, GPRI_mem_port1_t, GPRI_mem_port2_t);
  -- Possible input sources for deref unit
  type deref_input_t    is (DI_ai_t, DI_unify_unit_a_t, DI_unify_unit_b_t);
  -- Possible input sources for bind unit
  type bind_input_t     is (BI_deref_unit_t, BI_H_t);
  -- Possible input sources for trail unit
  type trail_input_t    is (TI_bind_output_t);
  -- WAM execution modes
  type wam_mode_t       is (mode_write_t, mode_read_t);
  -- Types of objects supported in WAM
  type tag_t            is (tag_str_t, tag_ref_t, tag_int_t, tag_lis_t);
  -- Unify unit input
  type unify_input_t    is (UI_S_t, UI_GPR_t, UI_mem_port1_t, UI_mem_port2_t);

  -- Maybe shoud create for tag unit the same thing?
  -- Currently isn't necessary.
end FpwamPkg;

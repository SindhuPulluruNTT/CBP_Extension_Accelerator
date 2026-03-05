managed with additional save implementation in class ZBP_I_POPRICINGCONDEXTT_S unique;
strict;
with draft;
define behavior for ZI_PoPricingConExtT_S alias PoPricingConditiAll
draft table zpr_tb_prext_d_s
with unmanaged save
lock master total etag LastChangedAtMax
authorization master ( global )
{
  field ( readonly )
  SingletonID;

  field ( features : instance )
  TransportRequestID;

  field ( notrigger )
  SingletonID,
  LastChangedAtMax;


  update;
  internal create;
  internal delete;

  draft action ( features : instance ) Edit with additional implementation;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;
  action ( features : instance ) SelectCustomizingTransptReq parameter D_SelectCustomizingTransptReqP result [1] $self;

  association _PoPricingConditionT { create ( features : instance ); with draft; }

  validation ValidateTransportRequest on save ##NOT_ASSIGNED_TO_DETACT { create; update; }

  side effects
  {
    action SelectCustomizingTransptReq affects $self;
  }

}

define behavior for ZI_PoPricingCondExtT alias PoPricingConditionT ##UNMAPPED_FIELD
persistent table zpr_tb_price_ext
draft table zpr_tb_po_pr_d
lock dependent by _PoPricingConditiAll
early numbering
authorization dependent by _PoPricingConditiAll
{
  field ( mandatory : create )
  CondType;
  //   Counter;

  field ( mandatory ) CondClass, CalcType, CondValue, EndDate,
  Low, Per, StartDate, Unit, Uom;

  field ( readonly )
  SingletonID,
  Counter;

  field ( features : instance )
  High;

  field ( readonly : update )
  CondType;
  //   Counter;

  field ( notrigger )
  SingletonID;


  update ( features : global );
  //  delete( features : global );
  action markdel;

  side effects
  {
    field Single affects field High;
  }

  factory action copyItem [1];

  mapping for zpr_tb_price_ext
    {
      CondType    = COND_TYPE;
      Counter     = COUNTER;
      CondClass   = COND_CLASS;
      CalcType    = CALC_TYPE;
      Single      = single_value;
      Low         = LOW;
      High        = HIGH;
      CondValue   = COND_VALUE;
      Unit        = UNIT;
      Per         = PER;
      Uom         = UOM;
      StartDate   = START_DATE;
      EndDate     = END_DATE;
      DeletionInd = DELETION_IND;
    }

  association _PoPricingConditiAll { with draft; }

  validation ValidateTransportRequest on save ##NOT_ASSIGNED_TO_DETACT { create; update; delete; }

}
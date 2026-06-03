managed with additional save implementation in class ZBP_I_MAPGLACCOUNTSTOCOND_S unique;
strict;
with draft;
define behavior for ZI_MapGlAccountsToCond_S alias MapGlAccountsToCAll
draft table ZPR_TB_GLMA_D_S
with unmanaged save
lock master total etag LastChangedAtMax
authorization master( global )
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

  association _MapGlAccountsToCond { create ( features : instance ); with draft; }

  validation ValidateTransportRequest on save ##NOT_ASSIGNED_TO_DETACT
  {
    create;
    update;
  }

  side effects
  {
    action SelectCustomizingTransptReq affects
        $self;
  }

}

define behavior for ZI_MapGlAccountsToCond alias MapGlAccountsToCond ##UNMAPPED_FIELD
persistent table ZPR_TB_GLMAP
draft table ZPR_TB_GLMAP_D
lock dependent by _MapGlAccountsToCAll
authorization dependent by _MapGlAccountsToCAll
{
  field ( mandatory : create )
   CondType;

  field ( readonly )
   SingletonID;

  field ( readonly : update )
   CondType;

  field ( notrigger )
   SingletonID;


  update( features : global );
  delete( features : global );

  mapping for ZPR_TB_GLMAP
  {
    CondType = COND_TYPE;
    DebitGl = DEBIT_GL;
    CreditGl = CREDIT_GL;
  }

  association _MapGlAccountsToCAll { with draft; }

  validation ValidateTransportRequest on save ##NOT_ASSIGNED_TO_DETACT
  {
    create;
    update;
    delete;
  }

}
managed with additional save implementation in class ZBP_BC_I_IMPL unique;
strict;
with draft;
define behavior for ZBS_I_SWCBC_S alias BusinessConfigAll
draft table ZBS_DMO_BCDS
with unmanaged save
lock master total etag LastChangedAtMax
authorization master( global )

{
  field ( readonly )
   SingletonID;

  field ( notrigger )
   SingletonID,
   HideTransport,
   LastChangedAtMax;


  update;
  internal create;
  internal delete;

  draft action ( features : instance ) Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare {
    validation BusinessConfigurati ~ ValidateDataConsistency;
  }
  action ( features : instance ) SelectCustomizingTransptReq parameter D_SelectCustomizingTransptReqP result [1] $self;

  association _BusinessConfigurati { create ( features : instance ); with draft; }
}

define behavior for ZI_BusinessConfigurati alias BusinessConfigurati
persistent table ZBS_DMO_BC
draft table ZBS_DMO_BC_D
etag master LocalLastChangedAt
lock dependent by _BusinessConfigAll
authorization dependent by _BusinessConfigAll

{
  field ( mandatory : create )
   ConfigId;

  field ( readonly )
   SingletonID,
   LastChangedAt,
   LocalLastChangedAt,
   ConfigDeprecationCode;

  field ( readonly : update )
   ConfigId;

  field ( notrigger )
   SingletonID,
   LastChangedAt,
   LocalLastChangedAt;


  update( features : global );
  delete( features : instance );

  action ( features : instance ) Deprecate result [1] $self;
  action ( features : instance ) Invalidate result [1] $self;
  factory action ( features : instance ) CopyBusinessConfigurati parameter ZBS_S_SWCCopyBCP [1];

  mapping for ZBS_DMO_BC
  {
    ConfigId = CONFIG_ID;
    Description = DESCRIPTION;
    IsUsed = IS_USED;
    IsMandatory = IS_MANDATORY;
    Processes = PROCESSES;
    WorkingClass = WORKING_CLASS;
    ConfigDeprecationCode = CONFIGDEPRECATIONCODE;
    LastChangedAt = LAST_CHANGED_AT;
    LocalLastChangedAt = LOCAL_LAST_CHANGED_AT;
  }

  association _BusinessConfigAll { with draft; }

  validation ValidateTransportRequest on save ##NOT_ASSIGNED_TO_DETACT { create; update; delete; }
  validation ValidateDataConsistency on save { create; update; }
}
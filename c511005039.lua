--Synchro Rivalry
--  By Shad3

local scard=s

function scard.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetCondition(scard.cd)
  e1:SetOperation(scard.op)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
  c:RegisterEffect(e3)
end

function scard.syn_fil(c)
  return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsControler(p)
end

function scard.cd(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(scard.syn_fil,1,nil,1-tp)
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  e1:SetReset(RESET_PHASE+PHASE_END)
  e1:SetValue(1)
  Duel.RegisterEffect(e1,tp)
end
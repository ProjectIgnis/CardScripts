--Muscle Gardna
--  By Shad3

local scard=s

function scard.initial_effect(c)
  --Cannot attack
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetCondition(scard.cd)
  c:RegisterEffect(e1)
end

function scard.cd(e)
  return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end
--Giant Kra-Corn
--  By Shad3

local scard=s
function scard.initial_effect(c)
  --Continual effect
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(LOCATION_MZONE,0)
  e1:SetTarget(scard.tg)
  e1:SetValue(scard.val)
  c:RegisterEffect(e1)
end

function scard.fil(c)
  return c:IsRace(RACE_PLANT) and c:IsPosition(POS_FACEUP_ATTACK)
end

function scard.tg(e,c)
  return scard.fil(c)
end

function scard.val(e,c)
  return Duel.GetMatchingGroup(scard.fil,c:GetControler(),LOCATION_MZONE,0,c):GetSum(Card.GetBaseAttack)
end
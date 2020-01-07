--Giant Kra-Corn
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Continual effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tg)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.fil(c)
  return c:IsRace(RACE_PLANT) and c:IsPosition(POS_FACEUP_ATTACK)
end
function s.tg(e,c)
  return s.fil(c)
end
function s.val(e,c)
  return Duel.GetMatchingGroup(s.fil,c:GetControler(),LOCATION_MZONE,0,c):GetSum(Card.GetBaseAttack)
end
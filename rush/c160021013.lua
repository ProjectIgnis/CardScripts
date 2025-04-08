--花牙クノイチ・リンカーネイション
--Rincarnation the Shadow Flower Ninja
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gains ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsTurnPlayer(1-tp) and not Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local atk=g:GetMaxGroup(Card.GetBaseAttack):GetFirst():GetBaseAttack()
	return atk
end
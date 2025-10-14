--背乗りドラコ
--Draco the Rider
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--Take no battle damage involving this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_DRAGON) and c:IsAttack(0) and c:IsDefense(1400)
end
function s.val(e,c)
	local tp=e:GetHandler():GetControler()
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil)
	return ct*500
end
--天啓の監視者
--Watchman of the Apocalypse
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
end
function s.con(e)
	return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandlerPlayer(),0,LOCATION_GRAVE,nil)>=6
end
function s.indval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsMonster() and rc:IsLevelBelow(8) and aux.indoval(e,re,rp)
end
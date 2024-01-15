--七宝神－良財
--Deity of Seven Treasures - Ryozai
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	--Cannot be destroyed by your opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
end
s.listed_names={160007052}
function s.cfilter(c)
	return c:IsCode(160007052) or (c:IsMonster() and c:IsDefense(2700))
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_GRAVE,0,1,nil)
end
function s.indtg(e,c)
	return (c:IsFaceup() and c:IsMonster() and c:IsLevel(7)) or (c:IsFacedown() and c:IsSpellTrap())
end
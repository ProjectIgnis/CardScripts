--アドバンスド・シールド・アーマー
--Advanced Shield
local s,id=GetID()
function s.initial_effect(c)
	Armor.AddProcedure(c)
	--Must be Summoned while you control an Armor monster
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(function(e) return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_ARMOR),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e3)
	--Cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
end
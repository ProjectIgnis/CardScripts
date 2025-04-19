-- ドラゴンに乗るワイバーン (Rush)
--Alligator's Sword Dragon (Rush)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Material
	Fusion.AddProcMix(c,true,true,88819587,64428736)
	--Can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.dircon)
	e1:SetOperation(s.dirop)
	c:RegisterEffect(e1)
end
function s.dircon(e,tp,eg,ep,ev,re,r,rp)
	local ATTRIBUTE_EARTH_WATER_FIRE=ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local ct=#g
	return ct>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH_WATER_FIRE)==ct and Duel.IsAbleToEnterBP()
		and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Direct attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3205)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
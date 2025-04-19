--ドドドセカンド
--Dododo Second
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.fupfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_SPIRIT_STADIUM)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fupfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and (not Duel.IsPlayerAffectedByEffect(tp,FLAG_NO_TRIBUTE))
		and e:GetHandler():CanBeDoubleTribute(FLAG_DOUBLE_TRIB_FIRE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--cost
	Duel.PayLPCost(tp,500)
	--effect
	local c=e:GetHandler()
	c:AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_FIRE)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_FIRE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelAbove(7) and c:IsSummonableCard()
end

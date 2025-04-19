--ロイヤルデモンズ・ガーディアン
--Royal Rebel's Guardian
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelAbove,7),tp,0,LOCATION_MZONE,1,nil)
		and (not Duel.IsPlayerAffectedByEffect(tp,FLAG_NO_TRIBUTE)) and e:GetHandler():CanBeDoubleTribute(FLAG_DOUBLE_TRIB_FIEND)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Double tribute
	local c=e:GetHandler()
	c:AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_FIEND)
	if Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)>1 then
		c:UpdateLevel(1,RESETS_STANDARD_PHASE_END,c)
	end
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_FIEND) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsRace(RACE_FIEND) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
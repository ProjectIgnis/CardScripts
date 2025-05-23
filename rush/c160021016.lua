--Ｐ・Ｍ タートグル
--Plasmatic Model Turtglue
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of your monsters gain 1 level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.filter(c)
	return c:HasLevel() and c:IsRace(RACE_THUNDER) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)<1 then return end
	--Effect
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		for tc in g:Iter() do
			tc:UpdateLevel(4,RESETS_STANDARD_PHASE_END,c)
		end
	end
end
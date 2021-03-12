-- アンドール
--Andoll
local s,id=GetID()
function s.initial_effect(c)
	--Set cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160201038,160201039}
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end

function s.ssfilter(c)
	return (c:IsCode(160201038) or c:IsCode(160201039)) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ssfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil) end
	
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.SendtoGrave(c,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ssfilter),tp,LOCATION_GRAVE,0,1,2,nil,e,tp)
	Duel.HintSelection(g)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
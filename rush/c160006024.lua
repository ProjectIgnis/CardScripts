-- 暗黒シャイン王アークトーク
--Worker Warrior - Sinister CEO
local s,id=GetID()
function s.initial_effect(c)
	-- Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160006062,160006063}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelAbove,7),tp,0,LOCATION_MZONE,nil)
	return #g>0
end
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #sg>0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.sfilter(c)
	return c:IsCode(160006062,160006063) and c:IsSSetable()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160006062)<2 and sg:FilterCount(Card.IsCode,nil,160006063)<2
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Requirement
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		-- Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- Set cards
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
			if ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				local tg=aux.SelectUnselectGroup(sg,1,tp,1,ft,s.rescon,1,tp)
				Duel.HintSelection(tg)
				Duel.SSet(tp,tg)
			end
		end
	end
end

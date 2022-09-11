-- エンシェント・アライブ・ドラゴン
-- Ancient Arrive Dragon
local s,id=GetID()
function s.initial_effect(c)
	-- atk change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160003022,160003023}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.atkfilter(c)
	return c:IsMonster() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,2,nil)
			if #g2>0 then
				for tc in g2:Iter() do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(-400)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffectRush(e1)
				end
				local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft=math.min(2,ct)
				local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
				if ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					local tg=aux.SelectUnselectGroup(sg,1,tp,1,ft,s.rescon,1,tp)
					Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
function s.sfilter(c,e,tp)
	return c:IsCode(160003022,160003023) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160003022)<2 and sg:FilterCount(Card.IsCode,nil,160003023)<2
end
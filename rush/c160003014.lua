--スパークハーツ・ガール
--Sparkhearts Girl
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 opponent monster lose 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={76103675,160301014} --"Sparks", "Curtain of Sparks"
function s.costfilter(c)
	return c:IsMonster() and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,nil) end
end
function s.sfilter(c)
	return c:IsCode(76103675,160301014) and c:IsSSetable()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,76103675)<2 and sg:FilterCount(Card.IsCode,nil,160301014)<2
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		--Effect
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-500)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				g:GetFirst():RegisterEffect(e1)
			end
			--Set cards
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
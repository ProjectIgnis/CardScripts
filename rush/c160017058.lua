--コスモス姫のお戯れ
--Jest of the Cosmos Princess
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw 3 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsMonster,nil)>=2
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_ONFIELD)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	local og=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_DISCARD,s.rescon)
	if Duel.SendtoGrave(og,REASON_COST)<1 then return end
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,2,nil)
		sg=sg:AddMaximumCheck()
		if #sg>0 then
			Duel.HintSelection(sg)
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				if Duel.GetFieldGroupCountRush(tp,0,LOCATION_ONFIELD)>=2 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.BreakEffect()
					Duel.Draw(tp,2,REASON_EFFECT)
				end
			end
		end
	end
end
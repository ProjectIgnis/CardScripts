--フィッシュアンドビッズ
--Fish and Bids
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Take 2 Fish monsters from your Deck and either banish both or send both to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsPhase(PHASE_MAIN1) and not Duel.CheckPhaseActivity() end)
	e1:SetCost(s.rmtgcost)
	e1:SetTarget(s.rmtgtg)
	e1:SetOperation(s.rmtgop)
	c:RegisterEffect(e1)
end
function s.rmtgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmtgfilter(c)
	return c:IsRace(RACE_FISH) and (c:IsAbleToRemove() or c:IsAbleToGrave())
end
function s.rescon(sg)
	return sg:FilterCount(Card.IsAbleToRemove,nil)==2 or sg:FilterCount(Card.IsAbleToGrave,nil)==2
end
function s.rmtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.rmtgfilter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.rmtgop(e,tp,eg,ep,ev,re,r,rp)
	local oppo=1-tp
	local hg=Duel.GetMatchingGroup(Card.IsAbleToRemove,oppo,LOCATION_HAND,0,nil,oppo)
	--Your opponent can banish 2 cards from their hand
	if #hg>=2 and Duel.SelectYesNo(oppo,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,oppo,HINTMSG_REMOVE)
		local hsg=hg:Select(oppo,2,2,nil)
		return #hsg==2 and Duel.Remove(hsg,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,oppo)==2
	end
	--If they do not, take 2 Fish monsters from your Deck and either banish both or send both to the GY
	local g=Duel.GetMatchingGroup(s.rmtgfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,2))
	if #sg==2 then
		local b1=sg:FilterCount(Card.IsAbleToRemove,nil)==2
		local b2=sg:FilterCount(Card.IsAbleToGrave,nil)==2
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
		if op==1 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		elseif op==2 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	--You cannot Special Summon for the rest of this turn, except Fish monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_FISH) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
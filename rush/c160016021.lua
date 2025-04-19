--アビスレイヤー・クインティアマット
--Abysslayer Quintiamat
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_MAXIMUM)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.filter,nil)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,0) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsLevelAbove(7) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	local og=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
	Duel.HintSelection(og,true)
	if Duel.SendtoDeck(og,nil,SEQ_DECKTOP,REASON_COST)<1 then return end
	Duel.ShuffleDeck(tp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.ConfirmDecktop(tp,5)
		local g=Duel.GetDecktopGroup(tp,5)
		Duel.DisableShuffleCheck()
		if g:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=g:FilterSelect(tp,s.thfilter,1,3,nil)
			if #tg>0 then
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
				Duel.ShuffleHand(tp)
				g:RemoveCard(tg)
			end
		end
		local ct=#g
		if ct>0 then
			Duel.MoveToDeckBottom(ct,tp)
			Duel.SortDeckbottom(tp,tp,ct)
		end
	end
end
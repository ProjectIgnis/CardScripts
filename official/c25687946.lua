--メルフィーがころんだ
--Melffy Statues Game
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add up to 4 "Melffy" monsters with different names from your Deck to your hand, then it becomes the End Phase of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--You cannot Special Summon the turn you activate this card, except "Melffy" monsters
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsSetCard(SET_MELFFY) and c:IsFaceup() end)
	--You can banish this card from your GY, then target 2 "Melffy" cards in your GY, except "Melffy Statues Game"; add 1 of them to your hand, and if you do, place the other on the bottom of the Deck. You can only use this effect of "Melffy Statues Game" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thdtg)
	e2:SetOperation(s.thdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MELFFY}
s.listed_names={id}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon the turn you activate this card, except "Melffy" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(SET_MELFFY) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return c:IsSetCard(SET_MELFFY) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local thg=aux.SelectUnselectGroup(g,e,tp,1,4,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #thg>0 and Duel.SendtoHand(thg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,thg)
		local turn_player=Duel.GetTurnPlayer()
		Duel.BreakEffect()
		if Duel.IsMainPhase1() then
			Duel.SkipPhase(turn_player,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
			--Prevent the player from entering the Battle Phase
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,turn_player)
		elseif Duel.IsMainPhase2() then
			Duel.SkipPhase(turn_player,PHASE_MAIN2,RESET_PHASE|PHASE_END,1)
		end
	end
end
function s.thdfilter(c)
	return c:IsSetCard(SET_MELFFY) and (c:IsAbleToHand() or c:IsAbleToDeck()) and not c:IsCode(id)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAbleToHand,nil)>=1 and sg:FilterCount(Card.IsAbleToDeck,nil)>=1
end
function s.thdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(s.thdfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,3))
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,0)
end
function s.gythfilter(c,tg)
	return c:IsAbleToHand() and tg:IsExists(Card.IsAbleToDeck,1,c)
end
function s.thdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=tg:FilterSelect(tp,s.gythfilter,1,1,nil,tg)
		if #hg==0 then return end
		Duel.HintSelection(hg)
		if Duel.SendtoHand(hg,nil,REASON_EFFECT)==0 then return end
		local dg=tg-hg
		if #dg==0 then return end
		Duel.HintSelection(dg)
		Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
--閃光の封殺剣
--Flashforce Sword
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Banish (face-up) 1 random card from your opponent's hand (until the Standby Phase of the next turn), then if this card was Set before activation and it banished a monster, you can apply this effect based on its Level
	--● 4 or lower: Your opponent banishes all monsters with its same name from their hand, Deck, and GY
	--● 5 or higher: Add 1 Level 5 or higher monster with the same Type, Attribute, and/or Level from your Deck to your hand
	--You can only activate 1 "Flashforce Sword" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	local c=e:GetHandler()
	local cd=e:GetChainData()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsPreviousPosition(POS_FACEDOWN) then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
		cd.set_before_activation=true
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_REMOVE)
		cd.set_before_activation=false
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.thfilter(c,race,attr,lv)
	return c:IsLevelAbove(5) and (c:IsRace(race) or c:IsAttribute(attr) or c:IsLevel(lv)) and c:IsAbleToHand()
end
function s.banfilter(c,code,opp)
	return c:IsMonster() and c:IsCode(code) and c:IsAbleToRemove(opp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sc=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1):GetFirst()
	if not sc then return end
	local turn_count=Duel.GetTurnCount()
	local reset_count=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
	--Banish (face-up) 1 random card from your opponent's hand (until the Standby Phase of the next turn)
	if aux.RemoveUntil(sc,POS_FACEUP,REASON_EFFECT,PHASE_STANDBY,id,e,tp,
		function(rg,e,tp,eg,ep,ev,re,r,rp)
			Duel.Hint(HINT_CARD,0,id)
			Duel.SendtoHand(rg,rg:GetFirst():GetPreviousControler(),REASON_EFFECT)
		end,
		function()
			return Duel.GetTurnCount()==turn_count+1
		end,
		RESET_PHASE|PHASE_STANDBY,reset_count)
		and sc:IsLocation(LOCATION_REMOVED) and sc:IsMonster()
		and e:GetChainData().set_before_activation then
		--● 4 or lower: Your opponent banishes all monsters with its same name from their hand, Deck, and GY
		local opp=1-tp
		local apply_banish_chk=sc:IsLevelBelow(4) and Duel.IsPlayerCanRemove(opp)
			and Duel.GetMatchingGroupCount(nil,opp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil)>0
		--● 5 or higher: Add 1 Level 5 or higher monster with the same Type, Attribute, and/or Level from your Deck to your hand
		local race,attr,lv=sc:GetRace(),sc:GetAttribute(),sc:GetLevel()
		local apply_search_chk=sc:IsLevelAbove(5)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,race,attr,lv)
		if not (apply_banish_chk or apply_search_chk) then return end
		local hint_offset=apply_banish_chk and 1 or 2
		if not Duel.SelectYesNo(tp,aux.Stringid(id,hint_offset)) then return end
		if apply_banish_chk then
			--● 4 or lower: Your opponent banishes all monsters with its same name from their hand, Deck, and GY
			local g=Duel.GetMatchingGroup(s.banfilter,opp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,sc:GetCode(),opp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT,nil,opp)
			end
		elseif apply_search_chk then
			--● 5 or higher: Add 1 Level 5 or higher monster with the same Type, Attribute, and/or Level from your Deck to your hand
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,attr,lv)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(opp,g)
			end
		end
	end
end
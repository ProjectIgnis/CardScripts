--レイズ・ムーンの望 スクイーズ－ジャックポット
--Raise Moon Hope Squeeze - Jackpot
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 7 monsters
	Xyz.AddProcedure(c,nil,7,2,nil,nil,Xyz.InfiniteMats)
	--Your opponent's monsters cannot target monsters for attacks, except this one
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(function(e,c)
		return c~=e:GetHandler()
	end)
	c:RegisterEffect(e1)
	--If this card is Xyz Summoned, or a monster(s) is Special Summoned from the hand: You can detach any number of materials from this card; place that many cards your opponent controls on the bottom of the Deck in any order. You can only use this effect of "Raise Moon Hope Squeeze - Jackpot" once per turn
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_TODECK)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsXyzSummoned()
	end)
	e2a:SetCost(Cost.DetachFromSelf(1,function(e,tp)
			return Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
		end)
	)
	e2a:SetTarget(s.tdtg)
	e2a:SetOperation(s.tdop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
	end)
	c:RegisterEffect(e2b)
	--Each time your opponent makes a card(s) leave their Deck, except by drawing them: You can attach the top card of their Deck to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.attachcon)
	e3:SetTarget(s.attachtg)
	e3:SetOperation(s.attachop)
	c:RegisterEffect(e3)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	local detached_materials_count=#e:GetChainData().cost_detached_materials
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,detached_materials_count,1-tp,LOCATION_ONFIELD)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local detached_materials_count=#e:GetChainData().cost_detached_materials
	if not Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,detached_materials_count,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,detached_materials_count,detached_materials_count,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and #g:Match(Card.IsLocation,nil,LOCATION_DECK)>0 then
		local your_g,opp_g=g:Split(Card.IsControler,nil,tp)
		if #your_g>1 then
			Duel.SortDeckbottom(tp,tp,#your_g)
		end
		if #opp_g>1 then
			Duel.SortDeckbottom(tp,1-tp,#opp_g)
		end
	end
end
function s.attachconfilter(c,opp)
	return c:IsPreviousControler(opp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsReasonPlayer(opp)
		and not c:IsReason(REASON_DRAW)
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.attachconfilter,1,nil,1-tp) and (not eg:IsContains(c) or c:IsPreviousLocation(LOCATION_MZONE))
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsXyzMonster() and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(1-tp,1)
	if c:IsRelateToEffect(e) and #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Overlay(c,g)
	end
end
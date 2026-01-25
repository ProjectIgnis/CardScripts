--大輪の魔導書
--Spellbook of the Grand Circle
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 4 "Charmer" monsters with different Attributes from your Deck, GY, and/or banishment to your hand, then shuffle 2 cards from your hand into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Fusion Monster from your Extra Deck, using "Charmer" and/or "Familiar-Possessed" monsters from your hand or field, also your opponent cannot activate cards or effects when a monster is Fusion Summoned this way
	local fusion_params={
				matfilter=function(c) return c:IsSetCard({SET_CHARMER,SET_FAMILIAR_POSSESSED}) end,
				stage2=s.stage2
			}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
end
s.listed_series={SET_CHARMER,SET_FAMILIAR_POSSESSED}
function s.thfilter(c)
	return c:IsSetCard(SET_CHARMER) and c:IsMonster() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
		and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,4,4,aux.dpcheck(Card.GetAttribute),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g<4 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_ATOHAND)
	if #sg==4 and Duel.SendtoHand(sg,nil,REASON_EFFECT)==4 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tdg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
		if #tdg==2 then
			Duel.BreakEffect()
			Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.stage2(e,fc,tp,sg,chk)
	if chk==1 then
		--Your opponent cannot activate cards or effects when a monster is Fusion Summoned this way
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetOperation(function(e)
					Duel.SetChainLimitTillChainEnd(function(e,ep,tp) return tp==ep end)
					e:Reset()
				end)
		Duel.RegisterEffect(e1,tp)
	end
end

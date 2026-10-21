--堅守する千年ゴーレム
--Invincible Millennium Golem
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials: "Destroyer Golem" + 1 Level 5 or lower EARTH monster
	Fusion.AddProcMixN(c,true,true,73481154,1,s.matfilter,1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Choose 1 "Revival of Sennin Genjin" in your Graveyard and add it to the hand. Then, you can choose up to 2 cards in your opponent's Graveyard and shuffle them into the Deck. If they are returned, then this card's Level is increased by 2 until the end of the turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.named_material={73481154} --Destroyer Golem
s.listed_names={160027057} --"Revival of Sennin Genjin"
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH,scard,sumtype,tp) and c:IsLevelBelow(5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsFusionSummoned()
end
function s.thfilter(c)
	return c:IsCode(160027057) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LVCHANGE,e:GetHandler(),1,tp,2)
end
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local todeck_g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,2,nil)
			Duel.HintSelection(todeck_g)
			if Duel.SendtoDeck(todeck_g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
				--This card's Level is increased by 2 until the end of the turn.
				e:GetHandler():UpdateLevel(2,RESETS_STANDARD_PHASE_END,e:GetHandler())
			end
		end
	end
end
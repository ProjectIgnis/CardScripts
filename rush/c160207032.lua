--レガシーレクス・レガレクス
--Legacyrex Legarex
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Mill and add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.mltg)
	e1:SetOperation(s.mlop)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,6,nil)
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_SEASERPENT)
end
function s.cfilter1(c,tp)
	return c:IsRace(RACE_SEASERPENT) and c:IsLevelAbove(7) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetLevel())
end
function s.cfilter2(c,lvl)
	return c:IsRace(RACE_SEASERPENT) and c:IsLevelAbove(7) and c:IsLevel(lvl) and c:IsAbleToHand()
end
function s.thfilter(c)
	return c:IsRace(RACE_SEASERPENT) and c:IsLevelAbove(7) and c:IsAbleToHand()
end
function s.mlop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	if Duel.GetOperatedGroup():FilterCount(s.cfilter,nil)>0
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1
end
-- 大くしゃみのゼニゲバザウルス
--Sneezing Greedizauls
local s,id=GetID()
function s.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGraveAsCost()
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
end
function s.filter(c)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
		local g2=Duel.GetOperatedGroup()
		local dam=(g:FilterCount(s.filter,nil) + g2:FilterCount(s.filter,nil))*400
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
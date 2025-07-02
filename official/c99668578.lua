--星因士 プロキオン
--Satellarknight Procyon
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 "tellarknight" monster from your hand to the GY, and if you do, draw 1 card
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.drtg)
	e1a:SetOperation(s.drop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1c)
end
s.listed_series={SET_TELLARKNIGHT}
function s.tgfilter(c)
	return c:IsSetCard(SET_TELLARKNIGHT) and c:IsMonster() and c:IsAbleToGrave()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	--Excluding itself for a proper interaction with "Tellarknight Constellar Caduceus" [58858807]
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_EFFECT)>0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
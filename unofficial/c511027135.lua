--ポイズン・チェーン (Anime)
--Poison Chain (Anime)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--discard deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={0x25}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x25) and c:HasLevel()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local lv=g:GetSum(Card.GetLevel)
	if chk==0 then return lv>0 and Duel.IsPlayerCanDiscardDeck(1-tp,lv) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,lv)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local lv=g:GetSum(Card.GetLevel)
	if lv>0 then
		Duel.DiscardDeck(1-tp,lv,REASON_EFFECT)
	end
end

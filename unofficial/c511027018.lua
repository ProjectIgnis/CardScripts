--Ｖａｉｎ－裏切りの嘲笑
--Vain Betrayer (anime)
--Script by Rundas
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
    --activate + send to grave
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.actcon)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
    --negate effects + prevent attacks
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.disable)
    e2:SetCode(EFFECT_DISABLE)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e3)
end

--activate + send to grave

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():Is_V_()
end

function s.filter(c)
	return c:Is_V_()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_DECK,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	if Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_DECK,nil)==0 and ct==#og then 
		Duel.Recover(tp,#og*500,REASON_EFFECT)
		Duel.BreakEffect()
		if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 then
			Duel.ShuffleDeck(1-tp)
			Duel.DiscardDeck(1-tp,math.min(#og*5,Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)),REASON_EFFECT)
		end
	end
end

--negate effect + cannot attack

function s.disable(e,c)
	return c:Is_V_()
end

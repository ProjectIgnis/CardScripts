--讃美火
--Hymnal Flame
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--deck destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g>0 and Duel.IsPlayerCanDiscardDeck(1-tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,g)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD),REASON_EFFECT)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g>0 and Duel.IsPlayerCanDiscardDeck(tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,g)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD),REASON_EFFECT)
end
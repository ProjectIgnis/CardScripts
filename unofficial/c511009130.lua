--Ｃ－ドンウーノ
--Cup Udon Uno
local s,id=GetID()
function s.initial_effect(c)
	--When this card is destroyed and sent to the Graveyard, destroy all cards in your opponent's Spell & Trap Card Zone.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95100656,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(function(e) return e:GetHandler():IsReason(REASON_DESTROY) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_STZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_STZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

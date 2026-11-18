--シグナル・ビークル
--Signal Vehicle
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent attacks, they must discard one card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetTarget(s.oppdiscardtg)
	e1:SetOperation(s.oppdiscardop)
	c:RegisterEffect(e1)
end
function s.oppdiscardtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.oppdiscardop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
end

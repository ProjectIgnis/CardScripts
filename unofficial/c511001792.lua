--ナンバーズ・カルマ
--Number Karma
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_NUMBER)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.cfilter,1-tp,LOCATION_MZONE,0,nil)
	if #g1==0 then
		Duel.Damage(tp,500,REASON_EFFECT,true)
	end
	if #g2==0 then
		Duel.Damage(1-tp,500,REASON_EFFECT,true)
	end
	Duel.RDComplete()
end
--アンブラル・デス・ブラッド
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	return tc:IsPreviousControler(tp) and  tc:IsSetCard(0x87) and tc:IsReason(REASON_BATTLE) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=eg:GetFirst():GetReasonCard()
	if chk==0 then return tg:IsOnField() and tg:IsDestructable() end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:GetFirst():GetReasonCard()
	if tg:IsRelateToEffect(e) then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

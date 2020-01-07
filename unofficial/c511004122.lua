--Utopia's Last Line of Defense 
--scripted by:urielkama
local s,id=GetID()
function s.initial_effect(c)
--change position
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.con2)
	e1:SetOperation(s.op2)
	c:RegisterEffect(e1)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return r~=REASON_BATTLE and bt:IsSetCard(0x107f)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
local bt=Duel.GetAttackTarget()
	if bt:IsRelateToBattle() and not bt:IsPosition(POS_FACEUP_DEFENSE) then
	Duel.ChangePosition(bt,POS_FACEUP_DEFENSE,REASON_EFFECT)
	end
end
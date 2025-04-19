--女教皇の錫杖 (Anime)
--Empress's Staff (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	e2:SetDescription(aux.Stringid(id,0))
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()~=nil
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local p=Duel.GetAttacker():GetControler()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		local p=Duel.GetAttacker():GetControler()
		Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
		Duel.BreakEffect()
		Duel.Damage(p,500,REASON_EFFECT)
	end
end
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)==0
end
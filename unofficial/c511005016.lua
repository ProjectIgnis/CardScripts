--Astral Shift
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCondition(s.act_cd)
	e1:SetTarget(s.act_tg)
	e1:SetOperation(s.act_op)
	c:RegisterEffect(e1)
end
function s.act_cd(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp)
end
function s.act_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
end
function s.act_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeAttackTarget(nil)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(s.draw_op)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	Duel.RegisterEffect(e1,tp)
end
function s.draw_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
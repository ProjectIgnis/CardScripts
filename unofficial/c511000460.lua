--聖なる旋風－ディバイン・ウィンド
--Divine Wind
--re-scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER) and ep~=tp
		and (aux.damcon1(e,tp,eg,ep,ev,re,r,rp) or aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ex,_,_,_,dam=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if not ex then
		ex,_,_,_,dam=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam+500)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local ex,_,_,_,dam=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
		if not ex then
			ex,_,_,_,dam=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
		end
		Duel.Damage(1-tp,dam+500,REASON_EFFECT)
	end
end

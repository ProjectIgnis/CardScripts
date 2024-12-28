--インフェルニティ・サプレッション
--Infernity Suppression
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Negate monster effect and inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Can be activated during the turn it was Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
s.listed_series={SET_INFERNITY}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_INFERNITY),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():HasLevel() then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,re:GetHandler():GetLevel()*100)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():HasLevel() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local dam=re:GetHandler():GetLevel()*100
		if dam>0 then
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
function s.actcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
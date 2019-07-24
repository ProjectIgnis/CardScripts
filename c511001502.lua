--Trick Mirror
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(511001283)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp~=tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=re:GetTarget()
	if chk==0 then return not re:GetHandler():IsHasEffect(511001283) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) end
	e:SetCategory(re:GetCategory())
	e:SetProperty(re:GetProperty())
	e:SetLabelObject(re)
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():CancelToGrave(false)
end

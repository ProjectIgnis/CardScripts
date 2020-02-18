--Wish of Final Effort
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:GetAttack()>0 and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:GetControler()==tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc,tp) and s.filter(chkc,tp) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) end
	local g=eg:Filter(s.filter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabelObject():GetAttack()
	Duel.Recover(tp,atk,REASON_EFFECT)
end

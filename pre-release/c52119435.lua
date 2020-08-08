--転晶のコーディネラル
--Coordineral the Gem Transferer
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Switch control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.concon)
	e2:SetTarget(s.contg)
	e2:SetOperation(s.conop)
	c:RegisterEffect(e2)
end
function s.indcon(e)
	return e:GetHandler():IsLinked()
end
function s.indtg(e,c)
	local oc=e:GetHandler()
	return c==oc or oc:GetLinkedGroup():IsContains(c)
end
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroupCount()==2
end
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetLinkedGroup()
	if chk==0 then return not g:IsExists(aux.NOT(Card.IsControlerCanBeChanged),1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,0,0)
end
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup()
	if #g~=2 then return end
	local c=g:GetFirst()
	local oc=g:GetNext()
	Duel.SwapControl(c,oc)
end

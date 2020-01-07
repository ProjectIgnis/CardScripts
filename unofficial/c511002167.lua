--闇晦ましの城
local s,id=GetID()
function s.initial_effect(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_LIMIT_SET_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetTarget(s.tttg)
	e1:SetOperation(s.ttop)
	e1:SetTargetRange(POS_FACEDOWN,0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TRUE)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.ttcon(e,c)
	if c==nil then return true end
	min,max=c:GetTributeRequirement()
	return Duel.CheckTribute(c,min,max)
end
function s.tttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	min,max=c:GetTributeRequirement()
	local g=Duel.SelectTribute(tp,c,min,max,nil,nil,nil,true)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end

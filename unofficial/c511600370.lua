--光と闇の竜 (Manga)
--Light and Darkness Dragon (Manga)
--Scripted by Larry126 & senpaizuri3
local s,id=GetID()
function s.initial_effect(c)
	--Summon limitation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_ACTIVATING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
function s.sumcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetTributeGroup(c)
	mg=mg:Filter(aux.IsZone,nil,relzone,tp)
	local tributes=maplevel(c:GetLevel())
	return tributes>0 and minc<=tributes and Duel.CheckTribute(c,tributes,tributes,mg,tp,zone)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetTributeGroup(c)
	mg=mg:Filter(aux.IsZone,nil,relzone,tp)
	local tributes=maplevel(c:GetLevel())
	local g=Duel.SelectTribute(tp,c,tributes,tributes,mg,tp,zone,Duel.GetCurrentChain()==0)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and e:GetHandler():GetFlagEffect(id)==0
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	if c:GetFlagEffect(id)>0 or c:GetDefense()<500 or c:GetAttack()<500 or Duel.GetCurrentChain()~=ev or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	if Duel.NegateActivation(ev) then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
			Duel.SendtoGrave(re:GetHandler(),REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-500)
		c:RegisterEffect(e2)
	end
end
function s.descon(e)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	Duel.Destroy(dg,REASON_EFFECT)
end
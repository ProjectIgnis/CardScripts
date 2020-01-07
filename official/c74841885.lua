--天魔神 インヴィシル
local s,id=GetID()
function s.initial_effect(c)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--tribute check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	--give negate effect only when summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetOperation(s.facechk)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.chkfilter(c,rac,att)
	return c:IsRace(rac) and c:IsAttribute(att)
end
function s.valcheck(e,c)
	if e:GetLabel()~=1 then return end
	e:SetLabel(0)
	local g=c:GetMaterial()
	local lbl=0
	if g:IsExists(s.chkfilter,1,nil,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		lbl=lbl+TYPE_SPELL
	end
	if g:IsExists(s.chkfilter,1,nil,RACE_FIEND,ATTRIBUTE_DARK) then
		lbl=lbl+TYPE_TRAP
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
		e0:SetRange(LOCATION_MZONE)
		e0:SetCode(3682106)
		e0:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e0)
	end
	if lbl~=0 then
		--disable
		local e1=Effect.CreateEffect(c)
		if lbl==TYPE_SPELL then
			e1:SetDescription(aux.Stringid(id,0))
		elseif lbl==TYPE_TRAP then
			e1:SetDescription(aux.Stringid(id,1))
		else
			e1:SetDescription(aux.Stringid(id,2))
		end
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
		e1:SetTarget(s.distg)
		e1:SetLabel(lbl)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
		--disable effect
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetRange(LOCATION_MZONE)
		e2:SetLabel(lbl)
		e2:SetOperation(s.disop)
		e2:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e2)
		if lbl&TYPE_TRAP~=0 then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetRange(LOCATION_MZONE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(s.distg)
			e3:SetLabel(TYPE_TRAP)
			e3:SetReset(RESET_EVENT+0xff0000)
			c:RegisterEffect(e3)
		end
	end
end
function s.distg(e,c)
	return c:IsType(e:GetLabel())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl&LOCATION_SZONE~=0 and re:IsActiveType(e:GetLabel()) then
		Duel.NegateEffect(ev)
	end
end
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end

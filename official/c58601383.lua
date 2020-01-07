--地天の騎士ガイアドレイク
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,97204936,s.ffilter)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter1)
	c:RegisterEffect(e2)
	--cannot be destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter2)
	c:RegisterEffect(e3)
end
s.miracle_synchro_fusion=true
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_SYNCHRO,fc,sumtype,tp) and not c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end
function s.efilter1(e,re,rp)
	return re:IsActiveType(TYPE_EFFECT)
end
function s.efilter2(e,re)
	return re:IsActiveType(TYPE_EFFECT)
end

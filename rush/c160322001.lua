--ハーピィ三姉妹・ＴＢ
--Harpie Lady Sisters Triangle Beauty
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160208002,1,s.matfilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Name becomes "Harpie Ladies"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(160208002)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--cannot be used as Fusion Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(s.sumlimit)
	c:RegisterEffect(e3)
end
s.named_material={160208002}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WIND,scard,sumtype,tp) and c:IsRace(RACE_WINGEDBEAST,scard,sumtype,tp) and not c:IsMaximumModeSide()
end
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost() and not c:IsHasEffect(EFFECT_CANNOT_BE_FUSION_MATERIAL)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.indval(e,re,rp)
	return (re:IsTrapEffect() or re:IsSpellEffect()) and aux.indoval(e,re,rp)
end
function s.indtg(e,c)
	return c:IsLevel(12)
end
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(1-e:GetHandlerPlayer())
end
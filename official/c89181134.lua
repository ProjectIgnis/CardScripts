--捕食植物サンデウ・キンジー
--Predaplant Chlamydosundew
local s,id=GetID()
function s.initial_effect(c)
	--fusattribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.attrtg)
	e1:SetValue(s.attrval)
	e1:SetOperation(s.attrcon)
	c:RegisterEffect(e1)
	--fusion summon
	local params = {aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),nil,s.fextra,nil,Fusion.ForcedHandler}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_PREDATOR}
function s.attrtg(e,c)
	return c:GetCounter(COUNTER_PREDATOR)>0
end
function s.attrval(e,c,rp)
	if rp==e:GetHandlerPlayer() then
		return ATTRIBUTE_DARK
	else return c:GetAttribute() end
end
function s.attrcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end
function s.filter(c)
	return c:IsFaceup() and c:GetCounter(COUNTER_PREDATOR)>0
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.filter),tp,0,LOCATION_MZONE,nil)
end

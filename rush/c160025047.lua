--ギャラクティカ・フュージョン・スペース
--Galactica Fusion Space
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Can also use monsters in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetTarget(aux.TargetBoolFunction(s.extrafil_repl_filter))
	e2:SetOperation(s.operation)
	e2:SetLabelObject({s.extrafil_replacement,s.extramat})
	e2:SetValue(function(_,c) return c and c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_FUSION,160015051}
function s.extrafil_repl_filter(c)
	return c:IsMonster() and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
function s.extrafil_replacement(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.extrafil_repl_filter),tp,LOCATION_GRAVE,0,nil)
end
function s.extramat(c,e,tp)
	return c:IsControler(tp) and e:GetHandler():IsCode(CARD_FUSION)
end
function s.operation(e,tc,tp,sg)
	local g=tc:GetMaterial()
	Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end